function data = getSection(k,file,field,m,p,varargin)
% DATA = getSection(K,FILE,FIELD,M,P)
% Retrieves section K of field FIELD on matfile FILE, assuming P processors
% are available and M overlapping points are needed.
% Splits along first 3 dimensions only. To understand how it divides up
% files, use getSplits.
%
% data = getSection(k,FILE,FIELD,m,p, I1...In)
% splits up FILE.FIELD(:,:,:,I1,I2...In). The trailing indices must follow
% the usual rules for indexing into matfiles. By default, I1...In = ':'.

%% Process inputs
s = size(file,field); % Size of the data file
split = getSplits(s(1:3),p);

if isempty(varargin)
    T = cell(1,length(s)-3);
    for i = 1:length(s) - 3
        T{i} = 1:s(i+3);
        % T{i} = ':'; % I'm not sure if this works for matfiles
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
    breaks = [0 find(diff(section{d}) <= 0) length(section{d})]; % Jumps in data
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
            data{i,j,k} = eval(['file.' field '(vects{1}{i},vects{2}{j},vects{3}{k},T{:});']);
            % Yeah, this is ugly.
        end
    end
end

data = cell2mat(data);
end