function fieldSection(lines,nvals)
% fieldSection(lines,nvals)
% Just uses the intersections with the edges
% Could be made faster by writing a special function instead of plotLine

if ~iscell(lines)
    lines = {lines};
end

% Function to detect boundary crossings:
isCross = @(x) sin(pi*x(:,3)/nvals(3)); % TODO: Make this an optional argument

% Function to keep a path inside the box:
boxmod = @(x) [mod(x(:,1),nvals(1)) mod(x(:,2),nvals(2)) mod(x(:,3),nvals(3))];


xc = cell(numel(lines),1);
for i = 1:numel(lines)
    xc{i} = boxmod(findCross(lines{i},isCross)); % Break into sections
end

cfun = @(x0) sin(pi*x0./nvals).^2; % TODO: Make this an optional argument

figure(1); clf; hold on
for i = 1:numel(lines)
    plot(xc{i}(:,1),xc{i}(:,2),'.','Color',cfun(xc{i}(1,:)))
end
end




function y = findCross(path,isCross)
% Function to find crossings

path = double(path);
svals = [0; cumsum(sum(diff(path).^2,2))]; % Arc-length at each point

% Construct parametric path by interpolation:
pathfun = @(s) [interp1(svals,path(:,1),s),...
    interp1(svals,path(:,2),s),...
    interp1(svals,path(:,3),s)];

%% Break path into sections
breaks = [1; find(diff(sign(isCross(path)))) + 1; size(path,1)]; % Identifies sign changes
N = numel(breaks)-1; % Number of chunks to break into


% Pin down crossings
scross = zeros(N-1,1);
for i = 1:N-1
    scross(i) = fzero(@(s) isCross(pathfun(s)),svals(breaks(i+1) + [-1 0]));
end

y = pathfun(scross); % All it takes, right?
end