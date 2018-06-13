function x = cconv3(x,h)
% X = cconv3(X,H) circularly convolves an array X with a 3-dimensional
% kernel H. H must be cubic with odd side length.
% 
% This function is fast for small kernels. For very large kernels, Fourier
% transform methods are more efficient.
%
% TODO: Modify this so that it's possible to downsample. Right now,
% returned array is always of the same size. Or make another function for
% downsampling.

n = size(h,1);
if length(size(x)) ~= 3 || length(size(h)) ~= 3
    error('X and H must be 3-dimensional')
elseif any(size(h) ~= n)
    error('Cubic kernels only')
elseif ~mod(n,2) % if n is even
    error('Kernel must have odd side length')
end

v = circExpand(x,(n-1)/2);
for i = 1:size(x,1)
    for j = 1:size(x,2)
        for k = 1:size(x,3)
            vals = v(i:i+n-1,j:j+n-1,k:k+n-1).*h;
            x(i,j,k) = sum(vals(:));
        end
    end
end
end