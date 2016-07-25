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

% Check that 'cob_root' has been set
if ~exist(cob_root,'dir')
    error('Error installing the package, try updating the value of cob_root in the file "cob_root.m"')
end

% Check that 'cob_root' has the needed folder
if ~exist(fullfile(cob_root,'lib'),'dir')
    error('Error installing the package, the folder "lib" not found, have you compiled it? See build.m')
end
if ~exist(fullfile(cob_root,'src'),'dir')
    error('Error installing the package, the folder "src" not found')
end

% Install own lib
addpath(cob_root);
addpath(fullfile(cob_root,'lib'));
addpath(fullfile(cob_root,'scripts'));
addpath(genpath(fullfile(cob_root,'src')));

%% Check that the needed functions are compiled
% Included in our code
needed_files = {'mex_assess_one_sel','mex_base_perimeters','mex_fast_features',...
                'mex_fast_intersections', 'mex_fast_reduction', 'mex_box_reduction',...
                'mex_get_tree_cands', 'mex_prune_tree_to_regions',...
                'mex_max_margin', 'mex_hole_filling',...
                'mex_intersect_hierarchies','mex_cands2masks','mex_cands2labels','mex_ucm2hier',...
                'paretofront',...                  % Included from paretofront
                'mexRF_train', 'mexRF_predict',... % Included from RF_Reg_C
                'convConst','gradientMex','imPadMex','imResampleMex','rgbConvertMex',... % Included from piotr_toolbox
                'buildW', 'mex_contour_sides', 'ucm_mean_pb',... % Included from BSR
                };
for ii=1:length(needed_files)
    if exist(needed_files{ii})~=3 %#ok<EXIST>
        error(['The needed function (' needed_files{ii} ') not found. Have you built the package properly?'])
    end
end

%% Clear
clear ii needed_files;
disp('-- Successful installation of COB. Enjoy! --');
