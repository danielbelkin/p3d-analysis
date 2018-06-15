function y = parCompress(x,n,p,T)
% Gonna write a parallel compression function
% idea: Each processor compresses one chunk of the data.
% Basically parconv, but returning only parts.
% Uses 2^p processors
% x should be a matfile?
%
% Y = ccompress(X,N) takes a 3-dimensional array X and downsamples it by a
% factor N along each dimension. 
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% TODO: Conside making this parallelizeable.
% TODO: Add more options for the kernel, etc

if ~isa(x,'matlab.io.MatFile')
    error('This function is inefficient with non-matfile inputs. Try ccompress')
elseif ~any(strcmp(fieldnames(x),'val'))
    error('Matfile must have a fieldname val')
    % TODO: Add an option to specify the fieldname?
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
    T = s(4); % Number of timesteps to do
end



% Construct the kernel
kernel = @(x) normpdf(x,0,n/2);
w = n; % Width = 2*w + 1, actually.
h = kernel(-w:w);
h = h.*reshape(h,1,[]).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

sections = splitIndx(s(1:3),(size(h,1) - 1)/2, p); % Split the indices
frames = cell(1,1,1,T);
for t=1:T % For each frame
    sectResult = cell(size(sections));  % Holds the result from each section
    disp('Splitting data...')
    parfor i = 1:numel(sections)
        v = convn(x.val(sections{i}{:},t),h,'valid');
        sectResult{i} = single(v(1:n:end,1:n:end,1:n:end)); % And downsample
    end
    disp('Recombining data...')
    frames{t} = cell2mat(sectResult); % Recombine results
end
y = cell2mat(frames); % And combine all frames to return.
end







