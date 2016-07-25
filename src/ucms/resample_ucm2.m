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
function ucm2_sz = resample_ucm2(ucm2, sz)

% UCM at 'target' size
sz2 = 2*sz+1;
ucm2_sz = zeros(sz2);

% JORDI: This was the old implementation (thresholded at 100 levels)
nthresh = 100;
mx = max(ucm2(:));
thresh = linspace(mx/nthresh, mx, nthresh)';

% % JORDI: New version (super slow) to compare properly
% thresh = unique(ucm2);
% thresh(thresh==0) = [];
% nthresh = length(thresh);

old_bw = zeros((size(ucm2)-1)/2);

for t = 1 : nthresh
    bw = (ucm2 < thresh(t) );
    if ~isequal(bw, old_bw),
        labels2 = bwlabel(bw);
        seg = labels2(2:2:end, 2:2:end);
        seg = imresize(seg,sz,'nearest');
        bdry = seg2bdry(seg);
        old_bw = bw;
    end
    ucm2_sz = max(ucm2_sz, thresh(t)*bdry);
end
% toc





