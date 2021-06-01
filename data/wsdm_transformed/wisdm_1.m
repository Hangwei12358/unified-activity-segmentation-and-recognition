% by Hangwei, 04-Oct-2018 15:40:14

% deal with raw data
clear all
clc
addpath('/home/hangwei/Documents/Code_Matlab/matlab2weka');
addpath('/home/hangwei/Documents/DataSets/WISDM_ar_v1.1');
addpath(genpath(pwd));

% load weka's .arff format folder into Matlab
myPath = '/home/hangwei/Documents/DataSets/WISDM_ar_v1.1/';
fileDataset = 'WISDM_ar_v1.1_transformed.arff';
javaaddpath('/home/hangwei/Documents/Code_Matlab/weka-3-9-1/weka.jar');
wekaOBJ = loadARFF([myPath fileDataset]);
[data_raw,featureNames,targetNDX,stringVals,relationName] = weka2matlab(wekaOBJ);
% indFirstFeature = 3;
% indLastFeature = 45; 
% indSubject = 2;

% chunk based on labels
allLabels = [0;1;2;3;4;5];

labelCol = data_raw(:, 46);
data_raw(:, 46) = []; data_raw(:, 33) = []; data_raw(:, 1:2) = [];
% get rid of all NaN in data
data_raw(isnan(data_raw)) = 0;

% remove the data that has only 1 frame for a segment, added by Hangwei
ind_to_remove = [];
for i = 2:(size(labelCol, 1)-1)
    prev_label = labelCol((i-1), 1);
    now_label = labelCol(i, 1);
    next_label = labelCol((i+1), 1);
    if(prev_label ~= now_label && now_label ~= next_label)
        ind_to_remove = [ind_to_remove; i];
    end
end
labelCol(ind_to_remove, :) = [];
data_raw(ind_to_remove, :) = [];


% normalize all the data to be centered and ranging [0, 1]
[n_all,m_all] = size(data_raw);
mean_all = mean(data_raw);
std_all = std(data_raw); % add a small number
data_raw_std = (data_raw - repmat(mean_all,[n_all,1]))./repmat(std_all,[n_all,1]);

% chunk
[leftR, leftC] = size(data_raw_std);
unordered_chunk = cell(1, 2);
unordered_chunk_label = [];
firstLabel = labelCol(1, 1);
chunkInd = 1;
tmpInd = 1;
for i = 2: leftR
    secondLabel = labelCol(i,1);
    if(secondLabel ~= firstLabel)
        unordered_chunk{chunkInd, 1} = data_raw_std(tmpInd:(i-1), 1:leftC); 
        tmpInd = i;
        unordered_chunk{chunkInd, 2} = firstLabel;
        unordered_chunk_label(chunkInd, 1) = firstLabel;
        chunkInd = chunkInd + 1;
        firstLabel = secondLabel;
    elseif(i == leftR) % the last chunk
        unordered_chunk{chunkInd, 1} = data_raw_std(tmpInd:leftR, 1:leftC);
        unordered_chunk{chunkInd, 2} = firstLabel;
        unordered_chunk_label(chunkInd, 1) = firstLabel;
    else
        ;
    end
end

numFeatures = size(unordered_chunk{1,1}, 2);
unordered_frame = [];
unordered_frame_label = [];
bkps_true = [];
for i = 1:size(unordered_chunk, 1)
    nowChunkLen = size(unordered_chunk{i, 1}, 1);
    if(i==1)
        bkps_true(i, 1) = nowChunkLen;
    else
        bkps_true(i, 1) = nowChunkLen + bkps_true(i-1, 1);
    end
    unordered_frame = [unordered_frame; unordered_chunk{i, 1}];
    unordered_frame_label = [unordered_frame_label; repmat(unordered_chunk{i, 2}, [size(unordered_chunk{i, 1},1), 1])];
end


% split different label's data into different cells
for i = 1:size(allLabels, 1)
    nowLabel = allLabels(i);
    if(nowLabel < 0)
        tmpVar = strcat('classMinus', int2str(-nowLabel));
    else
        tmpVar = strcat('class', int2str(nowLabel));
    end
    nowInd = find(unordered_chunk_label(:,1) == nowLabel);
    assignin('base', tmpVar, unordered_chunk(nowInd, :));
end


% % sort the chunks to make the data of the same distribution to be in a
% contigeous block
[B, I] = sort(unordered_chunk_label);
for i = 1:size(unordered_chunk_label, 1)
    sorted_chunk{i, 1} = unordered_chunk{I(i, 1), 1};
    sorted_chunk{i, 2} = unordered_chunk{I(i, 1), 2};
end
sorted_chunk_label = [];
sorted_frame = [];
sorted_frame_label = [];
for i = 1:size(sorted_chunk, 1)
    sorted_chunk_label(i, 1) = sorted_chunk{i, 2};
    sorted_frame = [sorted_frame; sorted_chunk{i, 1}];
    sorted_frame_label = [sorted_frame_label; repmat(sorted_chunk{i, 2}, [size(sorted_chunk{i, 1},1), 1])];
end

save('wisdm_transformed_data.mat', ...
    'unordered_chunk', 'unordered_chunk_label', ...
    'unordered_frame', 'unordered_frame_label', ...
    'numFeatures', 'allLabels','bkps_true','class0','class1','class2','class3','class4','class5', ...
    'sorted_chunk', 'sorted_chunk_label', ...
    'sorted_frame', 'sorted_frame_label');
% save('skoda_data.mat', ...
%     'unordered_chunk', 'unordered_chunk_label', ...
%     'unordered_frame', 'unordered_frame_label', ...
%     'numFeatures', 'allLabels','bkps_true','class32','class48','class49','class50','class51','class52','class53','class54','class55','class56','class57', ...
%     'sorted_chunk', 'sorted_chunk_label', ...
%     'sorted_frame', 'sorted_frame_label');
% save('skoda_1.mat','sorted_skoda_chunk', 'bkps_true', 'params','skoda_frame_label','skoda_chunk_label','numFeatures','skoda_frame', 'skoda_chunk','skoda_allLabels','class32','class48','class49','class50','class51','class52','class53','class54','class55','class56','class57');
save('unordered_frame.mat', 'unordered_frame');
save('bkps_true.mat','bkps_true');





