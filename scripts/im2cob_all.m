% ------------------------------------------------------------------------ 
%  Copyright (C)
%  Universitat Politecnica de Catalunya BarcelonaTech (UPC) - Spain
%  University of California Berkeley (UCB) - USA
% 
%  Jordi Pont-Tuset <jordi.pont@upc.edu>
%  Pablo Arbelaez <arbelaez@berkeley.edu>
%  June 2014
% ------------------------------------------------------------------------ 
% This file is part of the MCG package presented in:
%    Arbelaez P, Pont-Tuset J, Barron J, Marques F, Malik J,
%    "Multiscale Combinatorial Grouping,"
%    Computer Vision and Pattern Recognition (CVPR) 2014.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
%
% Script to compute COB UCMs on a whole dataset
%
% ------------------------------------------------------------------------
function im2cob_all(database, gt_set, compute_proposals)
if ~exist('database','var')
    database = 'PASCALContext';
end
if ~exist('gt_set','var')
    gt_set = 'voc_test';
end
if ~exist('compute_proposals','var')
    compute_proposals = 0;
end

% Adjust your paths in this file
set_params; 

% Results folder
res_dir = fullfile('results',database,gt_set,'COB');
if ~exist(res_dir,'dir')
    mkdir(res_dir);
end

% Which images to process
im_ids = db_ids(database,gt_set);
for ii=1:length(im_ids),
    % Display evolution
    display(['Processing image ' num2str(ii) ' out of ' num2str(length(im_ids)) ' , name: ' im_ids{ii}]);
    
    % Read image
    im = db_im(database, im_ids{ii});
    
    % Check if the result is already computed and readable
    % (glusterfs not very reliable)
    res_file = fullfile(res_dir,[im_ids{ii} '.mat']);
    try   
        load(res_file);
        display([' Result for image ' im_ids{ii} ' already computed']);
    catch %#ok<CTCH>
         
        % Call the actual code
        if ~compute_proposals
            [ucm2, ~, times] = im2ucm(im);
            parsave_ucm(res_file, ucm2, times);
        else
            [proposals, ucm2, times] = im2prop(im);
            parsave_prop(res_file, proposals, ucm2, times);
        end
    end
end

end


function parsave_ucm(res_file,ucm2,times) %#ok<INUSD>
    save(res_file,'ucm2','times');
end

function parsave_prop(res_file,proposals,ucm2,times) %#ok<INUSD>
    save(res_file,'proposals','ucm2','times');
end
