function [lambda, Lambda, netB] = slowLyapunov(Bfield)
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

grad = cell(1,3);
grad{3} = cat(3,-ones(3),zeros(3),ones(3)); % Dz
grad{1} = shiftdim(grad{3},1); % Dx
grad{2} = shiftdim(grad{2},1); % Dy

tic
for i = 1:3
    for j = 1:3
        J = cconv3(Bfield(:,:,:,i),grad{j});
        netJ = sum(J./B(:));
        toc
    end
end

avgJ = netJ/netB; % This is allowed because infintesimal matrices commute
Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); % But non-infintesimal matrices don't.
lambda = sort(eig(Lambda)); 
disp('Done')
end





