function catP3D(varargin)
% Function to automatically collate p3d output files
% TODO: Add option to copy them over from list of directories

varnames = {'rho'; 'jx'; 'jy'; 'jz'; 'bx'; 'by'; 'bz'; 'ex'; 'ey'; 'ez';
    'ne'; 'jex';'jey'; 'jez'; 'pexx'; 'peyy'; 'pezz'; 'pexy'; 'peyz';
    'pexz'; 'ni'; 'jix'; 'jiy'; 'jiz'; 'pixx'; 'piyy';'pizz'; 'pixy';
    'piyz'; 'pixz'; 'log'};


okargs = {'rdir' 'wdir' 'vars'};
dflts = {pwd pwd varnames};
[rdir,wdir,varnames] = parseArgs(okargs,dflts,varargin{:});

if ~isempty(wdir) && ~strcmp(wdir(end),'/')
    wdir(end+1) = '/';
end

if ~isempty(rdir) && ~strcmp(rdir(end),'/')
    rdir(end+1) = '/';
end

for i=1:length(varnames)    
    eval(['!rm ' wdir 'movie.' varnames{i} '.tot'])
    eval(['!cat ' rdir 'movie.' varnames{i} '.??? > ' wdir 'movie.' varnames{i} '.tot'])
end
end