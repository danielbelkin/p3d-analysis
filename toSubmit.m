% This file holds whatever code we want to submit to Cori. I'm not really
% sure how this works, exactly. I think it can be submitted with 
% ./matlabCoriSubmit
%
% I'll also use this file for interactive, simple runs. It's just faster to
% write them up here.

addpath /global/u2/d/dbelkin/matlab/p3d-analysis
cd /scratch2/scratchdirs/dbelkin/mms3d-compr

mx = load('bx.004.mat');
my = load('by.004.mat');
mz = load('bz.004.mat');

t = 1; % Can be 1:10
bfield = cat(4,mx.val(:,:,:,t),my.val(:,:,:,t),mz.val(:,:,:,t)); % Should we save this variable?

for i 