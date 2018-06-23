function data = getSection(k,file,field,m,p,varargin)
% data = getSection(k,file,m,p)
% data = getSection(k,file,m,p, I1...In)
% This function will combine mfileIndx and splitIndx in a more efficient
% way.
% Accesses section K of matfile FILE with M overlapping points, assuming P
% processors are available. 
% Splits along first 3 dimensions only. 
% 
% 
% TODO: Make sure that trailing indices are handled appropriately. 

%% Process inputs
s = size(file,field); % Size of the data file
split = getSplits(s(1:3),p);

if isempty(varargin)
    T = cell(1,length(s)-3);
    for i = 1:length(s) - 3
        T{i} = 1:s(i+3);
    end
else
    T = varargin;
end
    

%% Find the relevant data
subs = cell(1,3); 
[subs{:}] = ind2sub(split,k); % Find subscript indices from the linear index k.

section = cell(1,3);
for d = 1:3
    indx = [s(d)-m+1:s(d), 1:s(d), 1:m];
    section{d} = mod(indx(1+s(d)/split(d)*(subs{d}-1):s(d)/split(d)*subs{d} + 2*m) - 1,s(d)) + 1;
end

%% Pull the data from the file
vects = cell(1,3); % Holds indices broken by segment.
for d = 1:3
    breaks = [0 find(diff(section{d}) < 0) length(section{d})]; % Jumps in data
    vects{d} = cell(1,numel(breaks)-1); % Pre-allocate
    for i = 1:numel(breaks)-1
        vects{d}{i} = section{d}(1+breaks(i):breaks(i+1)); % Section between the jumps
    end
end

nchunks = cellfun(@numel,vects); % Number of vectors for each dimension
data = cell(nchunks);
for i = 1:nchunks(1)
    for j = 1:nchunks(2)
        for k = 1:nchunks(3)
            % data{i,j,k} = file.val(vects{1}{i},vects{2}{j},vects{3}{k},T{:});
            try
                data{i,j,k} = eval(['file.' field '(vects{1}{i},vects{2}{j},vects{3}{k},T{:});']);
            catch
                % f = @(x) any(diff(x) ~= 1);
                % f(vects{1}{i})
                % f(vects{2}{j})
                f(vects{3}{k})
                k
                vects{3}(k)
                diff(vects{3}(k))
                % cellfun(f,T)
                error('bad')
            end
            % Yeah, this is ugly.
        end
    end
end

data = cell2mat(data);
end