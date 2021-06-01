function func_get_prob(now_folder, label_true_sub)
% this function is to obtain the prob. matrix / confidence score of the new
% bkps situation
% by hangwei, 17-Sep-2018 15:34:17

% get the prob. matrix and predicted labels from smm, by hangwei, Aug.30.2018
% learn from b1_read.m
% read probabilities and true/predicted labels in the test1.txt
% by Hangwei, 10-May-2018 13:22:46

load('hci_data.mat');
load('prob_seg.mat');
load('sorted_index.mat');
load('smm_train.mat');

fID_all_names = fopen( strcat('./', now_folder, '/test1_b1.txt'),'r'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the data in cells
numClass = size(unique(label_true_sub),1);
numInputCol = numClass + 2;
inputStr = repmat('%s ', [1, numInputCol]);

all_contents = textscan(fID_all_names, inputStr);
fclose(fID_all_names);
% detele the first 2 rows
[~, n_col] = size(all_contents);
[n_row, ~] = size(all_contents{1,1});
true_label_smm = str2num(cell2mat(all_contents{1,1}(3:end)));
calcu_label_smm = str2num(cell2mat(all_contents{1, 2}(3:end)));
prob_matrix_smm = [];
for i = 3:n_row
    for j = 1:numClass
       prob_matrix_smm(i, j) = str2num(cell2mat(all_contents{1, (j+2)}(i, 1)));
    end
end
prob_matrix_smm(1:2, :) = [];
save('prob_matrix.mat', 'prob_matrix_smm','true_label_smm','calcu_label_smm');


[n_segment, numClass] = size(prob_matrix_smm);
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
    timeseries_prob_matrix(i, :) = prob_matrix_smm(transformedInd, :);
    timeseries_label(i, 1) = true_label_smm(transformedInd, 1); 
    timeseries_label(i, 2) = calcu_label_smm(transformedInd, 1);
    timeseries_label(i, 3) = (timeseries_label(i, 1) == timeseries_label(i, 2));
    timeseries_label(i, 4) = bkps_true_sub(i, 1); % ending index of ground truth
    timeseries_label(i, 5) = bkps_predict(i, 1); % ending index of a segment
    assert(timeseries_label(i, 1) == original_true_label(i, 1));    
    time_series_data = [time_series_data; sorted_chunk_seg{transformedInd, 1}];
end

% for illustration and to find the pattern
combined_matrix = [timeseries_label timeseries_prob_matrix unordered_prob_seg];
save('combined_matrix.mat', 'combined_matrix', 'time_series_data');


end
