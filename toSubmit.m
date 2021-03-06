% This file holds whatever code we want to submit to Cori. I'm not really
% sure how this works, exactly. I think it can be submitted with 
% ./matlabCoriSubmit
%
% I'll also use this file for login-node runs. It's just faster to
% write them up here.

addpath ~/matlab/p3d-analysis
run setup.m

rdir = [proj 'gem_orig/all'];
wdir = [scratch 'gem-guide-matfiles'];
cd(wdir);



%% Reading
% if isempty(gcp('nocreate'))
%     pp = parpool('local',12);
% end
% 
% names = {'bx' 'by' 'bz' 'ne' 'ni' 'jix' 'jiy' 'jiz' 'jex' 'jey' 'jez'};
% num = 'tot';
% parfor i=1:length(names)
%     readMovie(num,names{i},'rdir',rdir,'wdir',wdir);
% end


%% Loading variables
names = {'bx' 'by' 'bz' 'ne' 'ni' 'jix' 'jiy' 'jiz' 'jex' 'jey' 'jez'};
for i=1:numel(names)
    load([names{i} '.tot.mat']);
    assignin('base',names{i},val)
end

ji = cat(5,jix,jiy,jiz);
je = cat(5,jex,jey,jez);

clear jix jiy jiz jex jey jez

vi = ji./ni;
ve = -je./ne;

me = .04;
rho = ni + me*ne;
bfield = cat(5,bx,by,bz);
clear bx by bz

va = bfield./sqrt(rho);

sum3 = @(x) sum(sum(sum(x,1),2),3);
dot = @(x,y) sum(x.*y,5);


%% Misc



% mu = (ni + ne)./sum(sum(ni+ne,1),2); % Probability measure
% 
% avg = @(x) sum(sum(x.*mu,1),2); % Not sure how best to weight this
% vcov = @(x,y) avg(sum(x.*y,5)) - sum(avg(x).*avg(y),5);
% r = @(x,y) vcov(x,y)./sqrt(vcov(x,x).*vcov(y,y));

%
% N = 16; % Number of field lines to do
% parfor i=1:N
%     bfield = load('/scratch2/scratchdirs/dbelkin/heat3d/bfield.compr.mat');
%     lines{i} = fieldLine(bfield.val, 1e5);
% end
% 
% info = 'Created 7/9 with ode23t, t = 1e5';
% save([wdir 'lines3.mat'],'lines','info')

% Question: Can we look at correlations between lines?
% mu{i} = ergodicMeausre(lines(i)
% mu{i} = mu{i}(:);
% r = corrcoef(cell2mat(mu(:)'));


% lambda = cell(1,N);
% parfor i=1:N
%     % line = load(['fieldline' num2str(i) '.mat']);
%     lines = load('section4.mat')
%     mu = ergodicMeasure(lines.lines{i},[128 64 64]);
%     
%     field = load('../bfield.compr.mat')
%     lambda{i} = bLyapunov(field.val,mu);
% end







% x0 = [ones(1,N)' (1:4:64)' ones(1,N)'];
% 
% lines = cell(1,N);
% parfor i=1:N
%     bfield = load('/scratch2/scratchdirs/dbelkin/heat3d/bfield.mat');
%     lines{i} = fieldLine(bfield.val, 1e4,x0(i,:));
% end
%
% Time taken: 1 hour for most, 2 hours for longest.
% 
% save([wdir 'section6.mat'],'lines')


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
