function readMovie(num, name, varargin)
% readMovie(NUM, NAME) reads a movie from the p3d output
% format into a .mat file. 
% NUM is an integer indicating the filenumber to read. It can also
% be a 3-digit string.
% NAME is a string indicating the variable to read
% So e.g. readMovie('000','bz') reads movie.bz.000
% 
% readMovie(NUM, NAME,'NAME',VALUE)
% 
% Optional arguments and defaults:
% 'rdir' = ''       Directory path from which to read files
% 'wdir' = ''       Directory path to which to write files
% 'skip' = 0        Number of frames to skip
% 'compr' = 1       Factor by which to compress each array dimension
%
% This function is optimized for very large files. For smaller files, the
% older version is faster. The saved .mat file has fields .val, which
% contains the data, and .info, which holds some information about how the
% data was processed. 


%% Process inputs
tic % Start timing
okargs = {'rdir','wdir', 'skip', 'compr'};
dflts = {'' '' 0 1};

[rdir, wdir, skip, compr] = internal.stats.parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~isempty(wdir) && ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

if isnumeric(num)
    num = num2str(num,'%0.3i');
elseif ~ischar(num) || numel(num) ~= 3
    error('Input NUM must be a string or integer')
end

if ~ischar(name)
    error('Input NAME must be a char array')
end

disp(['Preparing to read movie.' name '.' num '...'])

%% Locate the variables we need
varnames = {'rho'; 'jx'; 'jy'; 'jz'; 'bx'; 'by'; 'bz'; 'ex'; 'ey'; 'ez';
    'ne'; 'jex';'jey'; 'jez'; 'pexx'; 'peyy'; 'pezz'; 'pexy'; 'peyz';
    'pexz'; 'ni'; 'jix'; 'jiy'; 'jiz'; 'pixx'; 'piyy';'pizz'; 'pixy';
    'piyz'; 'pixz'};

idx = find(strcmpi(varnames,name)); % Index of where desired variable is located in the order
    
if isempty(idx)
    error('Variable name appears to be wrong')
end

% Compile information about how the data was processed:
info = cell2struct(varargin(2:2:end),varargin(1:2:end),2);

%% Find system size
filename = [rdir 'p3d.stdout.' num];
fid = fopen(filename);
if fid == -1
    error(['Failed to open file ' filename]);
end

nvals = double(cell2mat(textscan(fid, '%*[^=] %*1s %d',3)).*cell2mat(textscan(fid, '%*[^=] %*1s %d',3))); % pex times nx, etc
fclose(fid);

nx = nvals(1);
ny = nvals(2);
nz = nvals(3);

ranges = single(reshape(dlmread([rdir 'movie.log.' num]),1,1,1,[],2)); % Single-precision determined here 
nt = size(ranges,4)/numel(varnames);
nframes = ceil(nt/(skip + 1)); % Number of frames we'll actually read

% Prepare normalization coefficients:
r = ranges(:,:,:,idx + (0:nt-1)*length(varnames)*(skip + 1),:); % min-max data for the current variable
A = diff(r,1,5)*2^-16; % Scale to maximum - sign is wrong.  
B = r(:,:,:,:,1); % Add in minimum


toc % Marks end of preparing-to-read

%% Read and save data
filename = [rdir 'movie.' name '.' num];
fid = fopen(filename);

if fid == -1
    error(['Failed to open ' filename]);
end

% Matfile version:
file = matfile([wdir name '.' num '.mat'],'Writable',true);
file.info = info;
file.val = zeros(ceil(nx/compr),ceil(ny/compr),ceil(nz/compr),nframes,'single'); % Pre-allocate. If this exceeds maximum array size limit, there is still hope. 
data = matfile('temp.mat','Writable',true);
data.val = zeros(nx,ny,nz); % If this exceeds maximum array size limit, then you're screwed.
for i = 1:nframes
    disp(['Getting data for frame ' num2str(i) ' of ' num2str(nframes)])
    data.val(:) = fread(fid,nx*ny*nz,[num2str(nx*ny*nz) '*uint16=>single'],2*nx*ny*nz*skip);
    if compr > 1
        disp('Compressing...')
        file.val(:,:,:,i) = A(i)*ccompress(data,compr) + B(i); 
        % TODO: Consider parallelizing compression.
        % file.val(:,:,:,i) = A(i)*parCompress(data,compr,procs) + B(i);
        % Need to figure out what procs is.
    else
        file.val(:,:,:,i) = A(i)*data + B(i);
    end
    toc
end

fclose(fid);
disp(['Done reading ' filename])
toc
end

