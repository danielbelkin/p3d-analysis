function endSound
% This function plays a sound. It's useful for marking the end of a long function. 
x = 0:3000;
y = sin(pi*x/1000).^2.*sin(x/5);
soundsc(y)
end