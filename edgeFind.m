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

% PROBLEM: Useless.

if ~iscell(vect)
    vect = {vect};
end

vect = reshape(vect(:),1,1,1,[]);

signChange = false([size(vect{1}) numel(vect)]); % Logical array
v = cell2mat(cellfun(@(x) circExpand(x,1),vect,'UniformOutput',false)); % Double array

for i = 1:size(signChange,1)
    for j = 1:size(signChange,2)
        for k = 1:size(signChange,3)
            for l = 1:size(signChange,4)
                vals = v(i:i+1,j:j+1,k:k+1,l); % Get the eight corners
                signChange(i,j,k,l) = ~(abs(sum(sign(vals(:)))) == 8); % True if they're not all the same sign
            end
        end
    end
end

isEdge = all(signChange,4); % Count as an edge if all 4 elements are 0. 

end