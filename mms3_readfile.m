%% 
% Script to get some lorajm 3D B-field data, process it, save it.


rdir = '/project/projectdirs/reconn/lorajm/mms3d';
wdir = '/global/u2/d/dbelkin/matlab/mms3d-matfiles';

for num = 0
    readMovie(num,{'bx' 'by' 'bz'},'rdir',rdir,'wdir',wdir);
end
