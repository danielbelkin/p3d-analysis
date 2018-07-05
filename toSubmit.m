% This file holds whatever code we want to submit to Cori. I'm not really
% sure how this works, exactly. I think it can be submitted with 
% ./matlabCoriSubmit
%
% I'll also use this file for login-node runs. It's just faster to
% write them up here.

% wdir = '/scratch2/scratchdirs/dbelkin/heat3d/fieldlines/';
% cd(wdir);

if isempty(gcp('nocreate'))
    pp = parpool('local',16);
end

% N = 32; % Number of field lines to do
% x0 = [zeros(1,32)' (1:32)' zeros(1,32)'];
% 
% lines = cell(1,N);
% parfor i=1:N
%     bfield = load('/scratch2/scratchdirs/dbelkin/heat3d/bfield.compr.mat');
%     lines{i} = fieldLine(bfield.val, 1e4,x0(i,:));
% end
% 
% save('section2.mat','lines')

xc = cell(32,1);
parfor i = 1:32
    y = plotLine(lines{i},[128 64 64],'figure',false);
    xc{i} = cellfun(@(x) x(1,:),y,'UniformOutput',false);
    xc{i} = cell2mat(xc{i}(:));
end



% info = 'Created 7/5 with ode23t, t = 1e4';
% for i=1:N
%     val = lines{i};
%     save([wdir 'fieldline' num2str(i + 46) '.mat'],'val','info','-v7.3')
% end

% len = cellfun(@(x) sum(sqrt(sum(diff(x).^2,2))),lines); 
% for i=1:numel(lines)
%   mu = mu + len(i)*ergodicMeasure(lines{i},[128 64 64]);
% end




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
