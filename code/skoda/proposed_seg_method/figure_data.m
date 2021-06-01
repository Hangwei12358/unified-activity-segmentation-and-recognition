% draw figure to see trends
% by hangwei, 27-Aug-2018 21:46:15

load('unordered_frame.mat');
load('bkps_true.mat');
figure;
end_ind = 4000;

plot((1:end_ind)', unordered_frame(1:end_ind, 1));
hold on
now_bkps = bkps_true(find(bkps_true(:, 1) < end_ind), 1);
num_bkps = size(now_bkps, 1);
for i = 1:num_bkps
    plot([now_bkps(i, 1), now_bkps(i, 1)], [0, 5]);
end



