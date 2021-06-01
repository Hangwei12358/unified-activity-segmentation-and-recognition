% read data from folders
clear all
clc
addpath('/home/hangwei/Documents/DataSets/PS/DataSet1');
rootPath = '/home/hangwei/Documents/DataSets/PS/DataSet1';
addpath(genpath(pwd));
% preprocessing
nowFile = 'Arm';
[arm_data, arm_str] = xlsread(strcat(nowFile, '.xlsx'));
arm_data(:, 1) = [];
arm_str(1,:) = [];
arm_str(:, 1:10) = [];
arm_label = PSFunc_getClassLabel(arm_str);

nowFile = 'Belt';
[belt_data, belt_str] = xlsread(strcat(nowFile, '.xlsx'));
belt_data(:, 1) = [];
belt_str(1,:) = [];
belt_str(:, 1:10) = [];
belt_label = PSFunc_getClassLabel(belt_str);

nowFile = 'Pocket';
[pocket_data, pocket_str] = xlsread(strcat(nowFile, '.xlsx'));
pocket_data(:, 1) = [];
pocket_str(1,:) = [];
pocket_str(:, 1:10) = [];
pocket_label = PSFunc_getClassLabel(pocket_str);

nowFile = 'Wrist';
[wrist_data, wrist_str] = xlsread(strcat(nowFile, '.xlsx'));
wrist_data(:, 1) = [];
wrist_str(1,:) = [];
wrist_str(:, 1:10) = [];
wrist_label = PSFunc_getClassLabel(wrist_str);

% check whether the dims are correct
if(length(arm_data) ~= length(arm_label) || length(belt_data) ~= length(belt_label) ||length(pocket_data) ~= length(pocket_label) ||length(wrist_data) ~= length(wrist_label))
    disp('Error: dim error!!\n');
else
    disp('Dim correct\n');
end

allLabels = (1:1:6)';

save('data_all.mat', 'allLabels','arm_data','arm_label','belt_data','belt_label','pocket_data','pocket_label','wrist_data','wrist_label');
