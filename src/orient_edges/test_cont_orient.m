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

% Read one partition
partition = db_gt('BSDS500','12003');
partition = partition{1};

% Get the orientations of the contours
[contour_list, ori_map, ori_quant] = cont_orient(partition);

%% Show the results
r = 5;
space = 10;
imshow(seg2bmap(partition),[])
hold on

X=[];Y=[];U=[];V=[];
for ii=1:length(contour_list)
    for jj=1:space:length(contour_list(ii).orient)
        X=[X, (contour_list(ii).contour_coords(jj,2)+1)/2];
        Y=[Y, (contour_list(ii).contour_coords(jj,1)+1)/2];
        U=[U, r*cos(contour_list(ii).orient(jj))];
        V=[V, r*sin(contour_list(ii).orient(jj))];
    end
    ii; 
end

quiver(X,Y,U,V,0,'r.'); quiver(X,Y,-U,-V,0,'r.');

