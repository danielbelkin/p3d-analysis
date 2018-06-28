function [x,x0] = fieldLine(bfield, d, x0)
% x = fieldLine(bfield, d, x0)
% Tracks magnetic field line starting at x0 for an approximate distance d.
% If x0 is not specified, a start point is chosen at random. 
% Not a unit-speed parameterization.
% Does not modulo it to be inside box.

s = size(bfield);
if nargin < 3
    x0 = s(1:3).*rand(1,3);
end


% Prepare to expand:
indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end

% Figure out how much time to use:
B = sqrt(sum(bfield.^2,4));
v = 1/mean(1./abs(B(:))); % Average velocity
tmax = d/v; 

%% Compute field Jacobian
deriv = cat(3,-ones(3),zeros(3),ones(3)); % This gives 18 times the gradient.
grad = cat(4,shiftdim(deriv,1),shiftdim(deriv,2),shiftdim(deriv,3)); 

J = zeros([3 3 s(1:3)]);
for i = 1:3
    for j = 1:3
        out = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/18;
        J(i,j,:,:,:) = reshape(out,[1 1 s(1:3)]);
    end
end

J = J(:,:,indx{:});

Jfun = @(~,x) J(:,:,...
    round(mod(x(1),s(1))) + 1,...
    round(mod(x(2),s(2))) + 1,...
    round(mod(x(3),s(3))) + 1);

% Benchmark time: 3.38 without Jacobian

%% Construct flow by interpolation

boxmod = @(x) {mod(x(2),s(2))+1 mod(x(1),s(1))+1 mod(x(3),s(3))+1}; % Used for index generation

bfield = bfield(indx{:},:); % Extend along one side (for interpolation)

interpFun = @(x,b) interp3(b,x{:}); % Interpolates mod s

f = @(~,x) [interpFun(boxmod(x),bfield(:,:,:,1));...
    interpFun(boxmod(x),bfield(:,:,:,2));...
    interpFun(boxmod(x),bfield(:,:,:,3))];

%% Solve the differential equation
options = odeset('MaxStep',1,... % This may slow things down considerably.
    'Vectorized','off');

% TODO: Set jacobian.
tic
[~,x] = ode45(f,[0 tmax],x0,options); %
% [~,x] = ode23tb(f,[0 tmax],x0,options); % More accurate?
% Ode45 is about twice as fast
% Only use a stiff-equation method if we really need to.
toc
end