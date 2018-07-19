function readHeat3D(name)

rdir = '/project/projectdirs/reconn/jdahlin/heat_3d/';
wdir = '/scratch2/scratchdirs/dbelkin/heat3d/';

nx = 512;
ny = 256;
nz = 256;

val = dlmread([rdir 'test' name '.txt']);
val = val';
val = val(:);
val = val(val ~= 0); % Not sure why this is necessary
val = reshape(val,nx,ny,nz);
save([wdir name '.mat'],'val','-v7.3');
end
