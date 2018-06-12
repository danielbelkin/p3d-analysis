function isEdge = edgeFind(vect)
% edgeFind is gonna try to identify cubes in which a vector field is zero. 
% It is unlikely to work well at first.
% vect is a cell array of vector elements.
% Actually, should probably make vect be a true vector field? Oh well.
%
% isEdge is of the same size as vect{i}, but is associated with the box
% located down and to the right, or something. 
%
% Might take some smoothing to make this work 
%
% This program will not fail gracefully at the moment - make sure all
% elements of vect are of the same dimensions. 

if ~iscell(vect)
    vect = {vect};
end

vect = reshape(vect{:},1,1,1,[]);

signChange = false([size(vect{1}) numel(vect)]); % Logical array
v = cell2mat(cellfun(@(x) circExpand(x,1),vect,'UniformOutput',false)); % Double array

for i = 1:size(v,1)
    for j = 1:size(v,2)
        for k = 1:size(v,3)
            for l = 1:size(v,4
                vals = v(i:i+1,j:j+1,k:k+1,l); % Get the eight corners
                signChange(i,j,k,l) = ~(abs(sum(sign(vals(:)))) == 8); % True if they're not all the same sign
            end
        end
    end
end

isEdge = all(signChange,4); % Count as an edge if all 4 elements are 0. 

end


% -------------------------------------------------------------------------

function v = circExpand(a,m)
% Takes an array x and an integer m.
% Returns an array that is x padded with partial copies of itself out to a
% distance m in 3 dimensions

x = 
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