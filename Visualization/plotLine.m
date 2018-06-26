function y = plotLine(path,nvals)
% Plots a single fieldline.
% Like fieldPlot, but should hopefully run faster.
% Plan: Take a fieldline
% Identify all events (crossings of the boundaries)
% Break along those, using linear interpolation to identify endpoints
% Plot it

%% Define some functions
path = double(path);
svals = [0; cumsum(sum(diff(path).^2,2))]; % Arc-length at each point

% Construct path by interpolation:
pathfun = @(s) [interp1(svals,path(:,1),s),...
    interp1(svals,path(:,2),s),...
    interp1(svals,path(:,3),s)];

% Function to detect boundary crossings:
isCross = @(x) sin(pi*(x./nvals)); 

% Modulo in a 3D box:
boxmod = @(x) [mod(x(:,1),nvals(:,1)) mod(x(:,2),nvals(:,2)) mod(x(:,3),nvals(:,3))];

%% Make sure there are no corner shots
% i.e. the path never crosses more than one wall in a single timestep. 
corners = find(sum(logical(diff(sign(isCross(path)))),2) == 2); % Find multiple crossings in one segment

for i = 1:numel(corners)
    % Add points to improve resolution around corner shots.
    smin = svals(corners(i));
    smax = svals(corners(i) + 1);
    s = mean([smin smax]); % Start in the middle
    k = 0; % Safety variable
    while 1
        if all(sign(isCross(pathfun(s))) == sign(isCross(pathfun(smin))))
            s = mean([s smax]); % Move right
        elseif all(sign(isCross(pathfun(s))) == sign(isCross(pathfun(smax))))
            s = mean([s smin]); % Move left
        else
            break
        end
        k = k+1;
        if k > 1e3
            error('Corner resolution is taking too long')            
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
breaks = [1; find(any(diff(sign(isCross(path))),2)) + 1; size(path,1)]; % Identifies sign changes
% breaks(2) is the first point of segment 2
N = numel(breaks)-1; % Number of chunks to break into

ds = .01; % Arbitrary, should be <<1
y = cell(1,N);

% Pin down crossings
scross = zeros(1,N-1);
for i = 1:N-1
    try
        scross(i) = fzero(@(s) prod(isCross(pathfun(s)),2),svals(breaks(i+1) + [-1 0]));
    catch me
        i
        breaks(i+1)
        svals(breaks(i+1) + [-1 0])
        pathfun(svals(breaks(i+1) + [-1 0]))
        throw(me)
    end
end

% Actually split
for i = 1:N
    if i ~= 1
        x1 = pathfun(scross(i-1) + ds);
    else
        x1 = [];
    end
    
    if i ~= N        
        x2 = pathfun(scross(i) - ds);
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
