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
% ------------------------------------------------------------------------
function [contour_list, region_table, junct_map] = seg2contourlist( seg, tolerance )
if ~exist('tolerance','var')
    tolerance = 3;
end

[contour_list, region_table, junct_map] = mex_seg2contourlist(double(seg),0,tolerance);


