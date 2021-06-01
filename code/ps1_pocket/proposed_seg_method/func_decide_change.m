function [change_ind, bkps_new, new_bkps_final] = func_decide_change(min_win_size)
% decide how to change the bkps candidate locations based on prob. etc
% by hangwei, 30-Aug-2018 16:37:00, 10-Sep-2018 22:00, 

load('ps1_pocket_data.mat');
load('combined_matrix.mat');

[n_row, n_col] = size(combined_matrix);


% 1st try: consider both misclassified and low_prob

% low_prob_ind = find(combined_matrix(:, 9) < 0.1 );
% misclassify_ind = find(combined_matrix(:, 3) == 0);
% change_ind = min([low_prob_ind; misclassify_ind]);

% 2nd try: only consider low_prob indices
% low_prob_ind = find(combined_matrix(:, n_col) < 0.1); % 0.1 / 0.05

% low_prob_ind = find(combined_matrix(:, (n_col - 1)) < 0.1);
% low_prob_ind = find(combined_matrix(:, (n_col - 1)) < 0.05);

% 3rd try: based on smm prob
% low_prob_ind = find(abs(combined_matrix(:, 6)- combined_matrix(:, 7)) < 0.1 );
low_prob_ind = find(max(combined_matrix(:, 6:(n_col-2)), [], 2) < 0.5);

% based on the wrong prediction index
% low_prob_ind = find(combined_matrix(:, 3) == 0 );


change_ind = min(low_prob_ind);


[bkps_new] = find_a_bkps(change_ind, combined_matrix, time_series_data, min_win_size);
% update the bkps vector
new_bkps_final = combined_matrix(:, 5);
new_bkps_final(change_ind, 1) = bkps_new;
new_bkps_final = sort(new_bkps_final);

save('new_bkps_final.mat', 'new_bkps_final');
end


%% functions
function [best_bkps_ind] = find_a_bkps(change_ind, combined_matrix, time_series_data, min_win_size)
% define the range of the new bkps as the range till the same class's
% segments
cur_label = combined_matrix(change_ind, 1);
change_start_ind = find(combined_matrix(1:(change_ind-1), 2) == cur_label);
change_start_ind = max(change_start_ind);
change_start = combined_matrix(change_start_ind, 5);
change_end_ind = find(combined_matrix((change_ind+1):end, 2) == cur_label);
change_end_ind = min(change_end_ind) + change_ind;
change_end = combined_matrix(change_end_ind, 5);

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

if(size(best_bkps_ind, 1) > 1)
    % if multiple best_bkps_ind, then select the 1st choice
    % best_bkps_ind = best_bkps_ind(1, 1);
    rand_ind = randi(size(best_bkps_ind, 1));
    best_bkps_ind = best_bkps_ind(rand_ind);
    
end
% bkps_new = bkps_candi(best_bkps_ind, 1);

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
