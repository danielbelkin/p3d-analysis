function data = readMovie(num, varlist,varargin)
% readMovie(NUM, VARLIST,'NAME',VALUE) reads a movie from the p3d output
% format into a .mat file. 
% NUM is a 3-digit integer indicating the filenumber to read
% VARLIST is a cell array of strings indicating variables to read
% If VARLIST is 'all', then all variables are read.
% Optional arguments and defaults:
% 'rdir' = ''    Directory path from which to read files
% 'wdir' = ''    Directory path to which to write files
% 'skip' = 0     Number of frames to skip
% 'save' = true  Do we save resulting files? 
% 
% To add:
% Option to downsample or otherwise compress?
% Option to grab only a few timesteps?



%% Process inputs
okargs = {'rdir','wdir', 'skip', 'save'};
dflts = {'' '' 0 true};

[rdir, wdir, skip, saveq] = internal.stats.parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

if isnumeric(num)
    num = num2str(num,'%0.3i');
elseif ~ischar(num) || numel(num) ~= 3
    error('Input RUN must be a string or integer')
end

if ischar(varlist)
    varlist = {varlist};
elseif ~iscell(varlist)
    error('Input VARLIST must be either a string or cell array')
end

%% Locate the variables we need
varnames = {'rho'; 'jx'; 'jy'; 'jz'; 'bx'; 'by'; 'bz'; 'ex'; 'ey'; 'ez';
    'ne'; 'jex';'jey'; 'jez'; 'pexx'; 'peyy'; 'pezz'; 'pexy'; 'peyz';
    'pexz'; 'ni'; 'jix'; 'jiy'; 'jiz'; 'pixx'; 'piyy';'pizz'; 'pixy';
    'piyz'; 'pixz'};

if strcmpi(varlist{1},'all')
    idx = 1:length(varnames);
else
    idx = zeros(size(varlist(:)));
    for i = 1:numel(varlist)
        idx(i) = find(strcmpi(varnames,varlist{i})); % List of where each variable is located in the order
    end
    
    if numel(idx) ~= numel(varlist)
        error('At least one variable name appears to be wrong')
    end
end

%% Find system size
filename = [rdir 'p3d.stdout.' num];
fid = fopen(filename);
if fid == -1
    error(['Failed to open file ' filename]);
end

nvals = cell2mat(textscan(fid, '%*[^=] %*1s %d',3)); % [nx ny nz]
fclose(fid);

nx = nvals(1); ny = nvals(2); nz = nvals(3); 


%% Read integer data

disp('Reading data...')
data = cell{1,
tic
for i = 1:numel(varlist)
    filename = [rdir 'movie.' varlist{i} '.' num];
    fid = fopen(filename);
    
    if fid == -1
        error(['Failed to open ' filename]);
    end
    
    data{i} = reshape(fread(fid,Inf,[num2str(nx*ny*nz) '*uint16'],2*nx*ny*nz*skip),nx,ny,nz,[]); 
    fclose(fid);
    toc
end


%% Normalize
% TODO: Add an option to skip normalization?
% Won't need it e.g. for LE calculation

disp('Normalizing data...')
tic
ranges = reshape(dlmread([rdir 'movie.log.' num]),1,1,1,[],2);
for i = 1:numel(varlist)
    nt = size(data{i},4);
    r = ranges(:,:,:,idx(i) + (0:nt-1)*length(varnames),:); % min-max data for the current variable
    A = 2^16./diff(r,1,5); % 1st coefficient for normalization
    B = -A.*r(:,:,:,:,1); % 2nd coefficient for normalization
    data{i} = A.*data{i} + B;
    toc
end

%% Save the files
% Only if no outputs were requested?
if saveq
    for i = 1:numel(varlist)
        m = matfile([wdir varlist{i} '.' num '.mat']);
        m.(varlist{i}) = data{i};
    end
end

disp('Done')
