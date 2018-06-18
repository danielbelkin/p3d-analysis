function y = ccompress(x,N,varargin)
% Y = ccompress(X,N) takes a 3-dimensional array X and downsamples it by a
% factor N along each dimension. 
% If X has more than 3 dimensions, this happens only along the first three
% dimensions.
% The default kernel is Gaussian with standard deviation N/2 and width 
% 2*N + 1 
% The array returned is single-precision.
% Y = ccompress(X,N,I1...In) compresses an n-dimensional array along
% indices given by I1...In. For this function, I1...In must be vectors of
% indices, all of equal length. Be careful about how you use this feature.
% In
%
% For very large datasets, use parCompress.
%
% TODO: Add more options for the kernel, etc
% TODO: Change the way trailing indices are handled. Make it match
% parCompress, so that they're treated only linearly. 
s = size(x);
if nargin < 3
    T = 1:prod(s(4:end));
else
    T = sub2ind(s(4:end),varargin{:}); % Use linear indexing over the last few dimensions    
end
    
% Construct the kernel
h = normpdf(-N:N,0,N/2);
h = h.*reshape(h,[],1).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

% Expand the data
m = (size(h,1) - 1)/2;
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = [s(d)-m+1:s(d), 1:s(d), 1:m];
end

y = zeros([ceil(s/N) numel(T)]);
for t = T
    x(:,:,:,t) = convn(x(indx{:},t),h,'valid');
    y(:,:,:,t) = single(x(1:N:end,1:N:end,1:N:end)); % This way is faster.
end
end







