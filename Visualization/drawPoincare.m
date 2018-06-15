function x = drawPoincare(bfield, npts, x0)
% x = drawPoincare(bfield, npts)
% Draws a poincare section at the midpoint of the z-plane with (very
% approximately) npts
%
% Idea: We should also fill in some points 

s = size(bfield);
if nargin < 3
    x0 = s(1:3).*rand(1,3);
end
zCut = s(3)/2; % The plain at which to cut

indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end


bz = bfield(:,:,:,3);
mbz = sum(bz(:)./abs(bz(:)))/sum(1./abs(bz(:))); % Average z-velocity
% Weighted by how much time you spend in the region, which is approximately 
% proportional to 1/abs(bz).


bfield = bfield(indx{:},:);

    function [value,isTerminal,direction] = isCross(~,y)
        value = mod(y(3),s(3)) - zCut;
        isTerminal = 0;
        direction = 0;
    end

% Define governing functin:
f = @(~,x) [interp3(bfield(:,:,:,1), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,2), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,3), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1)];


tmax = npts/s(3)/mbz; % Give it about as much time as we expect it to need
options = odeset('Events',@isCross);
[~,~,~,x,~] = ode45(f,[0 tmax],x0,options); % Runge-Kutta
end
