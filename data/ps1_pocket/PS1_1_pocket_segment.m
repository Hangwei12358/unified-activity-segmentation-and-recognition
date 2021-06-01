% segment the data based on the paper
% every 2 seconds i.e., every 100 frames -> 1 segment
% output: cells
% chunk for every 100 frames, not based on labels

clear all
clc
load('data_all.mat');
nowDataPos = 'pocket';

label_all = [];
chunkSize = 100;
% pocket
[pocketR, pocketC] = size(pocket_data);
pocketChunk = cell(1, 2);
chunkInd = 1;
tmpInd = 1;
for i = 1: ceil(pocketR/chunkSize)
    tmpIndStart = chunkSize*(i-1)+1;
    tmpIndEnd = min(chunkSize*(i), pocketR);
    tmpLabels = pocket_label(tmpIndStart:tmpIndEnd, 1);
    tmpUniqueLabel = unique(tmpLabels);
    tmpLength = tmpIndEnd - tmpIndStart; 
    if(length(tmpUniqueLabel) == 1 && tmpLength == 99) % all 100 frames have the same label
        pocketChunk{tmpInd, 1} = pocket_data(tmpIndStart:tmpIndEnd, :);
        pocketChunk{tmpInd, 2} = tmpUniqueLabel; % label info
        label_all(tmpInd, 1) = tmpUniqueLabel;
        tmpInd = tmpInd + 1;
    else % the 100 frames have different labels, then discard the chunk
    end
end

% remove some class 6's chunks to make sure the near chunks enjoy different
% labels
% added by hangwei, 28-Sep-2018 
pocketChunk(1603:1614, :) = [];
label_all(1603:1614, :) = [];


% split different label's data into different cells
for i = 1:size(allLabels, 1)
    nowLabel = allLabels(i);
    tmpVar = strcat(nowDataPos, '_class', int2str(nowLabel));
    nowInd = find(label_all(:,1) == nowLabel);
    assignin('base', tmpVar, pocketChunk(nowInd, :));
end

save(strcat(nowDataPos,'_class.mat'), 'nowDataPos', 'pocketChunk','allLabels','pocket_class1','pocket_class2','pocket_class3','pocket_class4','pocket_class5','pocket_class6');



