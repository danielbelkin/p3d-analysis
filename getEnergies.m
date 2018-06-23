function [KE,ME,HC] = getEnergies(num,rdir)
%  Gonna write a function to look at KE, ME, etc given a folder. 
% Assume particle charge = 1
% Ion mass = 1
% Electron mass = .01
% Need to track down electron mass
% Plan: Compute v, va. Assume time is 4th dimension.
% KE = 1/2*rho*sum(v.^2,5)
% ME = 1/2*rho*sum(va.^2, 5)
% HC = 1/2*rho*sum(v.*va,5)
% Could also compute U, I guess
% PROBLEM: MHD KE does not account for KE of each species.
% There's energy associated with J. In a pair plasma, KE ~ v1^2 +v2^2
% J ~ v1 - v2, u ~ v1 + v2, so u^2 + j^2 ~ KE
% How does this change in a non-pair plasma?

me = 1e-2;

if nargin < 1
    num = 0;
    rdir = '';
elseif nargin < 2
    rdir = '';
elseif ~isempty(rdir) && ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

if isnumeric(num)
    num = num2str(num,'%0.3i');
elseif ~ischar(num) || numel(num) ~= 3
    error('Input NUM must be a string or integer')
end

names = {'bx' 'by' 'bz' 'jix' 'jiy' 'jiz' 'jex' 'jey' 'jez' 'ne' 'ni'};
% names = {'ne' 'ni'};
ne = 0; % Necessary, for a stupid reason

for i=1:length(names)
    m = load([rdir names{i} '.' num '.compr.mat']); % Takes 15s/variable
    assign(names{i},m.val)
end

rho = ni + ne*me; % Mass density, not charge density
v = cat(5,jix - me*jex,jiy - me*jey,jiz - me*jez);
va = cat(5,bx,by,bz)./sqrt(4*pi*rho);

KE = 1/2*rho.*sum(v.^2,5); % These are negative for some reason. Why?
ME = 1/2*rho.*sum(va.^2,5);
HC = 1/2*rho.*sum(va.*v,5);
end


function assign(var,val)
    assignin('caller',var,val)
end