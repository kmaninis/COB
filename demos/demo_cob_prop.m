
%% Demo to show the results of COB Proposals
clear all;close all;home;

% Read an input image
I = imread(fullfile(cob_root,'demos','101087.jpg'));

% Compute the proposals
[proposals_cob, ucm2_cob, times] = im2prop(I);

% Display timing
fprintf('Timing: \n + Boundaries %0.3f s\n + UCMs       %0.3f s\n + Proposals  %0.3f s\n', times.boundaries, times.ucms, times.proposals)

%% Show UCM results (dilated for visualization)
figure;
subplot(1,2,1)
imshow(I), title('Image')

subplot(1,2,2)
imshow(imdilate(ucm2_cob,strel(ones(3))),[]), title('COB UCM')

%% Show Object Candidates results and bounding boxes
% Candidates in rank position 1 and 4
id1 = 1; id2 = 4;

% Get the masks from superpixels and labels
mask1 = ismember(proposals_cob.superpixels, proposals_cob.labels{id1});
mask2 = ismember(proposals_cob.superpixels, proposals_cob.labels{id2});

% Show results
% figure;
subplot(1,3,1)
imshow(I), title('Image')
subplot(1,3,2)
imshow(mask1), title('Proposal')
subplot(1,3,3)
imshow(mask2), title('Proposal')
