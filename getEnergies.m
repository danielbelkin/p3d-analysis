
function [KE,ME,HC] = getEnergies(num,rdir)
%  Gonna write a function to look at KE, ME, etc given a folder. 
% Assume mass ratio large, ion mass = 1
% Also assume particle charge = 1
% So that momentum = Ji
% Plan: Compute v, va. Assume time is 4th dimension.
% KE = 1/2*rho*sum(v.^2,5)
% ME = 1/2*rho*sum(va.^2, 5)
% HC = 1/2*rho*sum(v.*va,5)
% Could also compute U, I guess

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

names = {'bx' 'by' 'bz''jex' 'jey' 'jez' 'rho'};

for i=1:length(names)
    m = load([rdir names{i} '.' num '.mat']); % Takes 15s/variable
    assignin('caller',names{i},m.val)
end

v = cat(5,jix,jiy,jiz);
va = cat(5,bx,by,bz)./sqrt(4*pi*rho);

KE = 1/2*rho.*sum(v.^2,5);
ME = 1/2*rho.*sum(va.^2,5);
HC = 1/2*rho.*sum(va.*v,5);
end