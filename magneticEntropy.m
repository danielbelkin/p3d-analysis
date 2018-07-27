function S = magneticEntropy(ve,vi,ne,ni,me,mi)
% S = magneticEntropy(ve,vi,ne,ni,me,mi)
% TODO: Check units on energies, canonical momentum in Gaussian formulation

jfield = ni.*vi - ne.*ve;
% afield = vectorPotential(jfield,20); % I have no clue what an appropriate m is.
% disp('Using n = 20 for vectorPotential')


afield = vectorPotential2(jfield);

pe = me*ve - afield; % Assuming q = -1. 
pi = mi*vi + afield; % q = 1

Ne = sum(ne(:));
Ni = sum(ni(:));

KE = 1/2/me*ne.*pe.^2/Ne + 1/2/mi*ni.*pi.^2/Ni; % Average kinetic energy
ME = -1/2/me*ne.*afield.^2/Ne -1/2/mi*ni.*afield.^2/Ni; % Average magnetic energy

E = sum(KE(:) + ME(:)); % Average total energy per particle
Ze = sum(exp(1/2/me/E*afield(:).^2)); % Partition function for electrons
Zi = sum(exp(1/2/mi/E*afield(:).^2)); % Partition function for ions
% These are partial partition functions. They neglect the momentum-space
% part, which is constant in time.

S = log(Ze) + log(Zi);
end



