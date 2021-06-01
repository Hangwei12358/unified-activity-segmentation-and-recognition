% this script is to obtain all the optimal results of all subfolders &
% subsubfolders
% by Hangwei, 04-Oct-2018 10:49:07

clear all
clc
addpath(genpath(pwd));

test_txt_name = 'test1_svm_g0.01_c10.txt';
n_runs = 6;
numEcdfs = [5;15;30;45];
name_of_methods = {'Binseg'; 'BottomUp'; 'Dynp'; 'KCpA'; 'Pelt'; 'Window'}; 
num_methods = size(name_of_methods, 1);

results_ecdf = cell(1,1);
results_ind = 1;
for i = 1: num_methods
    for j = 1:n_runs
        now_folder_name = strcat('ecdf_', name_of_methods{i, 1}, '_', num2str(j));
        % get results from 4 subfolders
        cd(now_folder_name);
        for numEcdf = 1:size(numEcdfs, 1)
            nowEcdf = numEcdfs(numEcdf, 1);
            now_sub_folder_name = strcat('ecdf_', num2str(nowEcdf), '_experi');
            [miF_event, w_maF_event, miF_frame, w_maF_frame] = f_get_results_incNullClass_svm(now_sub_folder_name, test_txt_name);
            results_ecdf{results_ind, 1} = now_folder_name;          
            results_ecdf{results_ind, 2} = now_sub_folder_name;
            results_ecdf{results_ind, 3} = miF_event;
            results_ecdf{results_ind, 4} = w_maF_event;
            results_ecdf{results_ind, 5} = miF_frame;
            results_ecdf{results_ind, 6} = w_maF_frame;   
            results_ecdf{results_ind, 7} = strcat('ecdf_', num2str(nowEcdf), '_', name_of_methods{i, 1});   
            results_ind = results_ind + 1;
        end
        cd ..
        
    end
end 
save('results_ecdf.mat','results_ecdf');
% get the mean and std for each method
[results_table] = f_get_results_table_from_subfolders(results_ecdf, n_runs, numEcdfs);
save('results_ecdf.mat', 'results_table', '-append');


function [results_table] = f_get_results_table_from_subfolders(results_ecdf, n_runs, numEcdfs)
% learned from RESULTS_ANALYZE_SEMI_large.m
results_all_mat = cell2mat(results_ecdf(:, 3:6));
name_of_all_methods = results_ecdf(:, 7);
name_of_methods = unique(name_of_all_methods, 'stable');
numMethods = size(name_of_methods, 1);
% tmp_ind = (1:1:numMethods)';
numEachFolder = numMethods * n_runs;

indOfMethods_group = [];
for i = 1:numMethods
    now_ind = find(contains(name_of_all_methods, name_of_methods{i, 1}));
    indOfMethods_group(now_ind, 1) = repmat(i, [size(now_ind, 1), 1]); 
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



function [miF_event, w_maF_event, miF_frame, w_maF_frame] = f_get_results_incNullClass_svm(now_folder_name, test_txt_name)
% this function is migrated from accuracy_incNullClass_smm_test.m

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
class0Label = allLabels_t(1,1);
allLabels_t(1,:) = [];


allTestLabels = cell(length(allLabels_t), 1);
for i = 1:length(allLabels_t)
    allTestLabels{i, 1} = allLabels_t(i,1);
end


lengthTestLabels = length(allTestLabels);
lengthAll = length(find(label_t ~= class0Label));
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

% calculate the smm accuracy in frame
fID = fopen(test_txt_name, 'r'); 
calcu_label = textscan(fID, '%d %d');
calcu_label = double(calcu_label{1,1});

[confuMatrix, mi_frame, ma_frame] = micro_macro_PR_no0(calcu_label, label_t, proportion_each_label);
fclose(fID);
if(mi_frame.fscore > max_miF_frame)
    max_miF_frame = mi_frame.fscore;
end

if(ma_frame.fscore > max_maF_frame)
    max_maF_frame = ma_frame.fscore;
end

if(ma_frame.weighted_fscore > max_maF_weiFrame)
    max_maF_weiFrame = ma_frame.weighted_fscore;
end


first_index = 1;
 for i = 1: totalGroupNum
     trueLabelNum(i,1) = label_t(first_index, 1);
     trueLabelNum(i,2) = numGroup(i,1); % take one label each group
     last_index = first_index + numGroup(i,1) -1;
     trueLabelNum(i,3) = mode(calcu_label( first_index: last_index ,1));
     first_index = last_index + 1;
 end
predicted_tmp = trueLabelNum(:,3);
true_tmp = trueLabelNum(:,1);
true_no0 = true_tmp(find(true_tmp(:,1)~= class0Label));
lengthAll_event = length(true_no0);
proportion_each_label_event = zeros(lengthTestLabels, 2);
for theLabel = 1:length(allTestLabels)
    validRows = find(true_tmp == allTestLabels{theLabel}); 
    proportion_each_label_event(theLabel, 1) = allTestLabels{theLabel};
    proportion_each_label_event(theLabel, 2) = length(validRows)./lengthAll_event;
end
[confuMatrix_event, mi_event, ma_event] = micro_macro_PR_no0(predicted_tmp, true_tmp, proportion_each_label_event);



if(mi_event.fscore > max_miF_event)
    max_miF_event = mi_event.fscore;
end

if(ma_event.fscore > max_maF_event)
    max_maF_event = ma_event.fscore;
end

if(ma_event.weighted_fscore > max_maF_weiEvent)
    max_maF_weiEvent = ma_event.weighted_fscore;
end

% prep for the return variables % miF_event, w_maF_event, miF_frame, w_maF_frame
miF_event = max_miF_event*100;
w_maF_event = max_maF_weiEvent*100;
miF_frame = max_miF_frame*100;
w_maF_frame = max_maF_weiFrame*100;

cd ..

end



