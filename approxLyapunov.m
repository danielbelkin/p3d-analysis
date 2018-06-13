function lambda = approxLyapunov(bfiles, N)
% Approximate version, using averaging over a random sample of points.
% Vect is a vector of matfile data, {bx by bz}, with fieldnames 
% currently .bx, .by, .bz, but plan to make it .val
% TODO: Add option to also return uncertainty. 
% This should work ok without smoothing, I think, since there's already a
% lot of averaging
% Ignores edges, which is conceptually a no-no but in practice shouldn't
% matter at all

%% Sample N points at random
s = size(bfiles{1},'bx');
samp = zeros(length(s),N);

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
    
    Bv = cat(4,bfiles{1}.bx(i-1:i+1, j-1:j+1, k-1:k+1),...
        bfiles{2}.by(i-1:i+1, j-1:j+1, k-1:k+1),...
        bfiles{3}.bz(i-1:i+1, j-1:j+1, k-1:k+1)); % Pull out relevant field vector
    
    B = sqrt(sum(Bv.^2,4)); % Get magnitude at each field point
    B = mean(B(:)); % And average it (Could also just take center point)
    
    for a = 1:3
        for b = 1:3
            J(a,b) = sum(Bv(:,:,:,a).*grad(:,:,:,b))/2; % Estimate the derivatives
        end
    end
    
    % Add these to the sum
    netB = netB + B;
    netJ = netJ + J.*B;
end
Lambda = netJ/netB; % Normalize appropriately
lambda = real(eig(Lambda)); % Could also return the matrix, I guess.

end
