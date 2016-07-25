% ------------------------------------------------------------------------ 
%  Copyright (C)
%  ETH Zurich - Switzerland
% 
%  Kevis-Kokitsi Maninis <kmaninis@vision.ee.ethz.ch>
%  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
%  July 2016
% ------------------------------------------------------------------------ 
% This file is part of the COB package presented in:
%    K.K. Maninis, J. Pont-Tuset, P. Arbelaez and L. Van Gool 
%    Convolutional Oriented Boundaries
%    European Conference on Computer Vision (ECCV), 2016 
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
% This function computes the COB-MCG proposals given an image.
%  INPUT:
%  - image         : Input image
%  - compute_masks : Compute the proposals masks [0] or not [1]. Note that
%                     it is very time consuming. Otherwise use the labels 
%                     as shown in the demo.
%
%  OUTPUT:
%  - proposals : Struct containing the following fields
%          + superpixels   : Label matrix of the superpixel partition
%          + labels        : Cell containing the superpixel labels that form
%                            each of the proposals
%          + scores        : Score of each of the ranked proposals
%          + masks         : 3D boolean matrix containing the masks of the proposals
%                            (only if compute_masks==1)
%          + bboxes        : Bounding boxes of the proposals (up,left,down,right)
%                            See 'bboxes' folder for functions to work with them
%          + bboxes_scores : Score of each of the ranked bounding box
%
%  - ucm2     : Ultrametric Contour Map from which the proposals are
%                 extracted
%  - times    : Elapsed times on each part
%
%  DEMO:
%  - See demos/demo_cob_prop.m
% ------------------------------------------------------------------------
function [proposals, ucm2, times] = im2prop(image, compute_masks)
if ~exist('compute_masks','var')
    compute_masks = 0;
end

% Level of overlap to erase duplicates
J_th = 0.95;

% Max margin parameter
theta = 0.7;

% Adjust your paths and parameters in this file
cob_params = set_params();

% Get the hierarchies at each scale and the global hierarchy
[ucm2, ucms, times] = img2ucms(image, cob_params);

% Load pre-trained pareto point
pareto_n_cands = loadvar(fullfile(cob_root, 'models', 'mcg_pareto_point_train2012.mat'),'n_cands');
pareto_n_cands(:,3) = [];

% Load pre-trained random forest regresssor for the ranking of proposals
rf_regressor = loadvar(fullfile(cob_root, 'models', 'mcg_rand_forest_train2012.mat'),'rf');

% ------------------------------------
T=tic;

% Multi, 0.5, 2
all_ucms = cat(3,ucm2,ucms(:,:,2),ucms(:,:,1)); 

% Transform ucms to hierarchies (dendogram) and put them all together
n_hiers = size(all_ucms,3);
lps = [];
ms  = cell(n_hiers,1);
ths = cell(n_hiers,1);
for ii=1:n_hiers
    % Transform the UCM to a hierarchy
    curr_hier = ucm2hier(all_ucms(:,:,ii));
    ths{ii}.start_ths = curr_hier.start_ths';
    ths{ii}.end_ths   = curr_hier.end_ths';
    ms{ii}            = curr_hier.ms_matrix;
    lps = cat(3, lps, curr_hier.leaves_part);
end

% Get full cands, represented on a fused hierarchy
[f_lp,f_ms,cands,start_ths,end_ths] = full_cands_from_hiers(lps,ms,ths,pareto_n_cands);

% Hole filling and complementary proposals
if ~isempty(f_ms)
    [cands_hf, cands_comp] = hole_filling(double(f_lp), double(f_ms), cands); %#ok<NASGU>
else
    cands_hf = cands;
    cands_comp = cands; %#ok<NASGU>
end

% Select which proposals to keep (Uncomment just one line)
cands = cands_hf;                       % Just the proposals with holes filled
% cands = [cands_hf; cands_comp];         % Holes filled and the complementary
% cands = [cands; cands_hf; cands_comp];  % All of them
        
% Compute base features
b_feats = compute_base_features(f_lp, f_ms, all_ucms);
b_feats.start_ths = start_ths;
b_feats.end_ths   = end_ths;
b_feats.im_size   = size(f_lp);

% Filter by overlap
red_cands = mex_fast_reduction(cands-1,b_feats.areas,b_feats.intersections,J_th);

% Compute full features on reduced cands
[feats, bboxes] = compute_full_features(red_cands,b_feats);

% Rank proposals
class_scores = regRF_predict(feats,rf_regressor);
[scores, ids] = sort(class_scores,'descend');
red_cands = red_cands(ids,:);
bboxes = bboxes(ids,:);
if isrow(scores)
    scores = scores';
end

% Max margin
[new_ids, proposals.scores] = mex_max_margin(red_cands-1,scores,b_feats.intersections,theta);
cand_labels = red_cands(new_ids,:);
bboxes = bboxes(new_ids,:); 

% Filter boxes by overlap
[red_bboxes, proposals.bboxes_scores] = mex_box_reduction(bboxes, proposals.scores, 0.95);

% Change the coordinates of bboxes to be coherent with
% other results from other sources (sel_search, etc.)
proposals.bboxes = [red_bboxes(:,2) red_bboxes(:,1) red_bboxes(:,4) red_bboxes(:,3)];

% Get the labels of leave regions that form each proposals
proposals.superpixels = f_lp;
if ~isempty(f_ms)
    proposals.labels = cands2labels(cand_labels,f_ms);
else
    proposals.labels = {1};
end

% Transform the results to masks
if compute_masks
    if ~isempty(f_ms)
        proposals.masks = cands2masks(cand_labels, f_lp, f_ms);
    else
        proposals.masks = true(size(f_lp));
    end
end

times.proposals = toc(T);