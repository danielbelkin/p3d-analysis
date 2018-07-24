function A = vectorPotential(J,m)
% Calculates a vector potential using Biot-Savart formula.
% Units are weird and arbitrary.
% TODO: Write a procedure to select m adaptively?
n = 2*m + 1;
c = zeros(n,n,n,3);
[c(:,:,:,1),c(:,:,:,2),c(:,:,:,3)] = meshgridn(1:n,1:n,1:n);
A = cconvn(J,1./sqrt(sum((m+1 - c).^2, 4)));

% d = sqrt((m+1 - i).^2 + (m+1 - j).^2 + (m+1 - k).^2); % Inverse distances
% h = 1./d; 
% A = cconvn(J,h);
end