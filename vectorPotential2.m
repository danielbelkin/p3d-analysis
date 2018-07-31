function A = vectorPotential2(J)
% A = vectorPotential2(J)
% Uses fourier transform methods
% Scale is now correct.
% WARNING: I know it works component-wise. Haven't yet tested it on vector
% inputs. 
%
% But really, we want to be able to do this with vector currents. Need to
% check that it still works with the extra dimensions.


freqs = @(s) 2*pi/s*[0:floor(s/2) ceil(s/2)-1:-1:1]; % I think this is right
% Should have dimensions of (per space). 
% Assume grid-units are equal sizes, 1:L:Si
% Kmax = 2./L
% Kmin = 0. 
% So I think these are reasonable, since we've set L=1. 
% But in practice, they tend to be wrong by some factor. 


s = size(J);
s(end+1:3) = 1; % Make sure it's at least 3D
[kx,ky,kz] = meshgridn(freqs(s(1)),freqs(s(2)),freqs(s(3)));

k2 = kx.^2 + ky.^2 + kz.^2;

H = 1./k2;
H(1) = 0; % Subtract off mean current, in effect
A = ifftn(fftn(J).*H);
end

