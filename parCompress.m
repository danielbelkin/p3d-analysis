function y = parCompress(file,n,p,T)
% Y = parCompress(FILE,N,P) takes a matfile FILE with field VAL and
% downsamples VAL by a factor N along each of the first three dimensions.
% It uses P processors in parallel. 
% It's best to start the parallel pool first, I think.
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% If P is not a power of two, then only 2^floor(log2(P)) processors will
% actually be used.
%
% TODO: 
% Change how trailing indices are handled - matfiles can't do it the way
% I'd like to. 
% Add more options for the kernel, etc
% Add smart decision-making about how many processors to use

%% Process inputs
if ~isa(file,'matlab.io.MatFile')
    error('This function is inefficient with non-matfile inputs. Try ccompress')
elseif ~any(strcmp(fieldnames(file),'val'))
    error('Matfile must have a fieldname val')
    % Add an option to specify the fieldname?
end

s = size(file,'val');
if nargin < 3
    % Let's say we split until it's 65536 values by default:
    % p = 2^max(0,log2(prod(s(1:3))) - 16);
    % TODO: Instead, use gcp or parcluster to find out how many workers are
    % available. 
    pp = parcluster;
    procs = pp.NumWorkers;
    p = 2^floor(log2(procs));
else
    p = 2^floor(log2(p)); % We only use a power-of-two number of processors
end

if isempty(gcp('nocreate'))
    parpool('local',p) % Start a parallel pool
end


if nargin < 4
    T = 1:s(4); % Timesteps to do
else
    % TODO: Something here.
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
disp('Splitting data...')
m = (size(h,1) - 1)/2; % Amount that we need chunks to overlap by
splits = getSplits(s(1:3),p); % Figure out how to split indices
template = cell(splits);
t0 = tic; % Set timer
parfor i = 1:p % For each processor 
    data = getSection(i,file,m,p); % Could instead get all available.
    v = zeros([ceil(s(1:3)./splits), numel(T)]);
    for t=T % For each frame
        v(:,:,:,t) = convn(data(:,:,:,t),h,'valid');
        disp(['Frame ' num2str(t) ' of ' num2str(numel(T)) 'complete.'])
        toc(t0)
    end
    template{i} = single(v(1:n:end,1:n:end,1:n:end,:)); % Downsample by throwing away most of the data.
    % This seems very inefficient, but convn is a very fast compiled C
    % function. I think the only way to get faster is to write my own C
    % function and compile it. 
end

y = cell2mat(template); % And combine all frames to form a movie.
end







