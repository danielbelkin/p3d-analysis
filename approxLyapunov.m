function lambda = approxLyapunov(bfiles, N, t)
% Approximate version, using averaging over a random sample of points.
% Vect is a vector of matfiles, {bx by bz}, with fieldnames .val
%
% TODO: Add option to also return uncertainty.
% This should work ok without smoothing, I think, since there's already a
% lot of averaging
% Ignores edges, which is conceptually a no-no but in practice shouldn't
% matter at all
% t is the timestep at which we look
%
% This is still remarkably slow, considering.
% Presumably because it involves repetetive reading of the same files.
% Could be more efficient to do some trickery like choosing entire lines at
% random?
% And averaging along those lines, but only the center part.
% Or: Parallelize this.
%

if isa(bfiles{1},'matlab.io.MatFile')
    isMatfile = true;
else
    isMatfile = false;
end
%% Find LEs at these points
if isMatfile
    s = size(bfiles{1},'val');
else
    s = size(bfiles{1});
end

% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives twice the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3));
% Or should this be constructed inside the loop?
% One option: Construct it as int8, then convert to double

netB = 0;
netJ = zeros(3);
parfor n = 1:N
    i = randi([2 s(1)-1],N,1);
    j = randi([2 s(2)-1],N,1);
    k = randi([2 s(3)-1],N,1);
    
    if isMatfile
        Bv = cat(4,bfiles{1}.val(i-1:i+1, j-1:j+1, k-1:k+1,t),...
            bfiles{2}.val(i-1:i+1, j-1:j+1, k-1:k+1,t),...
            bfiles{3}.val(i-1:i+1, j-1:j+1, k-1:k+1,t)); % Pull out relevant field vector
    else
        Bv = cat(4,bfiles{1}(i-1:i+1, j-1:j+1, k-1:k+1,t),...
            bfiles{2}(i-1:i+1, j-1:j+1, k-1:k+1,t),...
            bfiles{3}(i-1:i+1, j-1:j+1, k-1:k+1,t));
    end
    B = sqrt(sum(Bv.^2,4)); % Get magnitude at each field point
    % B = mean(B(:)); % And average it (Could also just take center point)
    
    J = zeros(3);
    for a = 1:3
        for b = 1:3
            y = Bv(:,:,:,a)./B.*grad(:,:,:,b); % Estimated gradient
            J(a,b) = sum(y(:))/2; % Estimate the derivatives
        end
    end
    
    % Add these to the sum
    netB = netB + mean(B(:));
    netJ = netJ + J.*mean(B(:));
end
avgJ = netJ/netB;
Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); % Normalize appropriately
lambda = sort(eig(Lambda)); % Could also return the matrix, I guess.

% Earlier formula was incorrect because of non-commutivity of matrix math
end
