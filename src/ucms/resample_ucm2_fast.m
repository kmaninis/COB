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
function ucm2_sz = resample_ucm2_fast(ucm2, sz, mode_rescale)

if nargin<2,
    mode_rescale = 2;
end
% Get leaves segmentation
[tmp, n_sup] = bwlabel(ucm2 == 0);
labels = tmp(2:2:end,2:2:end);

% Resize leaves
lp_ucm_sz = imresize(labels,sz,'nearest');

% Transfer
% Mode: 1 - Sampling at all thresholds
%       2 - Sampling at 100 thresholds (as original method)
ucm2_sz = mex_ucm_rescale(ucm2,uint32(labels), n_sup, uint32(lp_ucm_sz), mode_rescale);




