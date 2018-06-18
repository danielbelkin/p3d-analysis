%% 
% Script to get some lorajm 3D B-field data, process it, save it.
% TODO: Add smoothing, memory management

rdir = '/project/projectdirs/reconn/lorajm/mms3d';
% wdir = '/global/u2/d/dbelkin/matlab/mms3d-matfiles';
wdir = '/scratch2/scratchdirs/dbelkin/mms3d-compr';



names = {'bx'};
nums = {'004'};

[indx1,indx2] = meshgrid(1:length(nums),1:length(names));

if isempty(gcp('nocreate'))
    pp = parpool('local',16);
end

t0 = tic;
for i = 1:numel(indx1)
    readMovie(nums{indx1(i)},names{indx2(i)},'rdir',rdir,'wdir',wdir,'skip',0,'compr',4);
    endSound;
end
toc(t0)