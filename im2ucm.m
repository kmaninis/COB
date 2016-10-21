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
% This function computes the COB UCM (Ultrametric Contour Map) given an image.
%  INPUT:
%  - image : Input image
%
%  OUTPUT:
%  - ucm2     : Global Ultrametric Contour Map
%  - ucms     : Ultrametric Contour Maps from different scales
%  - times    : Elapsed times on each part
%  - O.angle  : Contour orientations at each pixel
%    O.conf   : Confidence of each pixel being in one of the 8 bins of
%               orientation
%  - E        : Edges (coarse and fine)
%
%  DEMO:
%  - See demos/demo_cob_ucm.m
% 
%  NOTE:
%  - If you are also going to compute the proposals, you can reuse the
%    UCM returned by im2prop
% ------------------------------------------------------------------------
function [ucm2, ucms, times, O, E] = im2ucm(image)

% Adjust your paths and parameters in this file
cob_params = set_params(); 

% Get the hierarchies at each scale and the global hierarchy
[ucm2, ucms, times, O, E] = img2ucms(image, cob_params);

