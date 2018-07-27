function c = doubleCurl(v)
% Faster version of double-curl
% Requires only 9 convolutions, cf 12 for curl(curl())
% Assumes 5-D formatting
% Useful in periodic coordinates - built-in curl function is faster if
% edges not important
dx = [-1; 0; 1]/2; % This is twice the curl.
dy = reshape(dx,1,3);
dz = reshape(dx,1,1,3);
c = zeros(size(v));
c(:,:,:,:,1) = cconvn(v(:,:,:,:,2), convn(dy,dx)) + ...
    cconvn(v(:,:,:,:,1), -convn(dy,dy)-convn(dz,dz)) + ...
    cconvn(v(:,:,:,:,3), convn(dz,dx));

c(:,:,:,:,2) = cconvn(v(:,:,:,:,1), convn(dy,dx)) + ...
    cconvn(v(:,:,:,:,2), -convn(dx,dx)-convn(dz,dz)) + ...
    cconvn(v(:,:,:,:,3), convn(dz,dy));

c(:,:,:,:,3) = cconvn(v(:,:,:,:,1), convn(dz,dx)) + ...
    cconvn(v(:,:,:,:,3), -convn(dx,dx)-convn(dy,dy)) + ...
    cconvn(v(:,:,:,:,2), convn(dz,dy));
end