% This file holds whatever code we want to submit to Cori. I'm not really
% sure how this works, exactly. I think it can be submitted with 
% ./matlabCoriSubmit
%
% I'll also use this file for login-node runs. It's just faster to
% write them up here.


addpath /global/u2/d/dbelkin/matlab/p3d-analysis/Visualization
addpath /global/u2/d/dbelkin/matlab/p3d-analysis/Utils
addpath /global/u2/d/dbelkin/matlab/p3d-analysis/Reading


load fieldline2.mat

tic; mu = ergodicMeasure(x,[128 64 64]); toc
info = 'calculated from fieldline2.mat with the default number of points';
save('mu.mat','mu','info','-v7.3')

% names = {'bx' 'by' 'bz' 'ex' 'ey' 'ez'};
% 
% tic
% parfor i=1:numel(names)
%     val = load([names{i} '.mat');
% end
% toc


% Load a bfield snapshot for field-line studies:
% t = 1;
% mx = matfile('bx.004.compr.mat');
% my = matfile('by.004.compr.mat');
% mz = matfile('bz.004.compr.mat');
% 
% bfield = cat(4,mx.val(:,:,:,t),my.val(:,:,:,t),mz.val(:,:,:,t));



% Set up parallel pool and process some data:
% if isempty(gcp('nocreate'))
%     pp = parpool('local',16);
% end

% rdir = '/project/projectdirs/reconn/lorajm/mms2d';
% rdir = '/scratch2/scratchdirs/dbelkin/mms2d-matfiles/';
% wdir = '/scratch2/scratchdirs/dbelkin/mms2d-compr/';

% names = {'bx' 'by' 'bz'};
% for i=1:3
%    i
%    m = matfile([names{i} '.004.mat']);
%    val = parCompress(m,2);
%    save(['/global/u2/d/dbelkin/matlab/' names{i} '.004.compr.mat'],'val','-v7.3')
% end
