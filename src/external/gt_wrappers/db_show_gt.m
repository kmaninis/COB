% ------------------------------------------------------------------------ 
%  Copyright (C)
%  ETHZ - Computer Vision Lab
% 
%  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
%  September 2015
% ------------------------------------------------------------------------ 
% This file is part of the BOP package presented in:
%    Pont-Tuset J, Van Gool, Luc,
%    "Boosting Object Proposals: From Pascal to COCO"
%    International Conference on Computer Vision (ICCV) 2015.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
function show_gt = db_show_gt(database, image_id)
    if strcmp(database,'COCO')
        % Load the ground truth and extra info
        [~, gt_set, im, anns] = db_gt( database, image_id );
        
        % Get COCO
        coco = evalin('base', ['coco_' gt_set]);
        
        % Create an invisible figure
        h = figure('Position',[0 0 size(im,2) size(im,1)]); set(h, 'Visible', 'off');
        
        % Show everything
        imagesc(im); axis('image'); set(gca,'XTick',[],'YTick',[]); set(gca, 'Position', [0 0 1 1]);
        coco.showAnns(anns);
        
        cdata = hardcopy(h, '-Dzbuffer', '-r0');
        show_gt = cdata;
        
        close(h);
    elseif strcmp(database,'Pascal')
        % Load the ground truth
        gt = db_gt( database, image_id );
        
        % Get single image GT
        gt2 = zeros(size(gt.masks{1}));
        for ii=1:length(gt.masks)
            gt2(gt.masks{ii}) = gt.category(ii);
        end
        
        % Add void
        gt2(~gt.valid_pixels) = 255;
        
        % Get colormap
        cmap = pascal_colormap();
        
        % Get RGB image
        show_gt = ind2rgb(uint8(gt2),cmap);
    elseif strcmp(database,'BSDS500')
        % Load the ground truth
        gt = db_gt( database, image_id );
        
        % Overlay all contours on one
        show_gt = zeros(size(gt{1}));
        for ii=1:length(gt)
            show_gt = show_gt + seg2bmap(gt{ii});
        end
        show_gt = uint8(255*(1-show_gt/max(show_gt(:))));
    else
        error(['Not implemented for ' database])
    end
end
