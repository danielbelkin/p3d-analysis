function mu = ergodicMeasure(path,nvals,npts)
% MU = ergodicMeasure(PATH,[NX NY NZ],NPTS) estimates the ergodic measure
% associated with a path PATH through a triply-periodic box of size [NX NY
% NZ]. 
% Uses pathInterp to get a unit-speed path. NPTS is the number of sample
% points
%
% I suspect this will work best with extremely downsampled data, but we'll
% see. 
%
% You should probably do some smoothing afterwards too. This is basically
% KDE at that point.


%% Process inputs
if numel(nvals) ~= 3
    error('Nvals should be [nx ny nz]')
end

if nargin < 3
    npts = prod(nvals); % Default to one point per grid box
    % Should really make this decision based on arc length. Want about .1
    % or so. 
end

% Handle inputs that came from fieldPlot.m:
if iscell(path)
    lindx = zeros(size(path));
    for i = 1:numel(path) % First pass: Just compute partial lengths.
        if size(path{i}) > 1
            [~,lindx(i)] = pathInterp(path{i},0);
        else
            lindx(i) = 0;
            path{i} = []; % Throw away this value. We can't use it.
        end
    end
    L = sum(lindx);
    count = 0;
    for i = 1:numel(path) % Second pass: Do the interpolation.
        if lindx(i)
            n = poissrnd(npts*lindx(i)/L);
            path{i} = pathInterp(path{i},n); 
            count = count + n;
        end
    end
    npts = count; % This is how many points we actually have
    path = cell2mat(path(:));
else
    path = pathInterp(path,npts); 
end

if numel(path) == 0
    error('Too few points?')
end

nx = nvals(1);
ny = nvals(2);
nz = nvals(3);

% Make sure it's an integer inside the box
x = floor(mod(path(:,1),nx)) + 1;
y = floor(mod(path(:,2),ny)) + 1;
z = floor(mod(path(:,3),nz)) + 1;

%% Find the measure
mu = zeros(nvals);
for i = 1:size(path,1)
    mu(x(i),y(i),z(i)) = mu(x(i),y(i),z(i)) + 1; % This way is asymptotically fastest. 
end

% lindx = sub2ind(nvals,x,y,z); % Linear indices
% mu(lindx) = 1; % Faster if you only want a binary decision
% mu(lindx) = sum(lindx == lindx'); % Faster for small datasets
% Consider using discretize instead?

end