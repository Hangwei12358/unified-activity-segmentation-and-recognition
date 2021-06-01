% hci original data is sorted; however I need to shuffle the chunks to make
% sure adjacent chunks do not share the same label in order to have correct
% bkps.
% make the saved variables have meaningful names

clear all;
clc;
addpath(genpath(pwd))
load('pocket_class.mat');

% the hci data and pocket data are both sorted naturally, by Hangwei, Aug.24.2018
% so I need to make the chunks with the same label to be separate in order
% to get correct bkps number; to make sure adjacent chunk don't share the
% same label
s = rng;
label_seq = (randperm(size(allLabels, 1)))';

n_class = size(allLabels, 1);
chunk_pool = cell2mat(pocketChunk(:,2)); % label for each chunk
leftChunk_pool = pocketChunk;

nowInd = 1;
unordered_chunk = cell(1,1);
unordered_ind = 1;
unordered_chunk_label = [];
unordered_frame = [];
while(size(chunk_pool, 1) ~= 0)
    disp(size(chunk_pool, 1))
    if(mod(nowInd, n_class))
        tmp_label = allLabels(label_seq(mod(nowInd, n_class)));
    else
        tmp_label = allLabels(label_seq(n_class));
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

% create ps1 frame label and chunk label
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



save('ps1_pocket_data.mat', ...
    'unordered_chunk', 'unordered_chunk_label', ...
    'unordered_frame', 'unordered_frame_label', ...
    'numFeatures', 'allLabels','bkps_true','class1','class2','class3','class4','class5', 'class6', ...
    'sorted_chunk', 'sorted_chunk_label', ...
    'sorted_frame', 'sorted_frame_label');
% save for use in python
save('unordered_frame.mat', 'unordered_frame');
save('bkps_true.mat', 'bkps_true');