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
function cob_params = set_params(im)

if ~exist('im','var')
    im=zeros(1,1,3);
end

% Set the parameters below
if ~evalin('base','exist(''cob_params'',''var'')')
    disp('Setting COB parameters')
    
    % For CPU mode, set to 0
    cob_params.useGPU = 0;
    
    % Set the ID of your GPU (default 0)
    cob_params.gpu_id = 0;
    
    % Specify /path/to/caffe (needed for matcaffe)
    cob_params.caffe_path = '/scratch_net/reinhold_second/test/hed_cpu/matlab/';
    if ~exist(cob_params.caffe_path,'dir')
        error(['Caffe path ''' cob_params.caffe_path ''' not found'])
    end
    addpath(genpath(cob_params.caffe_path));
    
    % Network model
    cob_params.model = fullfile(cob_root,'models','deploy.prototxt');
    % Network weights
    cob_params.weights = fullfile(cob_root,'models','COB_PASCALContext_trainval.caffemodel');
    
    if size(im,3)==6
        cob_params.model = fullfile(cob_root,'models','deploy_rgbhha.prototxt');
        cob_params.weights = fullfile(cob_root,'models','COB_NYUD-v2_RGBHHA.caffemodel');
    end
    
    if ~exist(cob_params.weights,'file')
        error('a:b',['caffemodel file ''' cob_params.weights ''' not found.\nPlease visit ''http://www.vision.ee.ethz.ch/~cvlsegmentation/cob/code.html'' to download it.'])
    end
    
    % Create net and load weights
    cob_params.net = caffe.Net(cob_params.model, cob_params.weights, 'test');
    
    
    % Multiscale parameters
    cob_params.param_multi.thr       = 0.8; % 0.35 in MCG;
    cob_params.param_multi.fq        = 4;   % 8 in MCG;
    
    % Alignment threshold
    cob_params.align_thr             = 0.05; % 0.1 in MCG
    
    % Other parameters
    cob_params.other_param.glob      = 0;   % Globalization or not
    cob_params.other_param.mult_Pb   = 10;
    cob_params.other_param.sat_sPb   = 60;
    cob_params.other_param.nvec      = 6;
    cob_params.other_param.dthresh   = 2;
    cob_params.other_param.ic_gamma  = 0.12;
    cob_params.other_param.rng = loadvar(fullfile(cob_root,'models','rand_num_gen.mat'),'rand_num_gen');
    
    % Copy to base workspace
    assignin('base', 'cob_params', cob_params);
    
    % For GPU users
    if cob_params.useGPU
        evalin('base', 'caffe.set_mode_gpu()');
        evalin('base', 'caffe.set_device(cob_params.gpu_id)')
    end
    
else
    % Recover the parameters
    cob_params = evalin('base', 'cob_params');
end



