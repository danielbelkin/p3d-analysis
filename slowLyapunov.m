function [lambda, stats] = slowLyapunov(Bfield)
% Function to compute lyapunov exponents all in one go.
% Almost certainly extremely slow for large datasets.
% BFIELD = cat(4,bx,by,bz)
% vect should be an array of matfiles?
% With .val fields
% No, just let vect be numbers. 
% 
% 
% Based on the assumption that the ergodic measure is unique. 
% TODO: Make it possible for bx, by, bz to be matfiles? 
disp('Running slowLyapunov...')
tic;
B = sqrt(sum(Bfield.^2,4));
netB = sum(B(:));

% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives twice the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3));

netJ = zeros(3);
netJ2 = netJ;
tic
for i = 1:3
    for j = 1:3
        J = cconv3(Bfield(:,:,:,i),grad(:,:,:,j))/2; % Something wrong here
        netJ(i,j) = sum(J(:).*B(:));
        netJ2(i,j) = netJ(i,j).^2;
        toc
    end
end

avgJ = netJ/netB; % This is allowed because infintesimal matrices commute
stdJ = sqrt(netJ2 - netJ.^2)/netB;
Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); % But non-infintesimal matrices don't.
lambda = sort(eig(Lambda)); 

if nargout == 2
    stats.Lambda = Lambda;
    stats.avgJ = avgJ;
    stats.stdJ = stdJ;
    stats.netB = netB;
end
disp('Done')
end





