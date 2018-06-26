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


indicator = @(x) sin(pi*(x./nvals)); % A zero of the indicator indicates a boundary crossing

%% Make sure there are no corner shots
% i.e. the path never crosses more than one wall in a single timestep. 
corners = find(sum(logical(diff(sign(indicator(path)))),2) > 1); % Find multiple crossings in one segment

for i = 1:numel(corners)
    % Add points to improve resolution around corner shots.
    smin = svals(corners(i));
    smax = svals(corners(i) + 1);
    s = mean([smin smax]); % Start in the middle
    k = 0; % Safety variable
    while k < 1000
        k = k+1;
        if all(indicator(pathfun(s)) == indicator(pathfun(smin)))
            s = mean([s smax]); % Move right
        elseif all(indicator(pathfun(s)) == indicator(pathfun(smax)))
            s = mean([s smin]); % Move left
        else
            break
        end
    end
    path = [path(1:corners(i),:); pathfun(s); path(corners(i)+1:end,:)]; % Append the new point
end

svals = [0; cumsum(sum(diff(path).^2,2))]; % Arc-length at each point

pathfun = @(s) [interp1(svals,path(:,1),s),...
    interp1(svals,path(:,2),s),...
    interp1(svals,path(:,3),s)];
% Redefine it to include new points.




%% Break path into sections
breaks = [1; find(any(diff(sign(indicator(path))),2)) + 1; size(path,1)]; % Identifies sign changes
% breaks(2) is the first point of segment 2
N = numel(breaks)-1; % Number of chunks to break into
boxmod = @(x) [mod(x(:,1),nvals(:,1)) mod(x(:,2),nvals(:,2)) mod(x(:,3),nvals(:,3))];

ds = .01; % Arbitrary, could maybe be as small as eps
y = cell(1,N);

% Better code: If a corner shot is detected, interpolate until it's
% resolved. TODO: Implement this. 

% Handle middle
for i = 1:N
    if i ~= 1
        s1 = fzero(@(s) prod(indicator(pathfun(s)),2),svals(breaks(i) + [-1 0])); % Find entry point
        x1 = pathfun(s1 + ds);
    else
        x1 = [];
    end
    if i ~= N        
        s2 = fzero(@(s) prod(indicator(pathfun(s)),2),svals(breaks(i + 1) + [-1 0])); % Find exit point        
        x2 = pathfun(s2 - ds);
    else
        x2 = [];
    end
    y{i} = boxmod([x1; path(breaks(i):breaks(i + 1) - 1,:); x2]); 
end

%% Plot the field
disp('Plotting...')
figure(1); clf; hold on;
whitebg('black')

for i = 1:N
    plot3(y{i}(1,1), y{i}(1,2), y{i}(1,3),'go')
    plot3(y{i}(end,1), y{i}(end,2), y{i}(end,3),'ro')
    plot3(y{i}(:,1), y{i}(:,2), y{i}(:,3),'-','Color',1-[i/N .5 1-i/N]);
end

grid on
xlabel('x'); ylabel('y'); zlabel('z')
xlim([0 nvals(1)]); ylim([0 nvals(2)]); zlim([0 nvals(3)])
ax = gca; ax.CameraPosition = [0 0 0];


% Old code, which doesn't handle corner shots correctly:
% if i ~= 1
%         s1 = fzero(@(s) indicator(pathfun(s)),svals(breaks(i) + [-1 0])); % Find entry point
%         x1 = pathfun(s1 + ds);
%     else
%         x1 = [];
%     end
%     if i ~= N        
%         s2 = fzero(@(s) indicator(pathfun(s)),svals(breaks(i + 1) + [-1 0])); % Find exit point        
%         x2 = pathfun(s2 - ds);
%     else
%         x2 = [];
%     end
