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

function contour_list = cont_orient(partition)

% Get contour lists at two resolutions
contour_list       = seg2contourlist(partition,0);
contour_list_simpl = seg2contourlist(partition,3);

% Check that simplification worked as expected
for ii=1:length(contour_list_simpl)
    % Check that beginning and end point coincide
    assert(isequal(contour_list(ii).contour_coords(1,:),contour_list_simpl(ii).contour_coords(1,:)))
    assert(isequal(contour_list(ii).contour_coords(end,:),contour_list_simpl(ii).contour_coords(end,:)))
    
    % Check that clist2 is a subset of clist1
    assert(all(ismember(contour_list_simpl(ii).contour_coords,contour_list(ii).contour_coords,'rows')))
end

% Sweep all segments
for ii=1:length(contour_list_simpl)
    
    % Sweep all contour pixels
    curr_pos = 1;
    contour_list(ii).orient = zeros(size(contour_list(ii).contour_coords,1),1);
    for jj=1:size(contour_list_simpl(ii).contour_coords,1)-1

        % Current segment points
        x0 = round(contour_list_simpl(ii).contour_coords(jj,1));
        y0 = round(contour_list_simpl(ii).contour_coords(jj,2));
        x1 = round(contour_list_simpl(ii).contour_coords(jj+1,1));
        y1 = round(contour_list_simpl(ii).contour_coords(jj+1,2));

        % Orientation
        alph = atan2(x1-x0, y1-y0)+pi/2;
        if alph<0
            alph = alph+pi;
        end
        if alph>pi
            alph = alph-pi;
        end

        % Fill the "full-resolution" contour
        while(~isequal(contour_list(ii).contour_coords(curr_pos,:), [x1, y1]))
            contour_list(ii).orient(curr_pos) = alph;
            curr_pos = curr_pos+1;
        end
    end
    
    % Last point as the preceding
    contour_list(ii).orient(end) = alph;
end
