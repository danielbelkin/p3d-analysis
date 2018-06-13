%% 
% Script to get some lorajm 3D B-field data, process it, save it.


rdir = '/project/projectdirs/reconn/lorajm/mms3d';
% wdir = '/global/u2/d/dbelkin/matlab/mms3d-matfiles';
wdir = '$SCRATCH/mms3d-matfiles';

t0 = tic;
for num = 0:4
    readMovie(num,{'bx' 'by' 'bz'},'rdir',rdir,'wdir',wdir);
end
toc(t0)