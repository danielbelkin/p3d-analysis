function [lambda, stats] = slowLyapunov(Bfield)
% [LAMBDA, STATS] = slowLyapunov(BFIELD)
% Function to compute lyapunov exponents all in one go.
% Almost certainly extremely slow for large datasets.
% BFIELD = cat(4,BX,BY,BZ)
% No, just let vect be numbers. 
% 
% 
% Based on the assumption that the ergodic measure is unique. 
% Actually not that slow with compressed data.
disp('Running slowLyapunov...')
tic;
B = sqrt(sum(Bfield.^2,4));
netB = sum(B(:));
bfield = Bfield./B;

% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives twice the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3));

avgJ = zeros(3);
stdJ = avgJ;
tic
for i = 1:3
    for j = 1:3
        Jij = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/2; % WRONG, want gradB.
        avgJ(i,j) = sum(Jij(:).*B(:))./netB; % The weighted average
        stdJ(i,j) = sqrt(sum(Jij(:).^2.*B(:))./netB - avgJ(i,j)^2);
        toc
    end
end

stdJ = stdJ/sqrt(numel(B))*sqrt(numel(d)); % Account for sample size
% Also account for the fact that only one in 27 measurements is independent
Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); 
lambda = sort(eig(Lambda)); 

if nargout == 2
    stats.Lambda = Lambda;
    stats.avgJ = avgJ;
    stats.stdJ = stdJ;
    stats.netB = netB;
end
disp('Done')
end