function indx = circExpand(s,m)
% Takes a size s and an integer m.
% Returns a cell array such that x(indx{:}) is expanded.
% if m is a vector of same length as s, then each element is used.

m = m + zeros(size(s)); % Expand to same size as s
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = mod([s(d)-m(d)+1:s(d), 1:s(d), 1:m(d)] - 1, s(d)) + 1;
end
end