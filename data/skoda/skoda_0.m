clear all;
clc;
tic
% % read data from .dat file
addpath('//home/hangwei/Documents/DataSets/ETH_series/SkodaMiniCP');
addpath(genpath(pwd))
% if nargin == 0 %the function was called without arguments, , ITE_code_dir is set to the current directory
%     ITE_code_dir = pwd;
% end
% addpath(genpath(ITE_code_dir));
% if nargin == 0 %the function was called without arguments, ITE_code_dir is set to the current directory
%     ITE_code_dir = pwd;
% end
% rmpath(genpath(ITE_code_dir));
%load('dataset_cp_2007_12.mat'); % segmented data, not include class 0 (class 32 in this case)
load('left_classall_clean.mat');
load('right_classall_clean.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% at this time only use left info

% remove all the columns of sensor id
tmpCol = [65; 58; 51; 44; 37; 30; 23; 16; 9; 2];
for kk = 1: length(tmpCol)
    left_classall_clean(:, tmpCol(kk)) = [];
end
save('left_hangwei.mat', 'left_classall_clean');





