function S = magneticEntropy(ve,vi,ne,ni,me,mi)
% TODO: Check units on energies, canonical momentum in Gaussian formulation
% TODO: Find out what n should be to get an accurate vector potential
% Could write something fancy with an adaptive kernel size
jfield = ni.*vi - ne.*ve;
afield = vectorPotential(jfield,20); % I have no clue what an appropriate m is.
disp('Using n = 20')
% Might want to write a version that does fourier-space circular
% convolution instead.
% or a version of paralell convolution optimized for large kernels?

pe = me*ve - afield; % Assuming q = -1. 
pi = mi*vi + afield; % q = 1

Ne = sum(ne(:));
Ni = sum(ni(:));

KE = 1/2/me*sum(ne.*pe(:).^2)/Ne + 1/2/mi*sum(ni.*pi(:).^2)/Ni; % Average kinetic energy
ME = -1/2/me*sum(ne.*afield.^2)/Ne -1/2/mi*sum(ni.*afield.^2)/Ni; % Average magnetic energy

E = KE + ME; % Average total energy per particle
Ze = sum(exp(1/2/me/E*afield(:).^2)); % Partition function for electrons
Zi = sum(exp(1/2/mi/E*afield(:).^2)); % Partition function for ions
% These are partial partition functions. They neglect the momentum-space
% part, which is constant in time.

S = log(Ze) + log(Zi);
end



