%% 
% Script to get some lorajm 3D B-field data, process it, save it.
% TODO: Add smoothing, memory management

rdir = '/project/projectdirs/reconn/lorajm/mms3d';
% wdir = '/global/u2/d/dbelkin/matlab/mms3d-matfiles';
wdir = '/scratch2/scratchdirs/dbelkin/mms3d-matfiles';



names = {'bx' 'by' 'bz'};
% nums = {'000' '001' '002' '003' '004'};
nums = {'004'};

[indx1,indx2] = meshgrid(1:length(nums),1:length(names));

t0 = tic;
parfor i = 1:numel(indx1)
    readMovie(nums{indx1(i)},names{indx2(i)},'rdir',rdir,'wdir',wdir,'skip',100);
end
toc(t0)