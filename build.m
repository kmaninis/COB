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
%
% This function builds all the MEX files needed.
% Dependencies needed to build: Boost C++ libraries (http://www.boost.org)
%
% The code contains C++11 functionality, so you have to use a compiler that
% supports the flag -std=c++11.C
% Some help on how to do it in: http://jponttuset.github.io/matlab2014-mex-flags/
% ------------------------------------------------------------------------
function build()
% Check that 'cob_root' has been set
if ~exist(cob_root,'dir')
    error('Error building COB, try updating the value of cob_root in the file "cob_root.m"')
end

%% Include the generic paths and files to compile
include{1} = fullfile(cob_root, 'src', 'misc');  % To get matlab_multiarray.hpp
if (strcmp(computer(),'PCWIN64') || strcmp(computer(),'PCWIN32'))
    include{2} = 'C:\Program Files\boost_1_55_0';  % Boost libraries (change it if necessary)
else
    include{2} = '/opt/local/include/';  % Boost libraries (change it if necessary)
end
include{3} = fullfile(cob_root, 'src', 'external','piotr_toolbox'); % To build Piotr toolbox
include{4} = fullfile(cob_root, 'src', 'external'); % To build Piotr toolbox

include_str = '';
for ii=1:length(include)
    include_str = [include_str ' -I''' include{ii} '''']; %#ok<AGROW>
end

build_file{1}     = fullfile(cob_root, 'src', 'proposals'    ,'mex_assess_one_sel.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_base_perimeters.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_fast_features.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_fast_intersections.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_fast_reduction.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'bboxes'       ,'mex_box_reduction.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_get_tree_cands.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_prune_tree_to_regions.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_max_margin.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'proposals'    ,'mex_hole_filling.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_intersect_hierarchies.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_ucm2hier.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_cands2masks.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_cands2labels.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_ucm_align.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'misc'          ,'mex_ucm_rescale.cpp');
build_file{end+1} = fullfile(cob_root, 'src', 'external'     ,'paretofront','paretofront.cpp');

%% Define the compiler
gcc_compiler = 'g++';
gcc_string = ['GCC=''' gcc_compiler ''' '];

%% Build everything
if ~exist(fullfile(cob_root, 'lib'),'dir')
    mkdir(fullfile(cob_root, 'lib'))
end
            
for ii=1:length(build_file)
    eval(['mex ' gcc_string '''' build_file{ii} ''' -outdir ''' fullfile(cob_root, 'lib') '''' include_str])
end

%% Build random forest files
file1   = fullfile(cob_root, 'src', 'external', 'RF_Reg_C', 'src', 'mex_regressionRF_train.cpp');
file2   = fullfile(cob_root, 'src', 'external', 'RF_Reg_C', 'src', 'mex_regressionRF_predict.cpp');
dep1    = fullfile(cob_root, 'src', 'external', 'RF_Reg_C', 'src', 'cokus.cpp');
dep2    = fullfile(cob_root, 'src', 'external', 'RF_Reg_C', 'src', 'reg_RF.cpp');
o_file1 = fullfile(cob_root, 'lib', 'mexRF_train');
o_file2 = fullfile(cob_root, 'lib', 'mexRF_predict');

eval(['mex ' gcc_string file1 ' ' dep1 ' ' dep2 ' -output ' o_file1 ' -DMATLAB -O'])
eval(['mex ' gcc_string file2 ' ' dep1 ' ' dep2 ' -output ' o_file2 ' -DMATLAB -O'])

%% Build piotr_toolbox files
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'external','piotr_toolbox',     'convConst.cpp') ' -outdir ' fullfile(cob_root, 'lib') include_str])
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'external','piotr_toolbox',   'gradientMex.cpp') ' -outdir ' fullfile(cob_root, 'lib') include_str])
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'external','piotr_toolbox',      'imPadMex.cpp') ' -outdir ' fullfile(cob_root, 'lib') include_str])
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'external','piotr_toolbox', 'imResampleMex.cpp') ' -outdir ' fullfile(cob_root, 'lib') include_str])
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'external','piotr_toolbox', 'rgbConvertMex.cpp') ' -outdir ' fullfile(cob_root, 'lib') include_str])

%% Build BSR-related files
% 'ucm_mean_pb'
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'bsr', 'ucm_mean_pb.cpp') ' -outdir ' fullfile(cob_root, 'lib')])

% 'buildW'
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'bsr', 'buildW.cpp') ' -outdir ' fullfile(cob_root, 'lib'),...
            ' -I' fullfile(cob_root,'src','external','BSR','buildW') ' -I' fullfile(cob_root,'src','external','BSR','buildW','util'),...
            '   ' fullfile(cob_root,'src','external','BSR','buildW','smatrix.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','buildW','ic.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','buildW','affinity.cc'),...
            ])
    
% 'mex_contour_sides'
eval(['mex ' gcc_string fullfile(cob_root, 'src', 'bsr', 'mex_contour_sides.cpp') ' -outdir ' fullfile(cob_root, 'lib'),...
            ' -I' fullfile(cob_root,'src','external','BSR','include'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','concurrent','threads','child_thread.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','concurrent','threads','runnable.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','concurrent','threads','thread.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','concurrent','threads','synchronization','synchronizables','synchronizable.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','concurrent','threads','synchronization','synchronizables','unsynchronized.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_bad_cast.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_not_found.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_not_implemented.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_index_out_of_bounds.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_invalid_argument.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','ex_null_pointer_dereference.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','exception.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','exceptions','throwable.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','lang','array.cc'),...                
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','generators','rand_gen_uniform.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','sources','rand_source_default.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','sources','rand_source.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','sources','mersenne_twister_64.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','sources','rand_source_64.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','sources','system_entropy.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','random','util','randperm.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','matrices','matrix.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','matrices','exceptions','ex_matrix_dimension_mismatch.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','libraries','lib_image.cc'),...
            '   ' fullfile(cob_root,'src','external','BSR','src','math','libraries','lib_signal.cc'),...                     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','math.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','exact.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','geometry','point_2D.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','geometry','seg_intersect.cc'),...     
            '   ' fullfile(cob_root,'src','external','BSR','src','math','geometry','triangulation.cc'),...  
            '   ' fullfile(cob_root,'src','external','BSR','src','math','geometry','triangle_2D.cc'),...  
            '   ' fullfile(cob_root,'src','external','BSR','src','mlearning','clustering','clusterers','abstract','clusterer.cc'),...  
            '   ' fullfile(cob_root,'src','external','BSR','src','mlearning','clustering','clusterers','abstract','weighted_clusterer.cc'),...  
            '   ' fullfile(cob_root,'src','external','BSR','src','mlearning','clustering','clusterers','kmeans','basic_clusterer.cc'),...  
            ]);

%% Clear variables
clear build_file file1 file2 dep1 dep2 o_file1 o_file2 ii include include_str

%% Show message
disp('-- Successful compilation of COB. Enjoy! --')


