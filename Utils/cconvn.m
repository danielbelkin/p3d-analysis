function x = cconvn(x,h)
% X = cconv(X,H) circularly convolves an array X with a kernel h.
% If H is N-dimensional and X is M-dimensional, then it operates along the
% first N dimensions of X.
% H must be no larger than X in every dimension.
s = size(x);
n = size(h); % Want to make sure it's at least length 3?
d = length(size(h));

indx = circExpand(s(1:d),(n-1)/2); 
size(indx)
indx(d+1:length(s)) = {':'};

x = convn(x(indx{:}),h,'valid');

% T = prod(s(4:end));
% for i=1:T
%     x(:,:,:,i) = convn(x(indx{:},i),h,'valid'); 
% end
end