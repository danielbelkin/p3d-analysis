function varargout = parseArgs(okargs,defaults,varargin)
% Just a pared-down custom version of internal.stats.parseArgs. Works the
% same for all the cases in which I usually use it.
% Useful on NERSC, where stats toolbox licenses are limited

% Initialize some variables
varargout = defaults;
nargs = numel(varargin);

% Must have name/value pairs
if mod(nargs,2)~=0
    error('Wrong number of input arguments? Must have name/value pairs')
end

% Process name/value pairs
for j=1:2:nargs
    pname = varargin{j};
    if ~ischar(pname)
        error('Parameter names must be strings');
    end
    
    mask = strncmpi(pname,okargs,length(pname)); % look for partial match

    if ~any(mask)
        error('Unrecognized parameter name')
    elseif sum(mask)>1
        mask = strcmpi(pname,okargs); % use exact match to resolve ambiguity
        if sum(mask)~=1
            error('Ambiguous parameter name')
        end
    end
    varargout{mask} = varargin{j+1};
end
end

