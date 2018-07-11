function xc = fieldSection(lines,nvals)
% fieldSection(lines,nvals)
% TODO: Add optional arguments for:
%   isCross function handle
%   cfun function handle
%   figure to plot to
% TODO: Add parallelization?

if ~iscell(lines)
    lines = {lines};
end

isCross = @(x) sin(pi*x(:,3)/nvals(3)); % Detects boundary crossings


% Function to keep a path inside the box:
boxmod = @(x) [mod(x(:,1),nvals(1)) mod(x(:,2),nvals(2)) mod(x(:,3),nvals(3))];

try 
    gcp
    xc = cell(numel(lines),1);
    parfor i = 1:numel(lines)
        xc{i} = boxmod(findCross(lines{i},isCross)); % Break into sections
    end
catch
    xc = cellfun(@(x) boxmod(findCross(x,isCross)), lines,'UniformOutput',false);
end

% cfun = @(x0) sin(pi*x0./nvals).^2; % Determines color pattern
x0 = cellfun(@(x) x(1,:),xc);
cfun = @(x) (x - min(x0))./(max(x0) - min(x0)); % Linear 

figure(1); clf; hold on
for i = 1:numel(lines)
    plot(xc{i}(:,1),xc{i}(:,2),'.','Color',cfun(xc{i}(1,:)))
end
end


function y = findCross(path,isCross)
% Function to find crossings

path = double(path); % Make sure it's a double
% Parameterize the curve by an arbitrary scalar s:
pathfun = @(s) [interp1(path(:,1),s),...
    interp1(path(:,2),s),...
    interp1(path(:,3),s)];

%% Break path into sections
breaks = [1; find(diff(sign(isCross(path)))) + 1; size(path,1)]; % Identify intervals in which isCross changes sign
scross = arrayfun(@(i) fzero(@(s) isCross(pathfun(s)),[i-1 i]),breaks(2:end-1)); % Find the s-value of the zero
y = pathfun(scross); % Convert s back into cartesian coordinates
end