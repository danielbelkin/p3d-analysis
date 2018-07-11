function lle = localLyapunov(bfield)

s = size(bfield);

% Construct the gradient operator
d = cat(3,-ones(3),zeros(3),ones(3)); % This gives 18 times the gradient.
grad = cat(4,shiftdim(d,1),shiftdim(d,2),shiftdim(d,3)); 

J = zeros([s(1:3) 3 3]);

for i = 1:3
    for j = 1:3
        J(:,:,:,i,j) = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/18;
    end
end

Jval = zeros(3,3);
lle = zeros(s(1:3));
for i = 1:s(1)
    for j = 1:s(2)
        for k = 1:s(3)
            Jval(:) = J(i,j,k,:,:);
            lle(i,j,k) = max(real(eig(Jval)));
        end
    end
end
end