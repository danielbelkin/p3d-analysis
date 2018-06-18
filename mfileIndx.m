function data = mfileIndx(file,section,varargin)
% DATA = mfileIndx(FILE,SECTION)
% constructs a matrix DATA given a matfile FILE and a cell array of cell 
% arrays of index vectors SECTION. FILE must have a field .val, which is
% 3-dimensional. 
%
% If M were a stuct instead of a matfile, an equivalent function would be
% DATA = m.val(SECTION{:});
% Unfortunately, this is often illegal for matfiles.
%
% This is made to be used with splitIndx for parallelization.
%
% DATA = mfileIndx(M,INDX, I1...In) accesses M.val(:,:,:,I1...In).
% 
% This could be extended to more dimensions, but I think it would be
% slower.
%
% Right now, it also 


% More readable version:
vects = cell(size(section)); % Vector containing index segments
for i = 1:numel(section)
    indx = section{i};
    breaks = [0 find(diff(indx) < 0) length(indx)]; % Jumps in data
    for j = 1:numel(breaks)-1
        vects{i}{j} = section{i}(1+breaks(j):breaks(j+1)); % Section between the jumps
    end
end

nchunks = cellfun(@numel,vects); % Number of vectors for each dimension
data = cell(nchunks);
for i = 1:nchunks(1)
    for j = 1:nchunks(2)
        for k = 1:nchunks(3)
            data{i,j,k} = file.val(vects{1}{i},vects{2}{j},vects{3}{k},varargin{:});
        end
    end
end

data = cell2mat(data);
end