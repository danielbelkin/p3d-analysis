function S = magneticEntropy(ve,vi,ne,ni,me,mi)
% S = magneticEntropy(ve,vi,ne,ni,me,mi)
% TODO: Check units on energies, canonical momentum in Gaussian formulation

if nargin < 6
    mi = 1;
end

qe = -1;
qi = 1;

jfield = qi.*ni.*vi + qe.*ne.*ve;

afield = vectorPotential2(jfield);

% pe = me*ve - afield; % Assuming q = -1. 
% pi = mi*vi + afield; % q = 1
% Don't need these, I think.

Ne = sum(ne(:));
Ni = sum(ni(:));

% Many mistakes below. 
% KE = 1/2/me*ne.*pe.^2/Ne + 1/2/mi*ni.*pi.^2/Ni; % Average kinetic energy
% ME = -1/2/me*ne.*afield.^2/Ne -1/2/mi*ni.*afield.^2/Ni; % Average magnetic energy
% ME = -1/2/me

KE = 1/2*me*sum(ve.^2,5).*ne/Ne + 1/2*mi*sum(vi.^2,5).*ni/Ni; % KE per particle
ME = qe.*sum(ve.*afield,5).*ne/Ne + qi.*sum(vi.*afield,5).*ni/Ni; % ME per particle

E = sum(KE(:) + ME(:)); % Average total energy per particle
Ze = sum(exp(1/2/me/E*qe^2*sum(afield(:).^2,5))); % Partition function for electrons
Zi = sum(exp(1/2/mi/E*qi^2*sum(afield(:).^2,5))); % Partition function for ions
% These are partial partition functions. They neglect the momentum-space
% part, which is constant in time.

S = log(Ze) + log(Zi);
end



