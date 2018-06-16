function y = ccompress(x,N,T)
% Y = ccompress(X,N) takes a 3-dimensional array X and downsamples it by a
% factor N along each dimension. 
% Default kernel is Gaussian with standard deviation N/2 and width 2*N + 1
% Returned array is single-precision.
%
% TODO: Conside making this parallelizeable.
% TODO: Add more options for the kernel, etc

if nargin < 3
        T = 1:size(x,4);
end
    
% Construct the kernel
h = normpdf(-N:N,0,N/2);
h = h.*reshape(h,[],1).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

% Expand the data
m = (size(h,1) - 1)/2;
s = size(x);
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = [s(d)-m+1:s(d), 1:s(d), 1:m];
end

y = zeros([ceil(s/N) numel(T)]);
for t = T
    x(:,:,:,t) = convn(x(indx{:},t),h,'valid');
    y(:,:,:,t) = single(x(1:N:end,1:N:end,1:N:end)); % This way is faster.
end
end







