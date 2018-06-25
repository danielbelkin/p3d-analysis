function y = ccompress(x,N,varargin)
% Y = ccompress(X,N) takes an array X and downsamples it by a
% factor N along each of the first 3 dimensions. 
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
% TODO: Make sure kernel is well-behaved under composition. Want
% conv(h(N),h(N)) = h(2N). This requires H(N) = normpdf(-N:N,0,C*sqrt(N))
% for some C. Seems like for any C, you eventually get bad behavior. 
% TODO: Change the way trailing indices are handled. 

s = size(x);
if nargin < 3
    T = 1:prod(s(4:end));
else
    T = sub2ind(s(4:end),varargin{:}); % Use linear indexing over the last few dimensions    
end
    
% Construct the kernel
h = normpdf(-N:N,0,N/2);
% h = normpdf
h = h.*reshape(h,[],1).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

% Expand the data
dim = numel(s);
s(dim + 1:3) = 1; % Extend to look 3d
indx = circExpand(s(1:3),(size(h,1) - 1)/2); 

y = zeros([ceil(s(1:3)/N) numel(T)]);
for t = T
     out = convn(x(indx{:},t),h,'valid');
     x(:,:,:,t) = out;
    y(:,:,:,t) = single(x(1:N:end,1:N:end,1:N:end,t)); % This way is faster.
end
end







