function [x,x0] = fieldPlot(bfield, n, x0)
% x = fieldLine(bfield, n, x0)
% Tracks magnetic field line starting at x0 for n boundary-crossings.

s = size(bfield);
if nargin < 3
    x0 = s(1:3).*rand(1,3);
end


indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end

B = sqrt(sum(bfield.^2,4));
% v = mean(B(:)); % Average velocity
bfield = bfield./B;
v = 1;
tmax = max(size(bfield))/v; 

bfield = bfield(indx{:},:); % Extend
f = @(~,x) [interp3(bfield(:,:,:,1), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,2), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1); ...
            interp3(bfield(:,:,:,3), mod(x(1),s(1))+1,mod(x(2),s(2))+1,mod(x(3),s(3))+1)];


    function [value,isTerminal,direction] = isCross(~,y)
        value = prod(y).*prod(s(1:3) - y');
        % value = 0
        % This function doesn't work - why not?
        % Something about isTerminal?
        % Need to look at ode45 examples
        isTerminal = 1;
        direction = 0;
    end
        
        
        
options = odeset('Events',@isCross);
x = cell(1,n);
figure(1); clf; hold on;
for i = 1:n
    [~,x{i}] = ode45(f,[0 tmax],x0,options);
    x0 = [mod(x{i}(end,1),s(1)); mod(x{i}(end,2),s(2)); mod(x{i}(end,3),s(3))]; % startpoint for next cycle
    plot3(x{i}(:,1), x{i}(:,2), x{i}(:,3),'-','Color',[i/n .5 1-i/n]);
end
grid on
whitebg('black')
end