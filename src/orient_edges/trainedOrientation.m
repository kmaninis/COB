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
function O = trainedOrientation(I)
numClusters = 8;
quant_angles = 0:pi/numClusters:(numClusters-1)*pi/numClusters;

[Max1,ind1] = max(I,[],3);

for ii=1:size(ind1,1),
    for jj=1:size(ind1,2),
        I(ii,jj,ind1(ii,jj))=0;
    end
end

ind1(Max1<0.01)=0;

[Max2,ind2] = max(I,[],3);
ind2(Max2<0.01)=0;

 O1 = -ones(size(ind1));
 for i=1:numClusters,
     O1(ind1==i)=quant_angles(i);
 end 
 
 O2 = -ones(size(ind2));
 for i=1:numClusters,
     O2(ind2==i)=quant_angles(i);
 end 

O = interpolateAngles(Max1,Max2,O1,O2,numClusters);
O(Max1<0.5)=-1;

% Add random values
O(O<0) = pi*rand(1,sum(O(:)<0));
