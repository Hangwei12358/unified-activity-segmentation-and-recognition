% this script is to refine the segmentation results based on prob. matrix
% and label information
% method: search a subset of indices based on MMD
% by hangwei, 26-Jun-2018; main written July.9; 
clear all
clc
load('combined_matrix.mat');
% find the blocks of data that needs to be resampled
misclassify_ind = find(combined_matrix(:,3) == 0); 
diff_ind = [diff(misclassify_ind) == 1; 0];

% to delete the consecutive indices; only keep those separate segments
% diff_ind(3:end, :) = [];


seg_end_ind = find(diff_ind == 0);
seg_to_do= cell(1,1);
logged_seg_ind = 1; % to help to decide the sequence lengths
for i = 1:size(seg_end_ind, 1) % total number of missions
    if(seg_end_ind(i, 1) == logged_seg_ind)
        segInd = misclassify_ind(i, 1);
        seg_to_do{i, 1} = combined_matrix((segInd-2), 4); % start frame ind
        seg_to_do{i, 2} = combined_matrix((segInd+1), 4); % end frame ind
        seg_to_do{i, 3} = 2; % find 2 segments
        seg_to_do{i, 4} = combined_matrix(segInd-1:segInd+1, 1); % true labels
        seg_to_do{i, 5} = [(segInd -1); segInd];
        logged_seg_ind = logged_seg_ind + 1;
    else % multiple 0's case, do not react is the best
%         start_segInd = misclassify_ind(logged_seg_ind, 1);
%         end_segInd = misclassify_ind(seg_end_ind(i,1), 1);
%         seg_to_do{i, 1} = combined_matrix((start_segInd - 2), 4); % start frame ind
%         seg_to_do{i, 2} = combined_matrix((end_segInd + 1), 4); % end frame ind
%         seg_to_do{i, 3} = 2 + end_segInd - start_segInd; % find 2 segments
%         seg_to_do{i, 4} = combined_matrix(start_segInd-1:end_segInd + 1, 1); % true labels
%         logged_seg_ind = seg_end_ind(i, 1) + 1;
    end
end

% to re-segment the needed data
bkps_new = cell(1,1);
for i = 1:size(seg_to_do, 1) % sections that needs to be re-segment
    tic
    bkps_new{i, 1} = find_bkps(seg_to_do(i,:), combined_matrix, time_series_data);
    toc
end
% form the new segments breakpoints
new_bkps_final = combined_matrix(:, 4);
for i = 1:size(seg_to_do, 1)
    new_bkps_final(seg_to_do{i, 5}, :) = bkps_new{i, 1};
end
save('new_bkps_final.mat', 'new_bkps_final');




%% functions

function [bkps_new] = find_bkps(seg_to_do, combined_matrix, time_series_data)
    start_ind = seg_to_do{1, 1};
    end_ind = seg_to_do{1, 2};
    data = time_series_data(start_ind:end_ind, :);
    data_representative = get_data_representative(combined_matrix, time_series_data, 10);
    num_bkps = seg_to_do{1, 3};
    true_labels = seg_to_do{1, 4};
    bkps_new = zeros(num_bkps, 1);
    % form the potential candidate cases
    min_win_size = 10;
    step_size = 5;
    bkps_candi = [];
    data_tmp = cell(1,1);
    bkps_ind = 1;
    if (num_bkps == 2) % case 1: only find 2 bkps
    for firstSegInd = min_win_size:step_size:(size(data, 1)- 2*min_win_size)
        for secondSegInd = (firstSegInd+min_win_size):step_size:(size(data, 1)-min_win_size)
            data_tmp{1, 1} = true_labels(1, 1); data_tmp{1, 2} = data(1:firstSegInd, :); 
            data_tmp{2, 1} = true_labels(2, 1); data_tmp{2, 2} = data(firstSegInd+1: secondSegInd, :); 
            data_tmp{3, 1} = true_labels(3, 1); data_tmp{3, 2} = data(secondSegInd + 1:end, :); 
            bkps_candi(bkps_ind, 1) = firstSegInd;
            bkps_candi(bkps_ind, 2) = secondSegInd;
            bkps_candi(bkps_ind, 3) = cal_similarity(data_representative, data_tmp);% kernel value; cost function
            bkps_ind = bkps_ind + 1;
        end
    end
