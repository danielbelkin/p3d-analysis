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
% conv(h(N),h(N)) = h(2N). I think this is currently not the case.
% If h(N) is gaussian with variance S2 and width W, then conv(h(N),h(N)) is
% gaussian with variance 2*S2 and width 2*W - 1.
% Require S2 = (cN)^2. Then 2*S2 = 2*c^2*N^2, and for h(2N) variance is
% (2cN)^2, so we want 2*c^2*N^2 = 4*c^2*N^2, which is not possible. 
% If S2 = c*N, then we have what we want. But this requires std =
% c*sqrt(N). This seems concerning.
% Also, we want 2*W(N) - 1 = W(2*N). If W(1) = 3, then W(2) = 5, W(4) = 9,
% W(8) = 17, W(16) = 33
% W(2^n) = 2*W(2^n-1) - 1
% W = 2z^-1 W - 1
% W = 1/(2z^-1 - 1)
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
indx = circExpand(s,(size(h,1) - 1)/2);

y = zeros([ceil(s/N) numel(T)]);
for t = T
    x(:,:,:,t) = convn(x(indx{:},t),h,'valid');
    y(:,:,:,t) = single(x(1:N:end,1:N:end,1:N:end)); % This way is faster.
end
end







