function sections = splitIndx(s,m,p)
% SECTIONS = parCircExpand(S,M,P)
% is used to break an array of size S into P chunks, each overlapping by
% M elements on every edge. 
% P should be a power of two. If it is not, only 2^floor(log2(p)) sections
% will be returned. 
% 
% SECTIONS is a cell array. SECTIONS{I}{D} is the cell array of indices for
% processor I along dimension D. To access chunk I of a field named .val
% on a matfile M, use mfileIndx(M,SECTIONS{I})
% 
% TODO: Write a function combining splitIndx and mfileIndx

n = 2^floor(log2(p)); % Use only

if n ~= 0 && any(mod(log2(s),1))
    error('Unlikely to work')
elseif 2^n > prod(s)
    error(['Cannot split ' num2str(prod(s)) ' elements into ' num2str(2^n) ' boxes.'])
end

% Decide how many times to split along each axis
split = ones(size(s));
for i = 1:n
    [~,k] = max(s./split);
    split(k) = split(k).*2;
end

% Assign indices
dim = numel(s);
insideOut = cell(1,dim); % Pre-allocate
c = repmat({':'},1,length(s)); % Used for a cell indexing trick
for d = 1:dim % For each dimension
    indx = [s(d)-m+1:s(d), 1:s(d), 1:m]; 
    insideOut{d} = cell(split); % Pre-allocate again
    for i = 1:split(d) 
        block = indx(1+s(d)/split(d)*(i-1):s(d)/split(d)*(i) + 2*m); % Subsection of indices for this dimension
        c{d} = i; % Construct index list for saving
        insideOut{d}(c{:}) = {block}; % Save
    end
    c{d} = ':'; % This is by far the weirdest Matlab language feature I've found
end

% ...and flip inside out back to right-side-out.
sections = cell(split); % Shape of sections is meaningful.
for l = 1:numel(sections)
    sections{l} = cell(1,d);
    for d = 1:dim
        sections{l}{d} = insideOut{d}{l}; 
    end
end
end