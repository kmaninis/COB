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
function conf = interpolate_confs(confs,angle)
% confs: w x h x 8 confidence map with values in the range of [0,1]
% angle: in the range of [0,pi]

numClusters = 8;
quant_angles = 0:pi/numClusters:(numClusters-1)*pi/numClusters;
maxDist = quant_angles(2)-quant_angles(1);

if angle>quant_angles(end),
    quant_angles(1)=pi;
end

inds = knnsearch(quant_angles',angle,'K',2);
weights = (maxDist - abs(angle-quant_angles(inds)))/maxDist;
conf = weights(1)*confs(:,:,inds(1)) + weights(2)*confs(:,:,inds(2));

end
