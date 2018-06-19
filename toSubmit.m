% This file holds whatever code we want to submit to Cori. I'm not really
% sure how this works, exactly. I think it can be submitted with 
% ./matlabCoriSubmit
%
% I'll also use this file for interactive, simple runs. It's just faster to
% write them up here.

addpath /global/u2/d/dbelkin/matlab/p3d-analysis
cd /scratch2/scratchdirs/dbelkin/mms3d-compr

if isempty(gcp('nocreate'))
    pp = parpool('local',16);
end

names = {'bx' 'by' 'bz'};
val = zeros(512,256,128,3,10);
for i=1:3
   i
   m = matfile([names{i} '.004.mat']);
   val = parCompress(m,2);
   save(['/global/u2/d/dbelkin/matlab/' names{i} '.004.compr.mat'],'val','-v7.3')
end
