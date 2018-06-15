function v = mfileIndx(m,indx,varargin)
% v = mfileIndx(m,indx)
% constructs a matrix V given a matfile M and a cell array of cell arrays
% of index vectors INDX. M must have a field .val, which is 3-dimensional
% This is made to be used with splitIndx for parallelization.
%
% V = mfileIndx(M,INDX, I1...In) accesses M.val(:,:,:,I1...In).
%
% Because this is called only once per processor, it doesn't need to be
% fast.
% 
% If M were not a matfile, an equivalent function would be
% for d = 1:numel(indx)
%     indx{d} = cell2mat(indx{d});
% end
% v = m(indx{:});
% Unfortunately, this is often illegal for matfiles.
% This could be extended to more dimensions, but I think it would be
% slower.


% More readable version:
vects = cell(size(indx)); % Vector containing index segments
for i = 1:numel(indx)
    data = indx{i};
    breaks = [0 find(diff(data) < 0) length(data)]; % Jumps in data
    for j = 1:numel(breaks)-1
        vects{i}{j} = indx{i}(1+breaks(j):breaks(j+1)); % Section between the jumps
    end
end

nchunks = cellfun(@numel,vects); % Number of vectors for each dimension
v = cell(nchunks);
for i = 1:nchunks(1)
    for j = 1:nchunks(2)
        for k = 1:nchunks(3)
            v{i,j,k} = m.val(vects{1}{i},vects{2}{j},vects{3}{k},varargin{:});
        end
    end
end

v = cell2mat(v);
end