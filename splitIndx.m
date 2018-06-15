function sections = splitIndx(s,m,n)
% SECTIONS = parCircExpand(S,M,N)
% is used to break an array of size S into N chunks, each overlapping by M
% elements on every edge. This is useful for parallelizing access to
% matfiles. 
% SECTIONS is a cell array. SECTIONS{P}{D} is the list of indices for
% processor P along dimension D. To access the desired chunk of a variable
% X, processor P can use X(SECTIONS{P}{:}). 
% Consider renaming to indxSplit, parIndx or something.

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
    indx = [s(d)-m+1:s(d), 1:s(d), 1:m]; % All indices along this dimension
    
    insideOut{d} = cell(split); % Pre-allocate again
    for i = 1:split(d) 
        block = indx(1+s(d)/split(d)*(i-1):s(d)/split(d)*(i) + 2*m); % Subsection of indices for this dimension
        c{d} = i; % Construct index list for saving
        insideOut{d}(c{:}) = {block}; % Save
    end
    c{d} = ':'; % This is by far the weirdest Matlab language feature I've found
end

% ...and flip inside out back to right-side-out.
sections = cell(1,2^n);
for l = 1:numel(sections)
    sections{l} = cell(1,d);
    for d = 1:dim
        sections{l}{d} = insideOut{d}{l}; 
    end
end
end