function [n_wrong_chunk, diff_abs] = func_diff_calculation(n_frame)
% this function is to calculate the sum of distance of true bkps to
% predicted bkps
% calculate the bkps difference
% by hangwei, 11-Sep, 20-Sep-2018 14:17:10

load('hci_data.mat');
load('combined_matrix.mat');

% bkps_true_sub = bkps_true(bkps_true <= n_frame);
% bkps_true_sub = bkps_true_sub + 1;

% diff = bkps_true_sub - combined_matrix(:, 5);
diff = combined_matrix(:, 4) - combined_matrix(:, 5);
diff_abs = sum(abs(diff))

n_wrong_chunk = size(find(combined_matrix(:, 3) == 0), 1);


end
