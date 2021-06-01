% this script is to obtain all the optimal results of all subfolders
% by Hangwei, 04-Oct-2018 10:49:07

clear all
clc
addpath(genpath(pwd));

test_txt_name = 'test1_smm.txt';
n_runs = 6;
% name_of_methods = {'Binseg'; 'BottomUp'; 'Dynp'; 'KCpA'; 'Pelt'; 'Window'; 'proposed_method'}; % 
name_of_methods = {'e_divisive'; 'ks_cp3o_delta'; 'e_cp3o_delta'};  

num_methods = size(name_of_methods, 1);

results_seg_classify = cell(1,1);
results_ind = 1;
for i = 1: num_methods
    for j = 1:n_runs
        now_folder_name = strcat('smm_', name_of_methods{i, 1}, '_', num2str(j));
        [miF_event, w_maF_event, miF_frame, w_maF_frame] = f_get_results_noNullClass(now_folder_name, test_txt_name);
        results_seg_classify{results_ind, 1} = now_folder_name;
        results_seg_classify{results_ind, 2} = miF_event;
        results_seg_classify{results_ind, 3} = w_maF_event;
        results_seg_classify{results_ind, 4} = miF_frame;
        results_seg_classify{results_ind, 5} = w_maF_frame;   
        results_ind = results_ind + 1;
    end
end 
save('results_seg_classify.mat','results_seg_classify');

% get the mean and std for each method
[results_table] = f_get_results_table(results_seg_classify, n_runs, name_of_methods);
save('results_seg_classify.mat', 'results_table', '-append');




function [results_table] = f_get_results_table(results_seg_classify, n_runs, name_of_methods)
% learned from RESULTS_ANALYZE_SEMI_large.m
results_all_mat = cell2mat(results_seg_classify(:, 2:5));
numMethods = size(name_of_methods, 1);
tmp_ind = (1:1:numMethods)';
numEachFolder = numMethods * n_runs;

% generate group indices
indOfMethods_group = [];
for i = 1:numMethods
    indOfMethods_group = [indOfMethods_group; repmat(tmp_ind(i, 1), [n_runs, 1])];
end

firstInd = 1;
lastInd = numEachFolder;
firstInd_result = 1;
lastInd_result = numMethods;
results_mean = splitapply(@mean, results_all_mat(firstInd:lastInd,:), indOfMethods_group(firstInd:lastInd,:)); % by hangwei, nice
results_std =  splitapply(@std, results_all_mat(firstInd:lastInd,:), indOfMethods_group(firstInd:lastInd,:));

% show results in table
miF_s = results_mean(:, 1);
maF_s = results_mean(:, 2);
miF_f = results_mean(:, 3);
maF_f = results_mean(:, 4);
miF_s_std = results_std(:, 1);
maF_s_std = results_std(:, 2);
miF_f_std = results_std(:, 3);
maF_f_std = results_std(:, 4);
results_table = table(miF_s, maF_s, miF_f, maF_f,miF_s_std, maF_s_std, miF_f_std, maF_f_std, 'RowNames',name_of_methods)

end

function [miF_event, w_maF_event, miF_frame, w_maF_frame] = f_get_results_noNullClass(now_folder_name, test_txt_name)
% this function is migrated from accuracy_noNullClass_smm_test.m
% calculate the accuracy in frame of smm
cd(now_folder_name);
load('test.mat');

% as the labels in test data might not be all the labels in the train data
%%%%%%%%%%%%%%get the labels in test data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allLabels_t = [];
ind = 1;
for i = 1:length(label_t)
    tmp_label = label_t(i);
    a = find(allLabels_t == tmp_label);
    if (length(a) > 0)
        ;
    else
        allLabels_t(ind, 1) = tmp_label;
        ind = ind + 1;
    end
end
[B, I] = sort(allLabels_t);
allLabels_t = B;
% class0Label = allLabels_t(1,1);
% allLabels_t(1,:) = [];


allTestLabels = cell(length(allLabels_t), 1);
for i = 1:length(allLabels_t)
    allTestLabels{i, 1} = allLabels_t(i,1);
