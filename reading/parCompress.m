function val = parCompress(file,n,p,T,varargin)
% Y = parCompress(FILE,N,P) takes a matfile FILE with field VAL and
% downsamples VAL by a factor N along each of the first three dimensions.
% It uses P processors in parallel. 
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% If P is not a power of two, then only 2^floor(log2(P)) processors will
% actually be used.
% With 16 processors and a 2048x1024x512 dataset, this takes about a minute
% to run.
%
% parCompress(file,n,p,T,'NAME',VALUE) allows you to specify a few more
% things.
% T can be ':' or a vector of time values. This downsamples the array along
% the 4th dimension (without smoothing)
%
%
% Optional name-value pairs: 
% 'fieldname' = val      Name of the field on FILE to look at
% 'saveas' = false       Filename to save result under
% 
%
% TODO: 
% Change how trailing indices are handled - matfiles can't do it the way
% I'd like to. Consider requiring that we always compress frame-by-frame.
% For any dataset large enough to require parallelization, it's probably
% more efficient.
% Add more options for the kernel, etc
% Add smart decision-making about how many processors to use
% 

%% Process inputs

okargs = {'fieldname' 'saveas'};
dflts = {'val' false};
[field,saveas] = parseArgs(okargs,dflts,varargin{:}); 

if ~isa(file,'matlab.io.MatFile')
    error('This function is inefficient with non-matfile inputs. Try ccompress')
elseif ~any(strcmp(fieldnames(file),field))
    disp('Is this the file you intended to compress?')
    disp(file)
    error(['Matfile must have a field named ' field])
end

s = size(file,field);
dim = numel(s);
s(dim + 1:3) = 1; % Pad with ones if needed

if nargin < 3
    pp = parcluster;
    procs = pp.NumWorkers;
    p = 2^floor(log2(procs));
else
    p = 2^floor(log2(p)); % We only use a power-of-two number of processors
end

if isempty(gcp('nocreate'))
    parpool('local',p) % Start a parallel pool
end


if nargin < 4 || strcmp(T,':')
    if dim > 3
        T = 1:s(4); % Timesteps to do
    else
        T = 1;
    end
end

    



%% Construct the kernel
kernel = @(x) normpdf(x,0,n/2);
w = n; % Width = 2*w + 1, actually.
h = kernel(-w:w);
h = h.*reshape(h,[],1).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low
h = h./sum(h(:)); % Renormalize
% Consider making this a function instead of a broadcast variable?


%% Convolve
% disp('Splitting data...')
m = (size(h,1) - 1)/2; % Amount that we need chunks to overlap by
splits = getSplits(s(1:3),p); % Figure out how to split indices
template = cell(splits);
parfor i = 1:p % For each processor 
    data = getSection(i,file,field,m,p); 
    v = zeros([ceil(s(1:3)./splits), numel(T)]);
    for t = T % For each frame
        v(:,:,:,t) = convn(data(:,:,:,t),h,'valid');
        % disp(['Frame ' num2str(t) ' of ' num2str(numel(T)) ' complete.'])
    end
    template{i} = single(v(1:n:end,1:n:end,1:n:end,:)); % Downsample by throwing away most of the data.
    % This seems very inefficient, but convn is a very fast compiled C
    % function. I think the only way to get faster is to write my own C
    % function and compile it. 
end

val = cell2mat(template); % And combine all frames to form a movie.

if saveas
    save(saveas,'val','-v7.3')
    % TODO: Add an info field
end

end