%     elseif(num_bkps == 4) % case 2: find >2 bkps
%     for firstSegInd = min_win_size:step_size:(size(data, 1)- 4*min_win_size)
%         for secondSegInd = (firstSegInd+min_win_size):step_size:(size(data, 1)-3*min_win_size)
%             for thirdSegInd = (secondSegInd+min_win_size):step_size:(size(data, 1)- 2*min_win_size)
%                 for fourthSegInd = (thirdSegInd+min_win_size):step_size:(size(data, 1) - min_win_size)
%             data_tmp{1, 1} = true_labels(1, 1); data_tmp{1, 2} = data(1:firstSegInd, :); 
%             data_tmp{2, 1} = true_labels(2, 1); data_tmp{2, 2} = data(firstSegInd+1: secondSegInd, :); 
%             data_tmp{3, 1} = true_labels(3, 1); data_tmp{3, 2} = data(secondSegInd + 1:thirdSegInd, :); 
%             data_tmp{4, 1} = true_labels(4, 1); data_tmp{4, 2} = data(thirdSegInd + 1:fourthSegInd, :); 
%             data_tmp{5, 1} = true_labels(5, 1); data_tmp{5, 2} = data(fourthSegInd + 1:end, :); 
%             
%             bkps_candi(bkps_ind, 1) = firstSegInd;
%             bkps_candi(bkps_ind, 2) = secondSegInd;
%             bkps_candi(bkps_ind, 3) = thirdSegInd;
%             bkps_candi(bkps_ind, 4) = fourthSegInd;
%             
%             bkps_candi(bkps_ind, 5) = cal_similarity(data_representative, data_tmp);% kernel value; cost function
%             bkps_ind = bkps_ind + 1;
%                 end
%             end   
%         end
%     end
    else
        disp('multiple bkpss: not yet developped well');
    end
    [max_bkps_val, max_bkps_ind] = max(bkps_candi(:, 3));
    bkps_new = (bkps_candi(max_bkps_ind, 1:num_bkps))' + start_ind;
end
    
function val = cal_similarity(data_representative, data_tmp)
    num_chunks = size(data_representative, 2) - 1; 
    tmpval = 0;
    for i = 1:size(data_tmp, 1)
        now_label = data_tmp{i, 1};
        if(now_label == 32)
        else
            nowInd = find(cell2mat(data_representative(:,1)) == now_label);
            for j = 1:num_chunks
                sum_mat = rbf_dot_deg(data_tmp{i,2},data_representative{nowInd, j+1}, 0.01); % 0.1, 0.01(better)
            % tmpval = tmpval + 1000* sum(sum(sum_mat))/(size(sum_mat, 1)* size(sum_mat, 2));
            % if(now_label == 32) % need to explore the effects of Null class importance
            %    tmpval = tmpval + 0.0 * sum(sum(sum_mat)); % 0, 0.2, 1
            % else
                    tmpval = tmpval + sum(sum(sum_mat));
            % end
            end
        end
    end
    val = tmpval;
end


function  data_representative = get_data_representative(combined_matrix, time_series_data, num_chunks);
combined_matrix_origin = combined_matrix;
allLabels = unique(combined_matrix(:, 1));
num_labels = size(allLabels, 1);
% prob_vec = max(combined_matrix(:, 5:6), [], 2);

for i = 1:num_labels
    data_representative{i, 1} = allLabels(i, 1);
    [B, I] = sort(combined_matrix(:, 4+i), 'descend');
    for j = 1:num_chunks
        now_chunk = I(j, 1);
        start_ind = combined_matrix(now_chunk - 1, 4) + 1;
        end_ind = combined_matrix(now_chunk, 4);
        data_representative{i, j+1} = time_series_data(start_ind:end_ind, :);
    end
end
end


% function [ind_and_cost] = find_a_segment(data)
%     [n_r, n_c] = size(data);
%     min_size = 2; % at least 2 frames to form a segment block
%     for i = (min_size):(n_r - min_size - 1)
%         left_data = data(1:i, :);
%         right_data = data((i+1):end, :);
%         ind_and_cost(i, 1) = i;
%         ind_and_cost(i, 2) = calculate_similarity(left_data, right_data);
%     end
% end
% function [similarity_value] = calculate_similarity(first_data, second_data)
%     
% end