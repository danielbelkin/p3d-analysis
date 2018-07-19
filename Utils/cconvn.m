function x = cconvn(x,h)
% X = cconv(X,H) circularly convolves an array X with a kernel h.
% TODO: Make it operate along only the first 3 dimensions.
s = size(x);
n = size(h); % Want to make sure it's length 3
n(end+1:3) = 1;

indx = circExpand(s(1:3),(n-1)/2); % Want to be able to exand for a 
T = prod(s(4:end));
for i=1:T
    x(:,:,:,i) = convn(x(indx{:},i),h,'valid'); % This is bigger by 2 along each axis.
end
end