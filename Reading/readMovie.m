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
% 
% A concern: It's much faster for the first few frames than later frames.
% Why? 
%
% TODO: Extend info parameter to include electron mass, etc
% TODO: Automatically adapt between int16 ("double-byte") and uint16



%% Process inputs
tic % Start timing
okargs = {'rdir','wdir', 'skip', 'compr'};
dflts = {pwd pwd 0 1};

type = 'int16'; % CHANGE MANUALLY AS NEEDED

[rdir, wdir, skip, compr] = parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~isempty(rdir) && ~strcmp(rdir(end),'/')
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

if compr > 1
    pp = gcp('nocreate');
    if isempty(pp)
        procs = 1; % Number of available processors
    else
        procs = pp.NumWorkers;
    end
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

addpath(pwd); % Add the current directory to the path, just in case
cd(wdir); % If we don't do this, then the temporary files won't work properly for some reason

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
r = ranges(:,:,:,idx + (0:nframes - 1)*length(varnames),:); % min-max data for the current variable


% Scaling formula:
% (maxval - minval)*(x - minint)/(maxint - minint) + minval
% (maxval - minval)/(maxint - minint) * x - (maxval - minval)/(maxint - minint) * minint + minval
% A = (maxval - minval)/(maxint - minint)
% B = minval - A * minint


A = diff(r,1,5)/2^16; % Scale to maximum
B = r(:,:,:,:,1) + 2^15*A; % Add in minimum


%% Read and save data
filename = [rdir 'movie.' name '.' num];
fid = fopen(filename);

if fid == -1
    error(['Failed to open ' filename]);
end

% Initialize files
file = matfile([wdir name '.' num '.mat'],'Writable',true);
info.isComplete = false;
file.info = info;
file.val = zeros(ceil(nx/compr),ceil(ny/compr),ceil(nz/compr),nframes,'single'); % Pre-allocate. If this exceeds maximum array size limit, there is still hope. 

rng('shuffle')
randname = char(randi([97,122],1,5));
if exist(['temp_' randname '.mat'],'file')
    error(['File temp_' ra1ndname '.mat already exists'])
end

if compr > 1
    data = matfile([wdir 'temp_' randname '.mat'],'Writable',true);
    data.val = zeros(nx,ny,nz); % Used for parCompress
end

format = [num2str(nx*ny*nz) '*' type '=>single'];

toc % Marks end of preparing-to-read
if nframes > 1 % Yes, this is terrible. Everything about matfile indexing is terrible.
    for i = 1:nframes
        disp(['Getting data for frame ' num2str(i) ' of ' num2str(nframes)])
        if compr > 1
            % This one line consumes nearly all of the time:
            data.val = reshape(fread(fid,nx*ny*nz,format,2*nx*ny*nz*skip),nx,ny,nz); 
            disp('Compressing...')
            file.val(:,:,:,i) = A(i)*parCompress(data,compr,procs) + B(i);
        else % If we don't need to compress
            file.val(:,:,:,i) = A(i)*reshape(fread(fid,nx*ny*nz,format,2*nx*ny*nz*skip),nx,ny,nz) + B(i);
        end
        toc
    end
else % If we're only reading one frame
    disp('Getting data for frame 1 of 1')
    if compr > 1
        data.val = reshape(fread(fid,nx*ny*nz,format,2*nx*ny*nz*skip),nx,ny,nz);
        disp('Compressing...')
        file.val(:,:,:) = A*parCompress(data,compr,procs) + B;
    else % If we don't need to compress
        file.val(:,:,:) = A*reshape(fread(fid,nx*ny*nz,format,2*nx*ny*nz*skip),nx,ny,nz) + B;
    end
end

c = fread(fid,1,'int16');
if ~feof(fid)
    warning('Something wrong with reading?')
    disp(c)
end

fclose(fid);
data.val = [];
% TODO: Figure out a way to delete temp file
info.isComplete = true;
file.info = info;
disp(['Done reading ' filename])
toc
end

