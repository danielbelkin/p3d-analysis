function indx = circExpand(s,m)
% Takes a size s and an integer m.
% Returns a cell array such that x
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = mod([s(d)-m+1:s(d), 1:s(d), 1:m] - 1, s(d)) + 1;
end
end