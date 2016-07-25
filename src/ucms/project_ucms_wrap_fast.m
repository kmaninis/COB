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
function ucms_sp = project_ucms_wrap_fast(ucms,thr,mode)
% Mode: 1 - Sampling at all thresholds
%       2 - Sampling at 100 thresholds (as original method)

if nargin<3,
    mode = 2;
end

ucms_sp = zeros([size(ucms{1},1),size(ucms{1},2),numel(ucms)]);
labels2 = zeros([(size(ucms{1},1)-1)/2,(size(ucms{1},2)-1)/2,numel(ucms)]);
n_sp    = zeros(1,numel(ucms));

for d = 1:numel(ucms)
    [tmp, n_sp(d)] = bwlabel(ucms{d} <= thr);
    labels2(:,:,d) = tmp(2:2:end,2:2:end);
end

for d = 1:numel(ucms)
    ucm_sp = ucms{d};
    for u = d:-1:2
        [tmp, n_spb] = bwlabel(ucm_sp == 0);
        labels3 = tmp(2:2:end,2:2:end);
        ucm_sp = mex_ucm_align(ucm_sp, uint32(labels3), n_spb, uint32(labels2(:,:,u-1)), n_sp(u-1), mode);
    end
    ucms_sp(:,:,d) = ucm_sp;
end

