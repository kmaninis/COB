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

% Read an input image
I = imread(fullfile(cob_root, 'demos','101087.jpg'));

% Compute COB proposals twice, forcing to reload parameters
[prop1, ucm1] = im2prop(I);
clear cob_params;
[prop2, ucm2] = im2prop(I);

eq_prop = isequal(prop1,prop2);
eq_ucm  = isequal( ucm1, ucm2);

if eq_prop && eq_ucm
    disp('OK: Reproducibility tests passed')
else
    disp('ERROR: Reproducibility tests not passed!!')
end

