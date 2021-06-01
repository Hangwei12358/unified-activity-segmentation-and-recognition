load('skoda_data.mat');

figure;
n_frames = 5000;
% num_data = size(data_, 1);
% plot((1:end_ind)', data_(1:end_ind, 1));
plot((1:n_frames)', unordered_frame_label(1:n_frames, 1), 'color', 'g');
hold on
plot((1:n_frames)', label_bkps_frame_predict(1:n_frames, 1), 'color', 'r');
% plot the true segments
for i = 1:size(bkps_true_sub, 1)
    plot([bkps_true_sub(i, 1),bkps_true_sub(i, 1)], [1, 5], 'color','g');
end
% plot the predicted segments
for i = 1:size(bkps_predict, 1)
    plot([bkps_predict(i, 1),bkps_predict(i, 1)], [1, 5], 'color','r');
end


% figure;
% num_data = size(data_, 1);
% plot((1:num_data)', data_(:, 1));
% hold on
% % plot the true segments
% for i = 1:size(bkps_true_sub, 1)
%     plot([bkps_true_sub(i, 1),bkps_true_sub(i, 1)], [1, 5], 'color','g');
% end
% % plot the predicted segments
% for i = 1:size(bkps_predict, 1)
%     plot([bkps_predict(i, 1),bkps_predict(i, 1)], [1, 5], 'color','r');
% end
