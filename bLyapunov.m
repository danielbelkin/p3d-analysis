function [lambda, stats] = bLyapunov(Bfield,measure)
% [LAMBDA, STATS] = bLyapunov(BFIELD)
% Function to compute lyapunov exponents all in one go.
% Works quite quickly on compressed data; much too slow for raw data.
% Based on the assumption that the ergodic measure is unique. 
% BFIELD = cat(4,BX,BY,BZ) 
% This could be parallelized, but it's probably not worth it.
%
% [LAMBDA, STATS] = bLyapunov(BFIELD,MEASURE) gives more control over the
% region used. If MEASURE is a logical, bLyapunov computes a based on B for
% only the region specified by MEASURE. If MEASURE is a numeric array, it
% is assumed to be proportional to the desired ergodic measure. 
% 
% Stats contain: 
%   avgJ, the weighted average Jacobian
%   stdJ, the standard deviation of avgJ bmased on the (incorrect)
%         assumption that difference between every 18th pair of points is
%         iid
%   netB, the sum of abs(B) over the region
%   Lambda, the matrix from which lyapuonv exponents are calculated

% okargs = {'isIn' 'mu'};
% defaults = {1 false};
% [isIn,mu] = parseArgs(okargs, defaults, varargin{:});

B = sqrt(sum(Bfield.^2,4));
bfield = Bfield./B; % Unit vector field

if nargin < 2
    mu = B(:); % Just use field
elseif islogical(measure)
    mu = B(:).*measure(:); % Treat it as isIn
else
    mu = measure(:); % Treat it as the measure
end

mu = mu/sum(mu); % Normalize
netB = sum(mu); % Be careful about interpretation


% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives 18 times the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3)); 

avgJ = zeros(3);
stdJ = avgJ;
for i = 1:3
    for j = 1:3
        Jij = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/18;
        avgJ(i,j) = sum(Jij(:).*mu); % The weighted average
        stdJ(i,j) = sqrt(sum(Jij(:).^2.*mu) - avgJ(i,j)^2);
    end
end

stdJ = stdJ/sqrt(numel(B))*sqrt(18); % Account for sample size
% Also account for the fact that only one in 18 measurements is
% independent, since gradient estimators overlap
Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); 
lambda = sort(eig(Lambda)); 
% We expect lambda to sum to zero. Is there any way to build this into our
% estimate?

if nargout == 2
    stats.Lambda = Lambda;
    stats.avgJ = avgJ;
    stats.stdJ = stdJ;
    stats.netB = netB;
end

disp('Done')
end