function y = ccompress(x,N,varargin)
% Goal: Take an array x and a number N to downsample by.
% Compress every N by N by N cube of X into one point of y
% Default kernel is gaussian with standard deviation n/2 and width 2*n + 1
% And let's stick with single precision.
%
% TODO: Conside making this parallelizeable.
% TODO: Add more options for the kernel, etc

h = normpdf(-N:N,0,N/2);
h = h.*reshape(h,1,[]).*reshape(h,1,1,[]); % Make it 3d;
h = single(h); % Keep the precision low

% Expand:
m = size(h,1);
s = size(x);
dim = numel(s);
indx = cell(1,dim);
for d = 1:dim
    indx{d} = [s(d)-m+1:s(d), 1:s(d), 1:m];
end

x = convn(x(indx{:}),h,'valid');
y = x(1:N:end,1:N:end,1:N:end);
end







