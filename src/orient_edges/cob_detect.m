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
function [E,O] = cob_detect(net, data)

% Avoid large memory consumption
maxRes = 500;
dim = size(data);
flag = 0;
if ((dim(1)*dim(2))>maxRes^2),
    warning('Resizing image to avoid large memory consumption!!')
    data = imresize(data,[maxRes,maxRes]);
    flag = 1;
end

% Image conversion to be consistent with Caffe
data = data(:,:,[3 2 1]); % Convert to BGR
data = permute(data, [2, 1, 3]); % permute width and height
data = single(data);

% mean substraction
data(:,:,1) = data(:,:,1)-104.00698793;
data(:,:,2) = data(:,:,2)-116.66876762;
data(:,:,3) = data(:,:,3) - 122.67891434;

net.blobs('data').reshape([size(data) 1]);
res = net.forward({data});

if flag,
    for i=1:length(res),
        res{i} = imresize(res{i},[dim(2) dim(1)],'nearest');
    end
end

% Orientation classes (soft map)
temp = zeros([size(res{1}') 8]);
for i=1:8,
    temp(:,:,i) = permute(res{i},[2 1]); %watch net.outputs to associate names to the correct output.
end

% Multiscale Contours (Keep the order!!)
E{1} = permute(res{10},[2 1]); % fine scale
E{2} = permute(res{9},[2 1]);  % coarse scale

% Decode the orientation
O.angle = trainedOrientation(temp);
O.conf = temp;

end
