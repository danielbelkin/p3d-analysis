function lambda = lineLyapunov(path,Bfield)
% Plan: Compute Jacobian at every point on field (in a 3x3 cell array)
% Then use linear interpolation to compute each element at every point on
% the path
% Then average along the path with a cellfun
% Then find eigenvalues

disp('Running lineLyapunov...')


B = sqrt(sum(Bfield.^2,4));
bfield = Bfield./B; % Unit vector field

s = size(bfield);
indx = cell(1,3);

for i = 1:3
    indx{i} = [1:s(i), 1];
end

path =  [mod(path(:,1),s(1)) mod(path(:,2),s(2)) mod(path(:,3),s(3))] + 1; % Keep it inside domain

% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives 18 times the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3)); 

avgJ = zeros(3);
for i = 1:3
    for j = 1:3
        Jij = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/18;
        Jij = Jij(indx{:});
        avgJ(i,j) = mean(interp3(Jij,path(:,2),path(:,1),path(:,3)));
    end
end

Lambda = 1/2*logm(expm(avgJ)*expm(avgJ)'); 
lambda = sort(eig(Lambda)); 
end