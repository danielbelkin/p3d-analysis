function x = fieldPlot(bfield, n, x0)
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
v = mean(B(:)); % Average velocity
% bfield = bfield./B;
% v = 1;
tmax = 1e3*max(size(bfield))/v; 

bfield = bfield(indx{:},:); % Extend
interpFun = @(x,b) interp3(b,...
    mod(x(2),s(2))+1,mod(x(1),s(1))+1,mod(x(3),s(3))+1); % Interpolates mod s,
% MIGHT BE WRONG for weird reasons

f = @(~,x) [interpFun(x,bfield(:,:,:,1));...
    interpFun(x,bfield(:,:,:,2));...
    interpFun(x,bfield(:,:,:,3))];


    function [value,isTerminal,direction] = isCross(~,y)
        value = y'.*(s(1:3) - y'); % Is negative as soon as we leave box
        isTerminal = [1 1 1];
        direction = [0 0 0];
    end
        
options = odeset('Events',@isCross); % Set ODE options
x = cell(1,n);

for i = 1:n
    [~,x{i}] = ode45(f,[0 tmax],x0,options);
    x0 = x{i}(end,:);
    x0(x0 == 0) = -eps(0); % To ensure proper modulation
    x0 = [mod(x0(1),s(1)); mod(x0(2),s(2)); mod(x0(3),s(3))]; % startpoint for next cycle
end

disp('Plotting...')
figure(1); clf; hold on;
% plot3(x0(1),x0(2),x0(3),'go'); 
whitebg('black')

for i = 1:n
    plot3(x{i}(1,1), x{i}(1,2), x{i}(1,3),'go')
    plot3(x{i}(end,1), x{i}(end,2), x{i}(end,3),'ro')
    plot3(x{i}(:,1), x{i}(:,2), x{i}(:,3),'-','Color',1-[i/n .5 1-i/n]);
end

grid on
xlabel('x'); ylabel('y'); zlabel('z')
xlim([0 s(1)]); ylim([0 s(2)]); zlim([0 s(3)])
ax = gca; ax.CameraPosition = [0 1 2];
end