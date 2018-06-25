function [x,L] = pathInterp(path,varargin)
% takes an arbitrary path through 3-space and upsamples it so that it has n
% evenly-distributed points.
% Could also have points be distributed randomly along the path. Not sure
% which is better. 
% Could also specify distance instead of 

if nargin < 2
    n = 10*length(path);
end

svals = [0; cumsum(sum(diff(path).^2,2))]; % Arc-length at each point
pathfun = @(s) [interp1(svals,path(:,1),s),...
    interp1(svals,path(:,2),s),...
    interp1(svals,path(:,3),s)];

% s = (0:d:svals(end))';
L = svals(end);
s = linspace(0,L,n);
x = pathfun(s); % Deterministic version - probably good.
end




