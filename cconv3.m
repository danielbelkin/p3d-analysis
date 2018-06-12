function x = cconv3(x,h)
% X = cconv3(X,H) circularly convolves an array X with a 3-dimensional
% kernel H. H must be cubic with odd side length.
% 
% This function is fast for small kernels. For very large kernels, Fourier
% transform methods are more efficient.

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


% -------------------------------------------------------------------------

function v = circExpand(x,m)
% Takes an array x and an integer m.
% Returns an array that is x padded with partial copies of itself out to a
% distance m in 3 dimensions
v = zeros(size(x) + 2*m);

% Center
v(1+m:end-m, 1+m:end-m, 1+m:end-m) = x;

% Sides
v(1+m:end-m, 1+m:end-m, 1:m) = x(:, :, end-m+1:end);
v(1+m:end-m, 1+m:end-m, end-m+1:end) = x(:, :, 1:m);

v(1+m:end-m, 1:m, 1+m:end-m) = x(:, end-m+1:end, :);
v(1+m:end-m, end-m+1:end, 1+m:end-m) = x(:, 1:m, :);

v(1:m, 1+m:end-m, 1+m:end-m) = x(end-m+1:end, :, :);
v(end-m+1:end, 1+m:end-m, 1+m:end-m) = x(1:m, :, :);

% Edges
v(1:m, 1:m, 1+m:end-m) = x(end-m+1:end, end-m+1:end, :);
v(end-m+1:end, end-m+1:end, 1+m:end-m) = x(1:m, 1:m, :);

v(1:m, 1+m:end-m, 1:m) = x(end-m+1:end, :, end-m+1:end);
v(end-m+1:end, 1+m:end-m, end-m+1:end) = x(1:m, :, 1:m);

v(1+m:end-m, 1:m, 1:m) = x(:, end-m+1:end, end-m+1:end);
v(1+m:end-m, end-m+1:end, end-m+1:end) = x(:, 1:m, 1:m);

% More edges
v(1:m, end-m+1:end, 1+m:end-m) = x(end-m+1:end, 1:m, :);
v(end-m+1:end, 1:m, 1+m:end-m) = x(1:m, end-m+1:end, :);

v(1:m, 1+m:end-m, end-m+1:end) = x(end-m+1:end, :, 1:m);
v(end-m+1:end, 1+m:end-m, 1:m) = x(1:m, :, end-m+1:end);

v(1+m:end-m, 1:m, end-m+1:end) = x(:, end-m+1:end, 1:m);
v(1+m:end-m, end-m+1:end, 1:m) = x(:, 1:m, end-m+1:end);

% Corners
v(1:m, 1:m, 1:m) = x(end-m+1:end, end-m+1:end, end-m+1:end);
v(end-m+1:end, end-m+1:end, end-m+1:end) = x(1:m, 1:m, 1:m);

v(1:m, 1:m, end-m+1:end) = x(end-m+1:end, end-m+1:end, 1:m);
v(end-m+1:end, end-m+1:end, 1:m) = x(1:m, 1:m, end-m+1:end);

v(1:m, end-m+1:end, 1:m) = x(end-m+1:end, 1:m, end-m+1:end);
v(end-m+1:end, 1:m, end-m+1:end) = x(1:m, end-m+1:end, 1:m);

v(end-m+1:end, 1:m, 1:m) = x(1:m, end-m+1:end, end-m+1:end);
v(1:m, end-m+1:end, end-m+1:end) = x(end-m+1:end, 1:m, 1:m);
end