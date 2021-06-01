% this script is to generate data for ECDF feature extraction and SVM classification under various segmentation
% results.
% learn from experi_smm_classify_with_various_seg.m
% by Hangwei, 18-Oct-2018 17:13:54

clear all
clc
addpath(genpath(pwd));

numEcdfs = [5;15;30;45];

subfolder_str = './seg_results/';

% name_of_methods = {'Binseg'; 'BottomUp'; 'KCpA'; 'Pelt'; 'Window'; 'Dynp'};
name_of_methods = {'Binseg'; 'BottomUp'; 'KCpA'; 'Pelt'; 'Window'; 'Dynp'};


num_methods = size(name_of_methods, 1);
for i = 1: num_methods
    now_method = name_of_methods{i, 1};
numRuns = 6;

experi_folder_str = './seg_plus_classify_experi'
cd(experi_folder_str);

for tmpFolderIndn = 1: numRuns    
    tmpFolderInd = int2str(tmpFolderIndn)
    tmpFolderPath = strcat('ecdf_', now_method, '_', tmpFolderInd);

    cd(tmpFolderPath);

for nowInd_ecdf = 1:length(numEcdfs)  % modified by hangwei, 10-Sep-2017 11:25:26
    nowMoment = numEcdfs(nowInd_ecdf, 1);
    nowFolder = strcat('ecdf_',num2str(nowMoment), '_experi');
    cd(nowFolder);


system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/seg_plus_classify_experi/svm-train ./');
system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/seg_plus_classify_experi/svm-predict ./');
system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/seg_plus_classify_experi/svm_single.sh ./');


cd ..
% fileattrib(tmpFolderPath, '+w'); % remove the writing permission of the whole folder
end 
cd ..
end
cd ..
end




