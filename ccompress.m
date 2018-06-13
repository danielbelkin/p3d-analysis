function y = ccompress(x,N,varargin)
% Goal: Take an array x and a number N to downsample by.
% Compress every N by N by N cube of X into one point of y
% Want n to divide each dimension of x?
% For now, let's assume n is a power of two. 
% Default kernel is gaussian with standard deviation n/2 and width 2*n + 1, let's
% say. 
% And let's stick with single precision.
%
% Problem: This doesn't run efficiently on a matfile, which takes forever
% to load into memory.
% Options: Make it parallelizeable? Want to split it up by space. 
% Write a function to circExpand and also split up into a number of chunks


y = zeros(size(x)/N); 
h = normpdf(-N:N,0,N/2);
h = h.*reshape(h,1,[]).*reshape(h,1,1,[]); % Make the kernel 3d;
h = single(h); 
n = size(h,1); % We'll use this later. 

v = circExpand(x,N);
for i = 1:size(y,1)
    for j = 1:size(y,2)
        for k = 1:size(y,3)
            I = N*(i-1) + 1;
            J = N*(j-1) + 1;
            K = N*(k-1) + 1;
            vals = v(I:I+n-1,J:J+n-1,K:K+n-1).*h;
            y(i,j,k) = sum(vals(:));
        end
    end
end
end





