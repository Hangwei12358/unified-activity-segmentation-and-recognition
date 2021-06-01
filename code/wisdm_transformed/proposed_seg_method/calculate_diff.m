% calculate the bkps difference
% by hangwei, 11-Sep-2018 13:02:39

load('skoda_data.mat');
load('combined_matrix_improved.mat');

n_frame = 5000;

bkps_true_sub = bkps_true(bkps_true <= n_frame);
bkps_true_sub = bkps_true_sub + 1;
diff = bkps_true_sub - combined_matrix(:, 4);
diff_abs = sum(abs(diff))


load('combined_matrix.mat');

diff = bkps_true_sub - combined_matrix(:, 5);
diff_abs = sum(abs(diff))


% 4115-> 3981 ->