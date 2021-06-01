% this code is to generate segmented data according to segmented results to be the input of SMM
% by Hangwei, 07-May-2018 15:00:08
% this function is to get the prob. of each segment under the assumption
% that ground truth labels are available, by Hangwei, 29-Aug-2018 21:15:52

%% read in the dataset
% clear all;
% clc;
addpath(genpath(pwd))
load('skoda_data.mat');

%% read in the segmentation index
fID_segment = fopen('Dynp_5000.txt','r'); % 'Dynp_5000.txt', 'window1000_50.txt', 'Dynp_1000.txt'
str_fID = 'smm_experi';

bkps_predict = textscan(fID_segment, '%d');
bkps_predict = bkps_predict{1,1} + 1;
n_frames = max(bkps_predict);

bkps_true_sub = bkps_true(bkps_true <= max(bkps_predict));
bkps_true_sub = bkps_true_sub + 1;
% bkps_true_sub = [bkps_true_sub; n_frames];
assert(size(bkps_true_sub, 1) == size(bkps_predict, 1));
n_bkps = size(bkps_true_sub, 1);
label_true_sub = unordered_chunk_label(1:n_bkps, 1);
% generate frame labels based on predicted bkps
label_bkps_frame_predict = [];
for i = 1:n_bkps
    if(i== 1)
        start_ind = 1;
        end_ind = bkps_predict(i, 1);
    else
        start_ind = bkps_predict(i-1, 1) + 1;
        end_ind = bkps_predict(i, 1);
    end
    label_bkps_frame_predict(start_ind:end_ind, 1) = repmat(unordered_chunk_label(i, 1), [(end_ind-start_ind+1), 1]);
end
label_correction_ind = label_bkps_frame_predict == unordered_frame_label(1:n_frames, 1);
%% do PCA to accelerate the training and testing, can be removed afterwards
[pca_coeff, score, eigenvalues, ~, explained,mu] = pca(unordered_frame); %princomp also works
pcaDim = 0;
for i = 1:length(explained)
    if(sum(explained(1:i)) >= 90)
        pcaDim = i
        break;
    end
end
data_pca = score(:,1:pcaDim);

%% transform into cell-form
chunk_seg = cell(1,1);
unordered_prob_seg = [];
for i = 1:n_bkps
    if(i == 1)
        start_ind = 1;
        end_ind = bkps_predict(i, 1);
        start_ind_true = 1;
        end_ind_true = bkps_true_sub(i, 1);        
    else
        start_ind = bkps_predict(i-1, 1) + 1;
        end_ind = bkps_predict(i, 1);
        start_ind_true = bkps_true_sub(i-1, 1) + 1;
        end_ind_true = bkps_true_sub(i, 1);
    end
    chunk_seg{i, 1} = data_pca(start_ind: end_ind, :);        
    chunk_seg{i, 2} = label_true_sub(i, 1);
    unordered_prob_seg(i, 1) = double(sum(label_correction_ind(start_ind:end_ind, 1)))./double((end_ind - start_ind + 1));
    unordered_prob_seg(i, 2) = double(sum(label_correction_ind(start_ind_true:end_ind_true, 1)))./double((end_ind_true - start_ind_true + 1));

end

% %% show the difference
% figure;
% plot((1:n_frames)', unordered_frame(1:n_frames, 1));
% hold on
% for i = 1:n_bkps
%     plot([bkps_true_sub(i, 1), bkps_true_sub(i, 1)], [-5, 5], 'color', [1 0 1]); % true bkps
%     plot([bkps_predict(i, 1), bkps_predict(i, 1)], [-3, 3], 'color', [0 0 0]); % predicted bkps
% end


%% sort the cell-form to make the data of the same distribution to be in a contigeous block
[B, I] = sort(label_true_sub);
for i = 1:n_bkps
    sorted_chunk_seg{i, 1} = chunk_seg{I(i, 1), 1};
    sorted_chunk_seg{i, 2} = chunk_seg{I(i, 1), 2};
    sorted_prob_seg(i, 1) = unordered_prob_seg(I(i, 1), 1);
end
save('sorted_index.mat','I', 'bkps_predict', 'bkps_true_sub');
save('prob_seg.mat', 'sorted_prob_seg', 'unordered_prob_seg');
%% save in smm format
group_ = []; label_ = []; data_ = []; firstInd = 1;
for i = 1:n_bkps
    tmpSize = size(sorted_chunk_seg{i, 1}, 1);
    lastInd = firstInd + tmpSize - 1;
    group_(firstInd:lastInd, 1) = repmat(i, tmpSize, 1);
    label_(firstInd:lastInd, 1) = repmat(sorted_chunk_seg{i, 2}, tmpSize, 1);
    data_(firstInd:lastInd, :) = sorted_chunk_seg{i, 1};
    firstInd = lastInd + 1;
end

save('smm_train.mat', 'label_','group_','data_', 'chunk_seg', 'sorted_chunk_seg');
targetFolder = strcat('./', str_fID);
mkdir(targetFolder);
cd(targetFolder);
libsvmwrite_emp_ubicomp08('smm.train', label_, group_, sparse(data_));

%% the ground truth data in smm format for comparison
%% transform into cell-form
chunk_seg_gt = cell(1,1);
firstInd = 1;
for i = 1:n_bkps
    tmpSize = size(unordered_chunk{i, 1}, 1);
    lastInd = firstInd + tmpSize - 1;
    if(lastInd <= n_frames)
        chunk_seg_gt{i, 1} = data_pca(firstInd:lastInd, :);
        chunk_seg_gt{i, 2} = unordered_chunk{i, 2};
    else
        chunk_seg_gt{i, 1} = data_pca(firstInd: n_frames, :);
        chunk_seg_gt{i, 2} = unordered_chunk{i, 2};
    end
    firstInd = lastInd + 1;
end
%% sort the cell-form to make the data of the same distribution to be in a contigeous block
% [B, I] = sort(label_true_sub); % the same, so commented
for i = 1:n_bkps
    sorted_chunk_seg_gt{i, 1} = chunk_seg_gt{I(i, 1), 1};
    sorted_chunk_seg_gt{i, 2} = chunk_seg_gt{I(i, 1), 2};
end
%% save in smm format
group_gt = []; label_gt = []; data_gt = []; firstInd = 1;
for i = 1:n_bkps
    tmpSize = size(sorted_chunk_seg_gt{i, 1}, 1);
    lastInd = firstInd + tmpSize - 1;
    group_gt(firstInd:lastInd, 1) = repmat(i, tmpSize, 1);
    label_gt(firstInd:lastInd, 1) = repmat(sorted_chunk_seg_gt{i, 2}, tmpSize, 1);
    data_gt(firstInd:lastInd, :) = sorted_chunk_seg_gt{i, 1};
    firstInd = lastInd + 1;
end

libsvmwrite_emp_ubicomp08('smm.gt', label_gt, group_gt, sparse(data_gt));
% run smm and get the prediction with prob.
system('sh smm_single.sh');
cd ..
fileattrib(str_fID, '+w');
%% get the prob. matrix and predicted labels from smm, by hangwei, Aug.30.2018
% learn from b1_read.m
% read probabilities and true/predicted labels in the test1.txt
% by Hangwei, 10-May-2018 13:22:46

fID_all_names = fopen('./smm_experi/test1_b1.txt','r'); 
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

%%
% sort the prob. matrix into original time series sequence
% learn from b1_sort.m

% load('smm_train.mat');
% load('sorted_index.mat');

[n_segment, numClass] = size(prob_matrix_smm)
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

%%
