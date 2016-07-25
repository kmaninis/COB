%% Check timings
clear all;close all;clc;

% Read an input image
I = imread(fullfile(cob_root,'demos','101087.jpg'));

% Compute the proposals
[~, ~, times] = im2prop(I);
fprintf('Timing: \n + Boundaries %0.3f s\n + UCMs       %0.3f s\n + Proposals  %0.3f s\n', times.boundaries, times.ucms, times.proposals)

% Compute the proposals
[~, ~, times] = im2prop(I);
fprintf('Timing: \n + Boundaries %0.3f s\n + UCMs       %0.3f s\n + Proposals  %0.3f s\n', times.boundaries, times.ucms, times.proposals)

% Compute the proposals
[~, ~, times] = im2prop(I);
fprintf('Timing: \n + Boundaries %0.3f s\n + UCMs       %0.3f s\n + Proposals  %0.3f s\n', times.boundaries, times.ucms, times.proposals)

% Compute the proposals
[~, ~, times] = im2prop(I);
fprintf('Timing: \n + Boundaries %0.3f s\n + UCMs       %0.3f s\n + Proposals  %0.3f s\n', times.boundaries, times.ucms, times.proposals)
