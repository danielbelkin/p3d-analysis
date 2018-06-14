function crossings = zSection(Bfield, nsteps, npts)
% CROSSINGS = zSection(BX,BY,BZ,NSTEPS,NPTS)
% produces data for a Poincaré section of the magnetic field lines using an
% x-y plane at the midpoint of the z-axis. 
% CROSSINGS(2,10,4) is the Y coordinate of the 4th test point at the 10th
% crossing of the plane.
B = sum(Bfield.^2,4);
bfield = Bfield./B;

s = size(bfield);
zCut = s(3)/2; % The plain at which to cut

indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end


bz = bfield(:,:,:,3);
mbz = mean(bz(:)); % Average z-velocity

bfield = bfield(indx{:},:);

    function [value,isTerminal,direction] = isCross(~,y)
        value = mod(y(3),s(3)) - zCut;
        isTerminal = 1;
        direction = 0;
    end

f = @(~,x) [interp3(bfield(:,:,:,1), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,2), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,3), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1)];


tmax = 1e4*nsteps/s(3)/mbz; % Give it 1000 times longer than we expect it to need

options = odeset('Events',@isCross);

crossings = zeros(2,nsteps+1,npts);
parfor j = 1:npts % For each startpoint
    xc = [s(1)*rand s(2)*rand zCut]; % Choose initial point at random
    
    thisCrossings = zeros(2,nsteps+1); % Crossings for only this point
    thisCrossings(:,1) = xc(1:2);
    for i = 1:nsteps % Find the first n crossings
        [~,x,~,xc,~] = ode45(f,[0 tmax],xc,options); 
        if ~isempty(xc)
            thisCrossings(:,i+1) = [mod(xc(end,1),s(2)) + 1, mod(xc(end,2),s(2)) + 1];
            xc = xc(end,:);
        else
            thisCrossings(:,i+1) = NaN; % Should be very rare with divergenceless fields
            xc = x(end,:);
        end
    end
    crossings(:,:,j) = thisCrossings;
end
end
