
function cob_list(im_folder, id_file, id_start, id_end, prop_dir, box_dir, ucm_dir)
disp(['im_folder= ', im_folder])
disp(['id_file  = ', id_file])
disp(['id_start = ', num2str(id_start)])
disp(['id_end   = ', num2str(id_end)])
disp(['prop_dir = ', prop_dir])

% Read id file
fileID = fopen(id_file);
ids = textscan(fileID, '%s');
ids = ids{1};
fclose(fileID);

% Install COB
run /scratch_net/reinhold/Kevis/Software/COB/install.m

% Process only the ones selected
ids = ids(id_start:id_end);

for ii=1:length(ids)
    display(['Processing ids: ' num2str(id_start) ' to ' num2str(id_end) ' file: ' num2str(ii) ' of ' num2str(length(ids))]);
    curr_id = ids{ii};
    res_file = fullfile(ucm_dir,[curr_id '.mat']);
    
    % Are these boxes already computed?
    if ~exist(res_file, 'file')
        try
            if exist(fullfile(im_folder,[curr_id '.jpg']),'file')
                im = imread(fullfile(im_folder,[curr_id '.jpg']));
            elseif exist(fullfile(im_folder,[curr_id '.JPEG']),'file')
                im = imread(fullfile(im_folder,[curr_id '.JPEG']));
            else
                error(['Image : ' curr_id ' not found'])
            end
            
            tic;[proposals, ucm2] = im2prop(im);toc;
            
            % Proposals
            prop_save(fullfile(prop_dir,[curr_id '.mat']),proposals.superpixels,proposals.labels,proposals.scores);
            
            % Boxes
            box_save(fullfile(box_dir,[curr_id '.mat']),proposals.bboxes,proposals.bboxes_scores);
            
            % UCM
            ucm_save(fullfile(ucm_dir,[curr_id '.mat']),ucm2)
        catch ME
            disp(['ERROR: ' res_file])
            disp(ME.message)
        end
    end
end

end


function prop_save(res_file,superpixels,labels,scores) %#ok<INUSD>
save(res_file, 'superpixels','labels','scores');
end

function box_save(res_file,boxes,scores) %#ok<INUSD>
save(res_file, 'boxes','scores');
end

function ucm_save(res_file,ucm2) %#ok<INUSD>
save(res_file, 'ucm2');
end

