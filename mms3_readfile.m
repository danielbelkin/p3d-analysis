%% 
% Script to get some lorajm 3D B-field data, process it, save it.
% TODO: Add smoothing, memory management

rdir = '/project/projectdirs/reconn/lorajm/mms3d';
% wdir = '/global/u2/d/dbelkin/matlab/mms3d-matfiles';
wdir = '/scratch2/scratchdirs/dbelkin/mms3d-compr';



names = {'bx' 'by' 'bz'};
nums = {'004'};

[indx1,indx2] = meshgrid(1:length(nums),1:length(names));

t0 = tic;
for i = 1:numel(indx1)
    disp(['Starting worker ' num2str(i)]) % Temporary, here for debugging
    readMovie(nums{indx1(i)},names{indx2(i)},'rdir',rdir,'wdir',wdir,'skip',100,'compr',1);
end
toc(t0)