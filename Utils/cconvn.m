function x = cconvn(x,h)
% X = cconv(X,H) circularly convolves an array X with a kernel h.
% If H is N-dimensional and X is M-dimensional, then it operates along the
% first N dimensions of X.
% Every dimension of H must be an odd integer.

s = size(x);
n = size(h); 
d = length(n);

if any(~mod(n,2))
    error('Size of kernel must be odd along every dimension')
end

s(end+1:d) = 1; % Make sure s is at least as big as n
indx = circExpand(s(1:d),(n-1)/2); 
indx(d+1:length(s)) = {':'};

x = convn(x(indx{:}),h,'valid'); 

% T = prod(s(4:end));
% for i=1:T
%      out = convn(x(indx{:},i),h,'valid'); 
%      x(:,:,:,i) = out;
% end
end