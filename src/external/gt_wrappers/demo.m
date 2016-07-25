% ------------------------------------------------------------------------ 
%  Copyright (C)
%  ETHZ - Computer Vision Lab
% 
%  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
%  September 2015
% ------------------------------------------------------------------------ 
% This file is part of the BOP package presented in:
%    Pont-Tuset J, Van Gool, Luc,
%    "Boosting Object Proposals: From Pascal to COCO"
%    International Conference on Computer Vision (ICCV) 2015.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------

%% Add paths
addpath(genpath(gt_wrappers_root));

%% Get all image IDs from a certain dataset
% database = 'COCO';   gt_set   = 'train2014';
% database = 'Pascal'; gt_set   = 'Segmentation_train_2012';
% database = 'SBD';    gt_set   = 'train';
database = 'BSDS500';    gt_set   = 'train';

sel_id   = 2;

% Read image IDs
im_ids = db_ids(database,gt_set);

% Show size and example ID
disp(['There are ' num2str(length(im_ids)) ' images in ' database ' - ' gt_set])
disp([' Example ID ''' im_ids{sel_id} ''' in position ' num2str(sel_id)])

%% Load an image
im = db_im(database,im_ids{sel_id});

% Display
figure; subplot(2,2,1);
imshow(im)

%% Load a ground-truth annotation (first time in COCO takes longer)
gt = db_gt(database,im_ids{sel_id});

if isfield(gt,'masks') % Object ground truth
    for ii=1:min(3,length(gt.masks))
        subplot(2,2,1+ii);
        imshow(gt.masks{ii})
    end
elseif iscell(gt)
    for ii=1:min(3,length(gt))
        subplot(2,2,1+ii);

        imshow(label2rgb(gt{ii},'jet', 'k', 'shuffle'))
    end
else
    error('Unknown format');
end



