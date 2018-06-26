function y = plotLine(path,nvals)
% Plots a single fieldline.
% Like fieldPlot, but should hopefully run faster.
% Plan: Take a fieldline
% Identify all events (crossings of the boundaries)
% Break along those, using linear interpolation to identify endpoints
% Plot it

%% Construct path function by interpolation
path = double(path);
svals = [0; cumsum(sum(diff(path).^2,2))]; % Arc-length at each point

pathfun = @(s) [interp1(svals,path(:,1),s),...
    interp1(svals,path(:,2),s),...
    interp1(svals,path(:,3),s)];

%% Break path into sections
indicator = @(x) prod(x.*(nvals - x),2); % A zero of the indicator indicates a boundary crossing
breaks = [0 find(diff(sign(indicator(path)))) size(path,1)]; % Identifies sign changes
% breaks(2) is the last point of segment 1
nchunks = numel(breaks)-1;

boxmod = @(x) [mod(x(:,1),nvals(:,1)) mod(x(:,2),nvals(:,2)) mod(x(:,3),nvals(:,3))];

ds = .01; % Arbitrary, could maybe be as small as eps
y = cell(1,nchunks);
for i = 1:nchunks
    s1 = fzero(@(s) indicator(pathfun(s-svals(breaks(i)))),[0 1]); % Find entry point
    s2 = fzero(@(s) indicator(pathfun(s-svals(breaks(i + 1)))), [0 1]); % Find exit point
    y{i} = boxmod([pathfun(s1 + ds); % Entry point
        path(breaks(i) + 1:breaks(i + 1),:); % Path
        pathfun(s2 - ds)]); % Exit point
end

%% Plot the field
disp('Plotting...')
figure(1); clf; hold on;
whitebg('black')

for i = 1:nchunks
    plot3(y{i}(1,1), y{i}(1,2), y{i}(1,3),'go')
    plot3(y{i}(end,1), y{i}(end,2), y{i}(end,3),'ro')
    plot3(y{i}(:,1), y{i}(:,2), y{i}(:,3),'-','Color',1-[i/n .5 1-i/n]);
end

grid on
xlabel('x'); ylabel('y'); zlabel('z')
xlim([0 s(1)]); ylim([0 s(2)]); zlim([0 s(3)])
ax = gca; ax.CameraPosition = [0 0 0];
