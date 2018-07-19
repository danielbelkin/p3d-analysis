function readMMS3D(name, num)
% readMMS3D(name, num)
% Intended to standardize how I process data
rdir = '/project/projectdirs/reconn/lorajm/mms3d';
wdir = '/scratch2/scratchdirs/dbelkin/mms3d-compr';

if isempty(gcp('nocreate'))
    parpool('local',16);
end

t0 = tic;
readMovie(num,name,'rdir',rdir,'wdir',wdir,'skip',0,'compr',4);
toc(t0)
end