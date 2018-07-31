function A = vectorPotential(J,m)
% A = vectorPotential(J,m)
% Obselete, use vectorPotential2
% Calculates a vector potential using Biot-Savart formula.
% Units are weird and arbitrary.
% TODO: Write a procedure to select m adaptively?
% Or at least compute an error statistic, based on how well curl(curl(A))
% lines up with J
% Note also that this integral will in general fail to converge unless
% total J is 0. 
% TODO: Consider using Fourier domain approach instead? Find fourier
% transform of H analytically, or do it numerically for a very large
% kernel, and then cut off high frequencies. 
n = 2*m + 1;

% Approximate kernel:
c = zeros(n,n,n,3);
[c(:,:,:,1),c(:,:,:,2),c(:,:,:,3)] = meshgridn(1:n,1:n,1:n);
h = 1./sqrt(sum((m+1 - c).^2, 4)); % Inverse distances

% More accurate kernel:
m0 = 2; % FREE PARAMETER
n0 = 2*m0 + 1;
[i,j,k] = meshgridn(1:n0,1:n0,1:n0);
hfun = @(x,y,z) integral3(@(a,b,c) ((a-x).^2 + (b-y).^2 + (c-z).^2).^(-1/2),-1,1,-1,1,-1,1);
h0 = arrayfun(hfun,i-m0-1,k-m0-1,j-m0-1)./8;
% Based on assuming J is uniformly distributed over box
% Equivalent to approximate kernel up to 1 part in 1000 for r > 3 or so.
% More accurate near the origin.

% Composite kernel:
h(m+1-m0:m+1+m0,m+1-m0:m+1+m0,m+1-m0:m+1+m0) = h0; % Insert the more accurate kernel in the center

A = cconvn(J,h);
% Next: Consider using faster convolution methods?
end