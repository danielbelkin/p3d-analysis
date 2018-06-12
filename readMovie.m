function varargout = readMovie(num, varlist,varargin)
% NUM is a 3-digit integer indicating the filenumber to read
% VARLIST is a cell array of strings indicating variables to read
% 
% Options added:
% File to find movie in
% File to save matfiles to
% Number of frames to skip
% 
% To add:
% Option to downsample or otherwise compress?
% Option to grab only a few timesteps?

okargs = {'rdir','wdir', 'skip'};
dflts = {'' '' 0};

[rdir, wdir, skip] = internal.stats.parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

%% Process inputs
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

idx = zeros(size(varlist(:)));
for i = 1:numel(varlist)
    idx(i) = find(strcmpi(varnames,varlist{i})); % List of where each variable is located in the order
end

if numel(idx) ~= numel(varlist)
    error('At least one variable name appears to be wrong')
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
tic
for i = 1:numel(varlist)
    filename = [rdir 'movie.' varlist{i} '.' num];
    fid = fopen(filename);
    
    if fid == -1
        error(['Failed to open ' filename]);
    end
    
    data{i} = reshape(fread(fid,Inf,[num2str(nx*ny*nz) '*uint16'],2*nx*ny*nz*skip),nx,ny,nz,[]); 
    % Could make this a matfile, do everything from here on out in memory:
    % data{i} = matfile([varlist{i} '.' num '.mat'])
    % data{i}.vals = reshape ...
    % But that appears to be much slower, so let's avoid if possible.
    % But we're probably gonna have an array with 10^8 elements, so that
    % may be unavoidable. 
    % Question: How do we check how much space is available?
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
if nargout ~= 1 % I don't expect us to need any more than this ever
    for i = 1:numel(varlist)
        m = matfile([wdir varlist{i} '.' num '.mat']);
        m.(varlist{i}) = data{i};
    end
else
    varargout{1} = data;
end

disp('Done')
