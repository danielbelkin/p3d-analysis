function [y,x0] = fieldLine(bfield, d, x0)
% x = fieldLine(bfield, d, x0)
% Tracks magnetic field line starting at x0 for an approximate distance d.
% If x0 is not specified, a start point is chosen at random. 


s = size(bfield);
if nargin < 3
    x0 = s(1:3).*rand(1,3);
end


indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end

B = sqrt(sum(bfield.^2,4));
% bfield = bfield./B;
v = mean(B(:)); % Average velocity
tmax = d/v; 

bfield = bfield(indx{:},:); % Extend
f = @(~,x) [interp3(bfield(:,:,:,1), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,2), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,3), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1)];


[~,x] = ode45(f,[0 tmax],x0);
y(:,1) = mod(x(:,1),s(1));
y(:,2) = mod(x(:,2),s(2));
y(:,3) = mod(x(:,3),s(3));
end