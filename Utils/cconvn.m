function x = cconvn(x,h)
% X = cconv(X,H) circularly convolves an array X with a kernel h.
% TODO: Make it operate along only the first 3 dimensions.
s = size(x);
n = size(h,1);
indx = circExpand(s(1:3),(n-1)/2);
T = prod(s(4:end));
for i=1:T
    x(:,:,:,T) = convn(x(indx{:},T),h,'valid'); % This is bigger by 2 along each axis.
end
end