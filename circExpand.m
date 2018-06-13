function v = circExpand(x,m)
% Takes an array x and an integer m.
% Returns an array that is x padded with partial copies of itself out to a
% distance m. 
% I think x need not be cubic?

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