end

lengthTestLabels = length(allTestLabels);
lengthAll = length(label_t);
proportion_each_label = zeros(lengthTestLabels, 1);
for theLabel = 1:length(allTestLabels)
    validRows = find(label_t == allTestLabels{theLabel}); 
    proportion_each_label(theLabel, 1) = allTestLabels{theLabel};
    proportion_each_label(theLabel, 2) = length(validRows)./lengthAll;
end

max_miF_frame = 0;
max_maF_frame = 0;
max_maF_weiFrame = 0;
max_miF_event = 0;
max_maF_event = 0;
max_maF_weiEvent = 0;

% find total number of labels in test data:
totalGroupNum = max(group_t);
numGroup = zeros(totalGroupNum, 1); % each group's number of instances

for i = 1: totalGroupNum
    tmp = find(group_t == i);
    numGroup(i,1) = length(tmp);
end
 
trueLabelNum = zeros(totalGroupNum, 2);
first_index = 1;
for i = 1: totalGroupNum
    trueLabelNum(i,1) = label_t(first_index, 1);
    trueLabelNum(i,2) = numGroup(i,1); % take one label each group
end

fID_smm = fopen(test_txt_name, 'r');
fgets(fID_smm); 
calcu_label_smm = textscan(fID_smm, '%d %d');
true_label_event = calcu_label_smm{1,1};
predict_label_event = calcu_label_smm{1,2};

if (size(calcu_label_smm{1,1}, 1) == 0)
    ;
else
 % true_label_event_no0 = true_label_event(true_label_event(:,1));
lengthAll_event = length(true_label_event);
proportion_each_label_event = zeros(lengthTestLabels, 1);
for theLabel = 1:length(allTestLabels)
    validRows = find(true_label_event == allTestLabels{theLabel}); 
    proportion_each_label_event(theLabel, 1) = allTestLabels{theLabel};
    proportion_each_label_event(theLabel, 2) = length(validRows)./lengthAll_event;
end

% the input should be the have-0 predicted/true labels
[~, mi_event, ma_event] = micro_macro_PR_WISDM(predict_label_event, true_label_event, proportion_each_label_event);

if(mi_event.fscore > max_miF_event)
    max_miF_event = mi_event.fscore;
end

if(ma_event.fscore > max_maF_event)
    max_maF_event = ma_event.fscore;
end

if(ma_event.weighted_fscore > max_maF_weiEvent)
    max_maF_weiEvent = ma_event.weighted_fscore;
end
fclose(fID_smm);

tmp_frame = 0;
predict_label_frame = zeros(size(label_t));
frameInd = 1;
for i = 1 : totalGroupNum
    tmpGroupNum = trueLabelNum(i,2);
    tmpPredictLabel = calcu_label_smm{1,2}(i);
    tmpTrueLabel = calcu_label_smm{1,1}(i);
    predict_label_frame(frameInd:(frameInd + tmpGroupNum-1),1) = double(repmat(tmpPredictLabel, tmpGroupNum ,1));
    frameInd = frameInd + tmpGroupNum;
    
    if tmpPredictLabel == tmpTrueLabel
        tmp_frame = tmp_frame + tmpGroupNum;
    end
end
tmp_frame
accuracy_smm = tmp_frame./length(group_t) * 100
[~, mi_frame, ma_frame] = micro_macro_PR_WISDM(predict_label_frame, label_t, proportion_each_label);

if(mi_frame.fscore > max_miF_frame)
    max_miF_frame = mi_frame.fscore;
end

if(ma_frame.fscore > max_maF_frame)
    max_maF_frame = ma_frame.fscore;
end

if(ma_frame.weighted_fscore > max_maF_weiFrame)
    max_maF_weiFrame = ma_frame.weighted_fscore;
end
end

% prep for the return variables % miF_event, w_maF_event, miF_frame, w_maF_frame
miF_event = max_miF_event*100;
w_maF_event = max_maF_weiEvent*100;
miF_frame = max_miF_frame*100;
w_maF_frame = max_maF_weiFrame*100;

cd ..
end

