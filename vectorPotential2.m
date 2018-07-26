function A = vectorPotential2(J)
% Gonna use fourier transform methods
% Take fft, multiply by 1./k^2, 
kx = reshape(0:size(J,1)-1,[],1,1);
ky = reshape(0:size(J,2)-1,1,[],1);
kz = reshape(0:size(J,3)-1,1,1,[]);

k2 = kx.^2 + ky.^2 + kz.^2;
k2(1) = 1; % Avoid the infinity (this is not the right way to do this)


H = 1./k2;
A = -real(ifftn(fftn(J).*H));

% J(k) = -k^2 A(k), I think
end

