function drawPoincare(crossings,t,s)
% Draws the Poincare section using data returned by Crossings
% Options: Traditional Poincare section, where we just follow one point
% around.
% Or, choose a timestep. Color all the points according to their origins.
% So, create a npts-by-3 matrix. Rval is x-coordinate of origin, Bval is
% y-coordinate. Show how it evolves. 
% Let's just do this the slow way, where we plot each point.

if nargin < 3
    x = crossings(1,:,:);
    y = crossings(2,:,:);
    s = [max(x(:)) max(y(:))];
end


x0 = crossings(:,1,:);
xt = crossings(:,t,:); 

rVal = 1/2 + sin(pi*x0(1,:)./s(1))'/2;
gVal = 1/2 + sin(pi*x0(2,:)./s(2))'/2;
bVal = .2*ones(size(rVal)); % Whatever looks best
colors = [rVal gVal bVal];

figure(1); clf; hold on;
for i = 1:size(xt,3)
    plot(xt(1,1,i),xt(2,1,i),'o','Color',colors(i,:));
end
end





