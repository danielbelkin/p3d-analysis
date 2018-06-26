function mu = ergodicMeasure(path,nvals,npts)
% MU = ergodicMeasure(PATH,[NX NY NZ],NPTS) estimates the ergodic measure
% associated with a path PATH through a triply-periodic box of size [NX NY
% NZ]. 
% Uses pathInterp to get a unit-speed path. NPTS is the number of sample
% points


%% Process inputs
if nargin < 3
    npts = prod(nvals(1:3)); % Default to one point per grid box
    % Should maybe make this more like 10?
    % idk, might not really matter.
end

% Handle inputs that came from fieldPlot.m:
if iscell(path)
    l = zeros(size(path));
    for i = 1:numel(path) % First pass: Just compute partial lengths.
        if size(path{i}) > 1
            [~,l(i)] = pathInterp(path{i},0);
        else
            l(i) = 0;
            path{i} = []; % Throw away this value. We can't use it.
        end
    end
    L = sum(l);
    for i = 1:numel(path) % Second pass: Do the interpolation.
        if l(i)
            n = poissrnd(l(i)/L);
            path{i} = pathInterp(path{i},n); 
        end
    end
    path = cell2mat(path(:));
else
    path = pathInterp(path,npts); 
end

nx = nvals(1);
ny = nvals(2);
nz = nvals(3);

% Make sure it's inside the box
path(:,1) = mod(path(:,1),nx);
path(:,2) = mod(path(:,2),ny);
path(:,3) = mod(path(:,3),nz);

if numel(path) == 0
    error('IDK, man')
end

%% Find the measure
I = uint16(0:nx-1);
J = uint16(0:ny-1);
K = uint16(0:nz-1);
[I,J,K] = meshgridn(I,J,K); 

mu = arrayfun(@(i,j,k) sum(i <= path(:,1) & path(:,1) < i+1 ...
                & j <= path(:,2) & path(:,2) < j+1 ...
                & k <= path(:,3)  & path(:,3) < k+1),I,J,K);
end