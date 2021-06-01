% decide how to change the bkps candidate locations based on prob. etc
% by hangwei, 30-Aug-2018 16:37:00, 10-Sep-2018 22:00, 

% decide the change range for each bkps/or for some low confidence score's
% bkps

% clear all
% clc

min_win_size = 5;
load('combined_matrix.mat');
% load('combined_matrix_improved.mat');

% decide the addition of bkps, supervised case
% modify the 1st mistake bkps, as a simple case

low_prob_ind = find(combined_matrix(:, 9) < 0.1 );
misclassify_ind = find(combined_matrix(:, 3) == 0);

change_ind = min([low_prob_ind; misclassify_ind]);

bkps_new = find_a_bkps(change_ind, combined_matrix, time_series_data, min_win_size);
% update the bkps vector
new_bkps_final = combined_matrix(:, 5);
new_bkps_final(change_ind, 1) = bkps_new;
new_bkps_final = sort(new_bkps_final);

save('new_bkps_final.mat', 'new_bkps_final');




%% functions
function [bkps_new] = find_a_bkps(change_ind, combined_matrix, time_series_data, min_win_size)
% define the range of the new bkps as the range till the same class's
% segments
cur_label = combined_matrix(change_ind, 1);
change_start_ind = find(combined_matrix(1:(change_ind-1), 2) == cur_label);
change_start_ind = max(change_start_ind);
change_start = combined_matrix(change_start_ind, 5);
change_end_ind = find(combined_matrix((change_ind+1):end, 2) == cur_label);
change_end_ind = min(change_end_ind) + change_ind;
change_end = combined_matrix(change_end_ind, 5);

% changing_start = combined_matrix(max(1, (changing_ind -2)), 5);
% changing_end = combined_matrix(min(size(combined_matrix, 1), (changing_ind +2)), 5);
label_pool = combined_matrix(change_start_ind:change_end_ind, 1);
bkps_fix = combined_matrix([change_start_ind:(change_ind-1), (change_ind+1):change_end_ind], 5);

% loop to find 1 new bkps
bkps_candi = [];
for i = (change_start+ min_win_size):(change_end- min_win_size)
    tmp_bkps_pool = sort([bkps_fix; i]);
    bkps_candi(i, 1) = i;
    bkps_candi(i, 2) = cal_measurement(tmp_bkps_pool, time_series_data, label_pool, cur_label);
end
best_bkps_measure = max(bkps_candi(:, 2));
best_bkps_ind = find(bkps_candi(:, 2) == best_bkps_measure);
bkps_new = bkps_candi(best_bkps_ind, 1);


end

function measurement = cal_measurement(tmp_bkps_pool, time_series_data, label_pool, cur_label)
measurement = 0.0;
data_cell = cell(1,1);
for ii = 1:size(label_pool, 1)
    data_cell{ii, 1} = label_pool(ii, 1);
    if(ii == 1)
        data_cell{ii, 2} = time_series_data(1:tmp_bkps_pool(ii, 1), :);
    else
        data_cell{ii, 2} = time_series_data((tmp_bkps_pool(ii-1, 1)+1):tmp_bkps_pool(ii, 1),:);
    end
end

same_label_ind = find(label_pool == cur_label);
for jj = 1:size(same_label_ind, 1)
    for kk = (jj+1):size(same_label_ind, 1)
        measurement = measurement + sum(sum(rbf_dot_deg(data_cell{jj,2},data_cell{kk, 2}, 0.01))); % 0.1, 0.01(better)
    end
end

end



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
