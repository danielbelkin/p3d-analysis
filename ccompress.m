function y = ccompress(x,N)
% Y = ccompress(X,N) takes a 3-dimensional array X and downsamples it by a
% factor N along each dimension. 
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% TODO: Conside making this parallelizeable.
% TODO: Add more options for the kernel, etc

% Construct the kernel
h = normpdf(-N:N,0,N/2);
h = h.*reshape(h,1,[]).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

% Expand the data
m = size(h,1);
s = size(x);
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = [s(d)-m+1:s(d), 1:s(d), 1:m];
end

x = convn(x(indx{:}),h,'valid');
y = single(x(1:N:end,1:N:end,1:N:end)); % This way is faster.
end







