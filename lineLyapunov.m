function lambda = lineLyapunov(path,Bfield)
% lambda = lineLyapunov(path,Bfield)
% Basically just a shell function because I realized it's easier to use
% bLyapunov

s = size(Bfield);
mu = ergodicMeasure(path,s(1:3));
lambda = bLyapunov(Bfield,mu); 
end