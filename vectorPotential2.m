function A = vectorPotential2(J)
% A = vectorPotential2(J)
% Uses fourier transform methods
% WARNING: Scale may be wrong.
% WARNING: I know it works component-wise. Haven't yet tested it on vector
% inputs. 
%
% But really, we want to be able to do this with vector currents. Need to
% check that it still works with the extra dimensions.


freqs = @(s) [0:floor(s/2) ceil(s/2)-1:-1:1]; % I think this is right

s = size(J);
[kx,ky,kz] = meshgridn(freqs(s(1)),freqs(s(2)),freqs(s(3)));

k2 = kx.^2 + ky.^2 + kz.^2;

H = 1./k2;
H(1) = 0; % Subtract off mean current, in effect
A = ifftn(fftn(J).*H);
end

