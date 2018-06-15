function val = readMovie(num, varname,varargin)
% readMovie(NUM, VARNAME,'NAME',VALUE) reads a movie from the p3d output
% format into a .mat file. 
% NUM is a 3-digit integer indicating the filenumber to read
% VARNAME is a cell array of strings indicating variables to read
% If VARNAME is 'all', then all variables are read.
% Optional arguments and defaults:
% 'rdir' = ''    Directory path from which to read files
% 'wdir' = ''    Directory path to which to write files
% 'skip' = 0     Number of frames to skip
% 'save' = true  Do we save resulting files? 
% 'compr' = 1    Factor by which to compress each array dimension
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
okargs = {'rdir','wdir', 'skip', 'save'};
dflts = {'' '' 0 true};

[rdir, wdir, skip, saveq] = internal.stats.parseArgs(okargs,dflts,varargin{:});

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

%% Locate the variables we need
varnames = {'rho'; 'jx'; 'jy'; 'jz'; 'bx'; 'by'; 'bz'; 'ex'; 'ey'; 'ez';
    'ne'; 'jex';'jey'; 'jez'; 'pexx'; 'peyy'; 'pezz'; 'pexy'; 'peyz';
    'pexz'; 'ni'; 'jix'; 'jiy'; 'jiz'; 'pixx'; 'piyy';'pizz'; 'pixy';
    'piyz'; 'pixz'};

idx = find(strcmpi(varnames,varname)); % Index of where desired variable is located in the order
    
if isempty(idx)
    error('At least one variable name appears to be wrong')
end

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


%% Read integer data

disp('Reading data...')
tic

filename = [rdir 'movie.' varname '.' num];
fid = fopen(filename);

if fid == -1
    error(['Failed to open ' filename]);
end

val = reshape(...
     fread(fid,Inf,[num2str(nx*ny*nz) '*uint16=>single'],2*nx*ny*nz*skip),...
     nx,ny,nz,[]);

fclose(fid);

% Ok, so 3rd argument gives # of bytes to skip. There are 2*nx*ny*nz bytes
% in every frame. 
% TODO: Can avoid reshape call. Probably worth doing. 
% TODO: Columns are lined up incorrectly, I believe. Need to ask Marc about
% the proper ordering. 
% Guess: In x-y space, we fill up each y-value(row) from bottom to top,
% then fill rows up the columns.
% So if nx = 2048, ny = 1024, then we want to put 2048 values in,
% then wrap around, then put 2048 values in... etx
% So, a guess: Column
%
% Let's say we want nx = 5, ny = 4, nz = 3
% So it seems like this is correct, just flipped.


toc

%% Normalize
disp('Normalizing data...')
tic
ranges = single(reshape(dlmread([rdir 'movie.log.' num]),1,1,1,[],2)); % Single-precision determined here 
nt = size(val,4);

r = ranges(:,:,:,idx + (0:nt-1)*length(varnames)*(skip + 1),:); % min-max data for the current variable
A = -diff(r,1,5)*2^-16; % Scale to maximum
B = r(:,:,:,:,1); % Add in minimum
val = A.*val + B;
toc

% I strongly suspect that the memory error occurs when we convert from
% integer to float. 




%% Save the files
if saveq
    tic
    % m = matfile([wdir varlist{i} '.' num '.mat']);
    % m.(varlist{i}) = data{i};
    save([wdir varname '.' num '.mat'],'val','-v7.3')
    toc
end

%% Compress, if desired
if compr > 1
    disp('Compressing values...')
    val = ccompress(val,compr);
    save([wdir varname '.' num '.compr.mat'],'val','-v7.3')
end
disp(['Done reading ' filename])
end

