function [S,KE,ME] = magneticEntropy(ve,vi,ne,ni,me,mi)
% S = magneticEntropy(ve,vi,ne,ni,me,mi)
% TODO: Check units on energies, canonical momentum in Gaussian formulation
%TODO: 

if nargin < 6
    mi = 1;
end

sum3 = @(x) sum(sum(sum(x,1),2),3);
dot = @(x,y) sum(x.*y,5);

qe = -1;
qi = 1;

J = qi.*ni.*vi + qe.*ne.*ve;

A = vectorPotential2(J);

Ne = sum3(ne);
Ni = sum3(ni);

% Many mistakes below. 
% KE = 1/2/me*ne.*pe.^2/Ne + 1/2/mi*ni.*pi.^2/Ni; % Average kinetic energy
% ME = -1/2/me*ne.*afield.^2/Ne -1/2/mi*ni.*afield.^2/Ni; % Average magnetic energy
% ME = -1/2/me

KE = 1/2*me*dot(ve,ve).*ne./Ne + 1/2*mi*dot(vi,vi).*ni./Ni; % KE per particle
ME = qe.*dot(ve,A).*ne./Ne + qi.*dot(vi,A).*ni./Ni; % ME per particle

KE = sum3(KE);
ME = sum3(ME);

E = KE + ME; % Average total energy per particle
Ze = sum3(exp(1/2/me/E*qe^2*dot(A,A))); % Partition function for electrons
Zi = sum3(exp(1/2/mi/E*qi^2*dot(A,A))); % Partition function for ions
% These are partial partition functions. They neglect the momentum-space
% part, which is constant in time.


S = log(Ze) + log(Zi);
end



