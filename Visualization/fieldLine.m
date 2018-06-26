function [x,x0] = fieldLine(bfield, d, x0)
% x = fieldLine(bfield, d, x0)
% Tracks magnetic field line starting at x0 for an approximate distance d.
% If x0 is not specified, a start point is chosen at random. 
% Not a unit-speed parameterization.
% Does not modulo it to be inside box.

s = size(bfield);
if nargin < 3
    x0 = s(1:3).*rand(1,3);
end

indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end

B = sqrt(sum(bfield.^2,4));
v = 1/mean(1./abs(B(:))); % Average velocity
tmax = d/v; 

bfield = bfield(indx{:},:); % Extend along one side (for interpolation)
interpFun = @(x,b) interp3(b,...
    mod(x(2),s(2))+1,mod(x(1),s(1))+1,mod(x(3),s(3))+1); % Interpolates mod s,

f = @(~,x) [interpFun(x,bfield(:,:,:,1));...
    interpFun(x,bfield(:,:,:,2));...
    interpFun(x,bfield(:,:,:,3))];

[~,x] = ode45(f,[0 tmax],x0);
end