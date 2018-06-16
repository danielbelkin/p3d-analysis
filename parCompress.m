function y = parCompress(x,n,p,T)
% Y = parCompress(X,N,P)
% takes a 3-dimensional array X and downsamples it by a
% factor N along each dimension. It uses 2^P processors in parallel.
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% TODO: Add more options for the kernel, etc
% Add an option to specify the fieldname?

%% Process inputs
if ~isa(x,'matlab.io.MatFile')
    error('This function is inefficient with non-matfile inputs. Try ccompress')
elseif ~any(strcmp(fieldnames(x),'val'))
    error('Matfile must have a fieldname val')
    % Add an option to specify the fieldname?
end

s = size(x,'val');
if nargin < 3
    % Let's say we split until it's 65536 values by default
    p = max(0,log2(prod(s(1:3))) - 16);
    % TODO: Instead, use 
%     c = parcluster;
%     p = log2(c.NumWorkers);
end

if nargin < 4
    if size(s) == 4
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
sections = splitIndx(s(1:3),(size(h,1) - 1)/2, p); % Split the indices
frames = cell(1,1,1,numel(T));
disp('Splitting data...')
for t = T % For each frame requested
    sectResult = cell(size(sections));  % Holds the result from each section
    parfor i = 1:numel(sections)
        data = mfileIndx(x,sections{i},t);
        v = convn(data,h,'valid');
        sectResult{i} = single(v(1:n:end,1:n:end,1:n:end)); % And downsample
    end
    frames{t} = cell2mat(sectResult); % Combine sections to form a frame
    disp(['Frame ' num2str(t) ' of ' num2str(numel(T)) 'complete.'])
end
y = cell2mat(frames); % And combine all frames to form a movie.
end







