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
function [ucm2, ucms, times, O, E] = img2ucms(I, cob_parameters)

if size(I,3)==1 % Grayscale image
    I = cat(3,I,I,I);
end

if size(I,1)<15 || size(I,2)<15 % Tiny image
    % Simply return an empty UCM with the appropriate sizes
    ucm2 = zeros(2*size(I,1)+1,2*size(I,2)+1);
    ucms = repmat(ucm2,[1,1,2]);
    times = 0;
    warning(['The image you are trying to segment using COB is too small (' num2str(size(I,1)) ',' num2str(size(I,2)) '). Returning an empty UCM']);
    return
end

% Fill parameters for multiscale combination
param = cob_parameters.other_param;
[param.tx, param.ty, ~] = size(I);

% Compute ucms at multiple scales
[ucms_pre, tm, O, E] = img2ucm_scale_fast(cob_parameters.net, I, param);
tmp_times.im2ucm = tm;

% Align ucms
T=tic;
ucms = project_ucms_wrap_fast(ucms_pre, cob_parameters.align_thr);
tmp_times.project_ucms_wrap=toc(T);

% Combine ucms
param = cob_parameters.param_multi;
param.weights = ones(1,size(ucms,3));
T=tic;
ucm2 = ucms2multi(ucms, param);
tmp_times.ucms2multi=toc(T);

% Combine times
times.boundaries = tmp_times.im2ucm.edge_detect;
times.ucms       = tmp_times.im2ucm.ucm + tmp_times.project_ucms_wrap + tmp_times.ucms2multi;

function [ucm2, times, O, E] = img2ucm_scale_fast(net, I, param)


% Detect multiscale contours with a single fw pass
rng(param.rng);
T=tic;
[E,O] = cob_detect(net, I);
times.edge_detect=toc(T);

T=tic;
n_scales = length(E);
ucm2 = cell(n_scales,1);
for s=1:n_scales
    % Continuous oriented watershed transform
    [owt2, superpixels] = contours2OWT(E{s}, O.angle);
    
    % Globalization
    if param.glob,
        [ sPb_thin] = spectralPb_fast(owt2 * param.mult_Pb, param.nvec, param.ic_gamma, param.dthresh) / param.sat_sPb;
    end
    
    % Ultrametric contour map with mean pb.
    if (~param.glob)
        ucm2{s} = double(ucm_mean_pb( (owt2), superpixels) );
    else
        ucm2{s} = double(ucm_mean_pb( (owt2 + sPb_thin), superpixels) );
    end
end
times.ucm=toc(T);

%%
function ucm2 = ucms2multi(all_ucms, param)

%combine ucms
weights = param.weights;
weights = weights ./ sum(weights);

sz = size(all_ucms);
W_all = repmat(repmat(weights', [1,sz(2)]),[1,1,sz(1)]); W_all = permute(W_all, [3 2 1]);
all_ucms = all_ucms.*W_all;

ucm2_wt = sum(all_ucms,3);

labels2 = bwlabel(ucm2_wt == 0, 8);
labels = labels2(2:2:end, 2:2:end) - 1; % labels begin at 0 in mex file.
ucm2 = double(ucm_mean_pb(ucm2_wt, labels));
bw = (ucm2==0);
ucm2 = apply_sigmoid(ucm2, param.thr, param.fq);
ucm2(bw) = 0;
