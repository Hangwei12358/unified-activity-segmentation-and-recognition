% preprocessing of skoda dataset; unordered and ordered  chunk and frame
% data and labels are all prepared available

clear all;
clc;
tic
addpath(genpath(pwd))
load('left_hangwei.mat');

% resample
slidWinLen = 6;
slidWinStep = 7; % results in 14Hz
leftDataSlid = [];
[tmpR, tmpC] = size(left_classall_clean);
winStart = 1;
leftInd = 1;
allLabels = [32; 48; 49; 50; 51; 52; 53; 54; 55; 56; 57];

% for k = 1:tmpR
%     winLastInd = min((winStart + slidWinLen), tmpR);
%     tmpLabel = left_classall_clean(winStart:winLastInd, 1);
%     tmp = left_classall_clean(winStart:winLastInd, 2:tmpC);
%     leftDataSlid(leftInd, 1) = mode(tmpLabel);
%     leftDataSlid(leftInd, 2:tmpC) = mean(tmp);
%     leftInd = leftInd + 1;
%     if(winLastInd == tmpR)
%         break;
%     end
%     winStart = winStart + slidWinStep;
% end
% save('leftDataSlid.mat','leftDataSlid');

% save running time, load intermediate results 
load('leftDataSlid.mat');

labelCol = leftDataSlid(:,1);
leftDataSlid(:, 1) = [];

% get rid of all NaN in data
leftDataSlid(isnan(leftDataSlid)) = 0;

% normalize all the data to be centered and ranging [0, 1]
[n_all,m_all] = size(leftDataSlid);
mean_all = mean(leftDataSlid);
std_all = std(leftDataSlid); % add a small number

leftDataSlid_std = (leftDataSlid - repmat(mean_all,[n_all,1]))./repmat(std_all,[n_all,1]);
save('leftDataSlid_std.mat', 'leftDataSlid_std', 'labelCol');
% an empirical way to calculate the sigma, by Hangwei
tmp_median = median(leftDataSlid_std);
params.sig = mean(tmp_median);


% chunk
[leftR, leftC] = size(leftDataSlid_std);
unordered_chunk = cell(1, 2);
unordered_chunk_label = [];
firstLabel = labelCol(1, 1);
chunkInd = 1;
tmpInd = 1;
for i = 2: leftR
    secondLabel = labelCol(i,1);
    if(secondLabel ~= firstLabel)
        unordered_chunk{chunkInd, 1} = leftDataSlid_std(tmpInd:(i-1), 1:leftC); 
        tmpInd = i;
        unordered_chunk{chunkInd, 2} = firstLabel;
        unordered_chunk_label(chunkInd, 1) = firstLabel;
        chunkInd = chunkInd + 1;
        firstLabel = secondLabel;
    elseif(i == leftR) % the last chunk
        unordered_chunk{chunkInd, 1} = leftDataSlid_std(tmpInd:leftR, 1:leftC);
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


% change the name to make it clearer
% skoda_chunk = unordered_chunk;
% skoda_frame = leftDataSlid_std;
% skoda_allLabels = allLabels;
% create skoda frame label and chunk label
% skoda_chunk_label = unordered_chunk_label;
% skoda_frame_label = [];

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

save('skoda_data.mat', ...
    'unordered_chunk', 'unordered_chunk_label', ...
    'unordered_frame', 'unordered_frame_label', ...
    'numFeatures', 'allLabels','bkps_true','class32','class48','class49','class50','class51','class52','class53','class54','class55','class56','class57', ...
    'sorted_chunk', 'sorted_chunk_label', ...
    'sorted_frame', 'sorted_frame_label');
save('unordered_frame.mat', 'unordered_frame');
save('bkps_true.mat','bkps_true');
toc
