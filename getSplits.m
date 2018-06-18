function split = getSplits(s,p)
% Size is S, P processors available
% Split each dimension 
% This is a standalone function because it is often useful to be able to
% access it independently. 

n = floor(log2(p)); 
if n ~= 0 && any(mod(log2(s),1))
    error('Unlikely to work')
elseif 2^n > prod(s)
    error(['Cannot split ' num2str(prod(s)) ' elements into ' num2str(2^n) ' boxes.'])
end


split = ones(size(s));
for i = 1:n
    [~,j] = max(s./split);
    split(j) = split(j).*2;
end
end