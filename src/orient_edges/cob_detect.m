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
data = single(data);

% mean values of each channel: [R G B H H A]
mval = [122.67891434 116.66876762 104.00698793 134.0313 92.0228 117.3808];

% Avoid large memory consumption
maxRes = 500;
dim = size(data);
flag = 0;
if ((dim(1)*dim(2))>maxRes^2)
    warning('Resizing image to avoid large memory consumption!!')
    data = imresize(data,[maxRes,maxRes]);
    flag = 1;
end

% mean substraction
for ch=1:dim(3)
    data(:,:,ch) = data(:,:,ch) - mval(ch);
end

% Image conversion to be consistent with Caffe
if dim(3)==3
    data = data(:,:,[3 2 1]); % Convert to BGR (RGB case)
elseif dim(3)==6
    data = data(:,:,[3 2 1 6 5 4]); % Convert to BGR-AHH (RGBD case)
else
    error('Something is wronf with the input data.')
end
data = permute(data, [2, 1, 3]); % permute width and height


net.blobs('data').reshape([size(data) 1]);
res = net.forward({data});

if flag
    for i=1:length(res)
        res{i} = imresize(res{i},[dim(2) dim(1)],'nearest');
    end
end

% Orientation classes (soft map)
temp = zeros([size(res{1}') 8]);
for i=1:8
    temp(:,:,i) = permute(res{i},[2 1]); %watch net.outputs to associate names to the correct output.
end

% Multiscale Contours (Keep the order!!)
E{1} = permute(res{10},[2 1]); % fine scale
E{2} = permute(res{9},[2 1]);  % coarse scale

% Decode the orientation
O.angle = trainedOrientation(temp);
O.conf = temp;

end
