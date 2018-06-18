function data = getSection(k,file,m,p,varargin)
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
s = size(file,'val'); % Size of the data file
n = 2^floor(log2(p)); % 

if n ~= 0 && any(mod(log2(s),1))
    error('Unlikely to work')
elseif 2^n > prod(s)
    error(['Cannot split ' num2str(prod(s)) ' elements into ' num2str(2^n) ' boxes.'])
end

%% Decide how many times to split along each axis
split = ones(size(s));
for i = 1:n
    [~,j] = max(s./split);
    split(j) = split(j).*2;
end

%% Find the relevant data
subs = cell(1,3); % Subscript indices
[subs{:}] = ind2sub(s(1:3),k);

section = cell(1,3);
for d = 1:3
    indx = [s(d)-m+1:s(d), 1:s(d), 1:m];
    section{d} = indx(1+s(d)/split(d)*(subs{d}-1):s(d)/split(d)*subs{d} + 2*m);
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
            try
                data{i,j,k} = file.val(vects{1}{i},vects{2}{j},vects{3}{k},varargin{:});
            catch
                size(file,'val')
                vects{1}{i}
                vects{2}{j}
                vects{3}{k}
                error('hmm')
            end
        end
    end
end

data = cell2mat(data);
end