function [x,x0] = fieldLine(bfield, t, x0)
% x = fieldLine(bfield, t, x0)
% Tracks magnetic field line starting at x0 for a time t.
% If x0 is not specified, a start point is chosen at random. 
% Not a unit-speed parameterization.
% Does not modulo it to be inside box.

s = size(bfield);
bfield = double(bfield);
B = sqrt(sum(bfield.^2,4));

if nargin < 3
    % Choose a random initial point with probabiltiy density proportional
    % to field strength
    rng('shuffle')
    v = [0; cumsum(B(:))]./sum(B(:)); % Assign a region of [0,1] to each grid point
    l = discretize(rand,v); % Choose a grid point with appropriate probability
    
    x0 = cell(3,1);
    [x0{:}] = ind2sub(s(1:3),l); % Map back into 3D
    x0 = cell2mat(x0);
    
    % x0 = s(1:3).*rand(1,3);
    clear B v % Does Matlab garbage collection do this automatically?
end

% Prepare to expand:
indx = cell(1,3);
for i = 1:3
    indx{i} = [1:s(i), 1];
end

%% Compute field Jacobian
% deriv = cat(3,-ones(3),zeros(3),ones(3)); % This gives 18 times the gradient.
% grad = cat(4,shiftdim(deriv,1),shiftdim(deriv,2),shiftdim(deriv,3)); 
% 
% J = zeros([3 3 s(1:3)]);
% for i = 1:3
%     for j = 1:3
%         out = cconvn(bfield(:,:,:,i),grad(:,:,:,j))/18;
%         J(i,j,:,:,:) = reshape(out,[1 1 s(1:3)]);
%     end
% end
% 
% J = J(:,:,indx{:}); % Problem: Got an out-of-memory error here.
% 
% Jfun = @(~,x) J(:,:,...
%     round(mod(x(1),s(1))) + 1,...
%     round(mod(x(2),s(2))) + 1,...
%     round(mod(x(3),s(3))) + 1);

%% Construct flow by interpolation

boxmod = @(x) {mod(x(2),s(2))+1 mod(x(1),s(1))+1 mod(x(3),s(3))+1}; % Used for index generation

bfield = bfield(indx{:},:); % Extend along one side (for interpolation)

interpFun = @(x,b) interp3(b,x{:}); % Interpolates mod s

f = @(~,x) [interpFun(boxmod(x),bfield(:,:,:,1));...
    interpFun(boxmod(x),bfield(:,:,:,2));...
    interpFun(boxmod(x),bfield(:,:,:,3))];

%% Solve the differential equation
% options = odeset('MaxStep',1,... % This may slow things down considerably.
%     'Vectorized','off');

% options = odeset('Jacobian',Jfun); % For 23t
options = odeset;

tic
% [~,x] = ode45(f,[0 t],x0,options); %
[~,x] = ode23t(f,[0 t],x0,options);
toc

% Ode45 is fastest, but it only works well if we hold the step
% size down. Ode23t ends up being faster because the step can be longer.
end