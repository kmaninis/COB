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
function O = interpolateAngles(Max1,Max2,O1,O2,numClusters)

O = -ones(size(Max1));
for i=1:size(O,1),
    for j=1:size(O,2),
        flag=0;
        if (O1(i,j)==0)&&(O2(i,j)==(numClusters-1)*pi/numClusters),
            O1(i,j) = pi;
            flag=1;
        elseif (O2(i,j)==0)&&(O1(i,j)==(numClusters-1)*pi/numClusters),
            O2(i,j) = pi;
            flag=1;
        end
        if (abs(O1(i,j)-O2(i,j))== (pi/numClusters)) || (flag==1),
            if (O1(i,j)>=0) && (O2(i,j)>=0),
                O(i,j) = (Max1(i,j)*O1(i,j) + Max2(i,j)*O2(i,j))/(Max1(i,j)+Max2(i,j));
            elseif O1(i,j)>=0,
                O(i,j) = O1(i,j);
            elseif O2(i,j)>=0,
                error('Something went terribly wrong!!');
            end
        else
            O(i,j) = O1(i,j);
        end
    end
end


end