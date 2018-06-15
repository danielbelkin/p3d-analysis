function x = cconvn(x,h)
% X = cconv(X,H) circularly convolves an array X with a kernel h.
n = size(h,1);
indx = circExpand(size(x),(n-1)/2);
x = convn(x(indx{:}),h,'valid'); % This is bigger by 2 along each axis.
end