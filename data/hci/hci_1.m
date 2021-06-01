% hci original data is sorted; however I need to shuffle the chunks to make
% sure adjacent chunks do not share the same label in order to have correct
% bkps.
% make the saved variables have meaningful names

clear all;
clc;
addpath(genpath(pwd))
load('hci_hangwei.mat');

% resample
subsampleRate = 24;
slidWinStep = ceil(96/subsampleRate);
slidWinLen = slidWinStep - 1;

DataSlid = [];
[tmpR, tmpC] = size(usb_hci_guided);
winStart = 1;
leftInd = 1;
allLabels = [49; 50; 51; 52; 53];

% save running time, load intermediate results 
load('DataSlid.mat');

labelCol = DataSlid(:, 1);
DataSlid(:, 1) = [];
% get rid of all NaN in data
DataSlid(isnan(DataSlid)) = 0;
% normalize all the data to be centered and ranging [0, 1]
[n_all,m_all] = size(DataSlid);
mean_all = mean(DataSlid);
std_all = std(DataSlid); % add a small number

DataSlid_std = (DataSlid - repmat(mean_all,[n_all,1]))./repmat(std_all,[n_all,1]);
save('DataSlid_std.mat', 'DataSlid_std', 'labelCol');


% chunk
[leftR, leftC] = size(DataSlid_std);
leftChunk = cell(1, 2);
firstLabel = labelCol(1, 1);
chunkInd = 1;
tmpInd = 1;
% label_all = [];
for i = 2: leftR
    secondLabel = labelCol(i, 1);
    if(secondLabel ~= firstLabel)
        leftChunk{chunkInd, 1} = DataSlid_std(tmpInd:(i-1), 1:leftC); 
        tmpInd = i;
        leftChunk{chunkInd, 2} = firstLabel;
        % label_all(chunkInd, 1) = firstLabel;
        chunkInd = chunkInd + 1;
        firstLabel = secondLabel;
    elseif(i == leftR) % the last chunk
        leftChunk{chunkInd, 1} = DataSlid_std(tmpInd:leftR, 1:leftC);
        leftChunk{chunkInd, 2} = firstLabel;
        % label_all(chunkInd, 1) = firstLabel;
    else
        ;
    end
end

%%%% keep only 5 classes
leftChunk_5class = cell(1,1);
label_5class = [];
tmpInd = 1;
% DataSlid_std_5class = [];
for i = 1: size(leftChunk, 1)
    tmpLabel = leftChunk{i, 2};
    if(find(allLabels == tmpLabel))
        leftChunk_5class{tmpInd, 1} = leftChunk{i, 1}; % data info
        % DataSlid_std_5class = [DataSlid_std_5class; leftChunk{i, 1}];
        leftChunk_5class{tmpInd, 2} = leftChunk{i, 2}; % label info
        label_5class(tmpInd, 1) = leftChunk{i, 2};
        tmpInd = tmpInd + 1;
    else       
    end
end

% the hci data is sorted naturally
% so I need to make the chunks with the same label to be separate in order
% to get correct bkps number; to make sure adjacent chunk don't share the
% same label
s = rng;
label_seq = (randperm(size(allLabels, 1)))';
chunk_pool = label_5class;
leftChunk_pool = leftChunk_5class;
nowInd = 1;
unordered_chunk = cell(1,1);
unordered_ind = 1;
unordered_chunk_label = [];
unordered_frame = [];
while(size(chunk_pool, 1) ~= 0)
    disp(size(chunk_pool, 1))
    if(mod(nowInd, 5))
        tmp_label = allLabels(label_seq(mod(nowInd, 5)));
    else
        tmp_label = allLabels(label_seq(5));
    end

    tmp_Ind = find(chunk_pool == tmp_label, 1); % find the 1st feasible answer
    if(size(tmp_Ind, 1) == 0)
        nowInd = nowInd + 1;
        % this class has all been used
    else
        unordered_chunk{unordered_ind, 1} = leftChunk_pool{tmp_Ind, 1};
        unordered_chunk{unordered_ind, 2} = leftChunk_pool{tmp_Ind, 2};
        unordered_frame = [unordered_frame; leftChunk_pool{tmp_Ind, 1}];
        unordered_chunk_label(unordered_ind, 1) = leftChunk_pool{tmp_Ind, 2};
        unordered_ind = unordered_ind + 1;
        nowInd = nowInd + 1;
        chunk_pool(tmp_Ind, :) = [];
        leftChunk_pool(tmp_Ind, :) = [];
    end
end

% to make sure the last 2 indices have different labels, for segmentation
% problem
assert(unordered_chunk{(size(unordered_chunk, 1)-1), 2} ~= unordered_chunk{size(unordered_chunk, 1), 2});



% split different label's data into different cells
for i = 1:size(allLabels, 1)
    nowLabel = allLabels(i);
    tmpVar = strcat('class', int2str(nowLabel));
    nowInd = find(unordered_chunk_label(:,1) == allLabels(i));
    assignin('base', tmpVar, unordered_chunk(nowInd, :));
end

numFeatures = size(unordered_chunk{1,1}, 2);

% create hci frame label and chunk label
unordered_frame_label = [];
bkps_true = [];
for i = 1: size(unordered_chunk, 1)
    nowChunkLen = size(unordered_chunk{i, 1}, 1);
    unordered_frame_label = [unordered_frame_label; repmat(unordered_chunk{i, 2}, [nowChunkLen, 1])];
    if(i==1)
    bkps_true(i, 1) = nowChunkLen;
    else
    bkps_true(i, 1) = nowChunkLen + bkps_true(i-1, 1);
    end
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


save('hci_data.mat', ...
    'unordered_chunk', 'unordered_chunk_label', ...
    'unordered_frame', 'unordered_frame_label', ...
    'numFeatures', 'allLabels','bkps_true','class49','class50','class51','class52','class53', ...
    'sorted_chunk', 'sorted_chunk_label', ...
    'sorted_frame', 'sorted_frame_label');
% save for use in python
save('unordered_frame.mat', 'unordered_frame');
save('bkps_true.mat', 'bkps_true');