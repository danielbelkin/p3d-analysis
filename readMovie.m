function val = readMovie(num, varname,varargin)
% readMovie(NUM, VARNAME,'NAME',VALUE) reads a movie from the p3d output
% format into a .mat file. 
% NUM is a 3-digit integer indicating the filenumber to read
% VARNAME is a cell array of strings indicating variables to read
% If VARNAME is 'all', then all variables are read.
% Optional arguments and defaults:
% 'rdir' = ''       Directory path from which to read files
% 'wdir' = ''       Directory path to which to write files
% 'skip' = 0        Number of frames to skip
% 'save' = true     Do we save resulting files? 
% 'compr' = 1       Factor by which to compress each array dimension
%
% TODO: Add smarter memory management. Use matfiles (very slow) to save the
% data in very large chunks. 
% Or use -append to add it frame-by-frame, with each frame a new variable.
% Or just make it possible to read only an arbitrary frame somewhere.
% Add a .params field to the saved data
% Add option to downsample when saving
%
% Possible alternative approaches:
% A Tall array?
% Memory mapping on the original file - but this makes normalization kinda
% hard

%% Process inputs
tic % Start timing
okargs = {'rdir','wdir', 'skip', 'save', 'compr'};
dflts = {'' '' 0 true 1};

[rdir, wdir, skip, saveq, compr] = internal.stats.parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~isempty(wdir) && ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

if isnumeric(num)
    num = num2str(num,'%0.3i');
elseif ~ischar(num) || numel(num) ~= 3
    error('Input RUN must be a string or integer')
end

if ~ischar(varname)
    error('Input VARLIST must be a char array')
end

disp(['Preparing to read movie.' varname '.' num '...'])

%% Locate the variables we need
varnames = {'rho'; 'jx'; 'jy'; 'jz'; 'bx'; 'by'; 'bz'; 'ex'; 'ey'; 'ez';
    'ne'; 'jex';'jey'; 'jez'; 'pexx'; 'peyy'; 'pezz'; 'pexy'; 'peyz';
    'pexz'; 'ni'; 'jix'; 'jiy'; 'jiz'; 'pixx'; 'piyy';'pizz'; 'pixy';
    'piyz'; 'pixz'};

idx = find(strcmpi(varnames,varname)); % Index of where desired variable is located in the order
    
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
A = -diff(r,1,5)*2^-16; % Scale to maximum
B = r(:,:,:,:,1); % Add in minimum


toc % Marks end of preparing-to-read

%% Read integer data


filename = [rdir 'movie.' varname '.' num];
fid = fopen(filename);

if fid == -1
    error(['Failed to open ' filename]);
end

% val = zeros(ceil(nx/compr),ceil(ny/compr),ceil(nz/compr),nframes,'single'); % Pre-allocate

% Matfile version:
m = matfile([wdir varname '.' num '.mat']);
m.info = info;
m.val = zeros(ceil(nx/compr),ceil(ny/compr),ceil(nz/compr),nframes,'single'); % Pre-allocate
data = zeros(nx,ny,nz); % If this exceeds maximum array size limit, then you're screwed.
for i = 1:nframes
    disp(['Getting data for frame ' num2str(i) ' of ' num2str(nframes)])
    data(:) = fread(fid,nx*ny*nz,[num2str(nx*ny*nz) '*uint16=>single'],2*nx*ny*nz*skip);
    if compr > 1
        disp('Compressing...')
        m.val(:,:,:,i) = A(i)*ccompress(data,compr) + B(i);
    else
        m.val(:,:,:,i) = A(i)*data + B(i);
    end
end

% Old version, which we know worked:
% val = reshape(...
%      fread(fid,Inf,[num2str(nx*ny*nz) '*uint16=>single'],2*nx*ny*nz*skip),...
%      nx,ny,nz,[]);

fclose(fid);
toc





%% Normalize
% disp('Normalizing data...')
% 
% r = ranges(:,:,:,idx + (0:nt-1)*length(varnames)*(skip + 1),:); % min-max data for the current variable
% A = -diff(r,1,5)*2^-16; % Scale to maximum
% B = r(:,:,:,:,1); % Add in minimum
% m.val = A.*m.val + B; % This step won't work.
% toc

% I strongly suspect that the memory error occurs when we convert from
% integer to float. 




%% Save the files
% if saveq
%     disp('Saving data...')
%     info = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
%     save([wdir varname '.' num '.mat'],'val','info','-v7.3')
% end

disp(['Done reading ' filename])
toc
end

