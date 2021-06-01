% sort the prob. matrix into original time series sequence
% by Hangwei, 10-May-2018 13:46:35

clear all
clc
load('prob_matrix.mat');
load('smm_train.mat');
load('sorted_index.mat');

[n_segment, numClass] = size(prob_matrix)
% sort the prob matrix into original time series sequence
timeseries_prob_matrix = [];
timeseries_label = []; % true label, predicted label, correct prediciton or not
time_series_data = [];
original_true_label = cell2mat(chunk_seg(:, 2));
% I's value lists time series sequence of blocks naturally
% I's index lists the sorted sequence of blocks in smm format
% I(35, 1) = 2 means the 35th block in sorted manner should be the 2nd in
% time-series setting
for i = 1:n_segment
    transformedInd = find(I == i);
    timeseries_prob_matrix(i, :) = prob_matrix(transformedInd, :);
    timeseries_label(i, 1) = true_label(transformedInd, 1); 
    timeseries_label(i, 2) = calcu_label(transformedInd, 1);
    timeseries_label(i, 3) = (timeseries_label(i, 1) == timeseries_label(i, 2));
    timeseries_label(i, 4) = bkps_predict(i, 1); % ending index of a segment
    assert(timeseries_label(i, 1) == original_true_label(i, 1));
    
    time_series_data = [time_series_data; sorted_chunk_seg{transformedInd, 1}];
end

% for illustration and to find the pattern
combined_matrix = [timeseries_label timeseries_prob_matrix];
save('combined_matrix_improved.mat', 'combined_matrix', 'time_series_data');

%% plot the whole dataset
% 
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

%% plot only desired section
figure;
start_location = 4000
start_seg = 50
num_data = size(data_, 1);
plot((start_location : num_data)', data_(start_location:end, 1));
hold on
% plot the true segments
for i = start_seg : size(bkps_true_sub, 1)
    plot([bkps_true_sub(i, 1),bkps_true_sub(i, 1)], [1, 5], 'color','g');
end
% plot the predicted segments
for i = start_seg : size(bkps_predict, 1)
    plot([bkps_predict(i, 1),bkps_predict(i, 1)], [1, 5], 'color','r');
end
