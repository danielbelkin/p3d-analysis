function [lambda, stats] = bLyapunov(Bfield,isIn)
% [LAMBDA, STATS] = bLyapunov(BFIELD)
% Function to compute lyapunov exponents all in one go.
% Works quite quickly on compressed data; much too slow for raw data.
% Based on the assumption that the ergodic measure is unique. 
% BFIELD = cat(4,BX,BY,BZ) 
% This could be parallelized, but it's probably not worth it.
%
% [LAMBDA, STATS] = bLyapunov(BFIELD,isIn) allows you to add a logical isIn
% which specifies a region. Use ergodicMeasure to generate it. 
% 
% Stats contain: 
%   avgJ, the weighted average Jacobian
%   stdJ, the standard deviation of avgJ bmased on the (incorrect)
%         assumption that difference between every 18th pair of points is
%         iid
%   netB, the sum of abs(B) over the region
%   Lambda, the matrix from which lyapuonv exponents are calculated

disp('Running bLyapunov...')

if nargin < 2
    isIn = 1; % By default, include whole space
elseif any(isIn(:) > 1)
    isIn = isIn > 0; % Only use the logical. 
end

B = sqrt(sum(Bfield.^2,4));
bfield = Bfield./B; % Unit vector field
mu = B(:).*isIn(:); % Compute unnormalized measure
netB = sum(mu);
mu = mu/netB; % Normalize




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