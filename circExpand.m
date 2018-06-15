function v = circExpand(x,m)
% Takes an array x and an integer m.
% Returns an array that is x padded with partial copies of itself out to a
% distance m. 
% Now works with arrays of arbitrary dimension.
% Also, will create a version that produces only indices for  matfile.

s = size(x);
d = numel(s);
indx = cell(1,d);
for i = 1:d
    indx{i} = [s(i)-m+1:s(i), 1:s(i), 1:m]; % This is some cleverness. I'm proud.
end
v = x(indx{:});
end