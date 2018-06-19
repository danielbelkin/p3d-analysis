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
%bfield = cat(4,mx.val(:,:,:,t),my.val(:,:,:,t),mz.val(:,:,:,t)); % Should we save this variable?
pp = parpool('local',16);

names = {'bx by bz'};
val = zeros(512,256,128,3,10);
for i=1:3
   m = matfile([names{i} '.004.mat']);
   val(:,:,:,i,:) = parCompress(m,2,16,1:10);
end
save('/global/u2/d/dbelkin/matlab/bfield.004.compr.mat','val','-v7.3');
    