% this code is to generate segmented data according to segmented results to be the input of SMM
% by Hangwei, 07-May-2018 15:00:08

%% read in the dataset
clear all;
clc;
tic
addpath(genpath(pwd))
load('/home/hangwei/Documents/segment_Hangwei/data/skoda/skoda_data.mat');
load('/home/hangwei/Documents/segment_Hangwei/data/skoda/bkps_true.mat');

%% read in the segmentation index
str_fID = 'smm_experi_improved';
load('new_bkps_final.mat');

bkps_predict = new_bkps_final;
n_frames = max(bkps_predict);

bkps_true_sub = bkps_true(bkps_true <= max(bkps_predict));
bkps_true_sub = bkps_true_sub + 1;
% bkps_true_sub = [bkps_true_sub; n_frames];
assert(size(bkps_true_sub, 1) == size(bkps_predict, 1));
n_bkps = size(bkps_true_sub, 1);
label_true_sub = unordered_chunk_label(1:n_bkps, 1);

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
for i = 1:n_bkps
    if(i == 1)
        chunk_seg{i, 1} = data_pca(1:bkps_predict(1,1), :);
    else
        chunk_seg{i, 1} = data_pca((bkps_predict(i-1,1)+ 1): bkps_predict(i, 1), :);
    end
    chunk_seg{i, 2} = label_true_sub(i, 1);
end
%% sort the cell-form to make the data of the same distribution to be in a contigeous block
[B, I] = sort(label_true_sub);
for i = 1:n_bkps
    sorted_chunk_seg{i, 1} = chunk_seg{I(i, 1), 1};
    sorted_chunk_seg{i, 2} = chunk_seg{I(i, 1), 2};
end
save('sorted_index.mat','I', 'bkps_predict', 'bkps_true_sub');

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
cd ..
fileattrib(str_fID, '+w');
%%


