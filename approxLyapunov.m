function lambda = approxLyapunov(bfiles, N, t)
% Approximate version, using averaging over a random sample of points.
% Vect is a vector of matfile data, {bx by bz}, with fieldnames 
% currently .bx, .by, .bz, but plan to make it .val
% TODO: Add option to also return uncertainty. 
% Because uncertainty is important
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

%% Sample N points at random
s = size(bfiles{1},'val');
samp = zeros(N,3);

for i=1:3
    samp(:,i) = randi([2 s(i)-1],N,1); % Just ignore the edges for now
end

%% Find LEs at these points
% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives twice the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3));

netB = 0;
netJ = zeros(3);
J = zeros(3);
for n = 1:N
    i = samp(n,1);
    j = samp(n,2);
    k = samp(n,3);
    
    Bv = cat(4,bfiles{1}.val(i-1:i+1, j-1:j+1, k-1:k+1,t),...
        bfiles{2}.val(i-1:i+1, j-1:j+1, k-1:k+1,t),...
        bfiles{3}.val(i-1:i+1, j-1:j+1, k-1:k+1,t)); % Pull out relevant field vector
    
    B = sqrt(sum(Bv.^2,4)); % Get magnitude at each field point
    % B = mean(B(:)); % And average it (Could also just take center point)
    
    
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
Lambda = netJ/netB; % Normalize appropriately
lambda = real(eig(Lambda)); % Could also return the matrix, I guess.


end
