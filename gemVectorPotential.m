function A = gemVectorPotential(J)
% Gem Challenge vector potential
% Uses image currents
s = size(J);
imJ = flip(J,2).*cat(5,-1,1,-1); % Invert Jx and Jz, reflect along y direction. 
Jtot = cat(2,J,imJ); % Combine to get total current
Atot = vectorPotential2(Jtot);
A = Atot(:,1:s(2),:,:,:); % Discard the reflected part
end