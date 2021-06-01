% to iteratively run the bkps finding and refining process
% by Hangwei, starting from 11-Sep-2018, 17-Sep-2018, 
%% read in the dataset
clear all;
clc;
addpath(genpath(pwd))
load('ps1_pocket_data.mat');
NUM_ITER = 30;
n_frame = 160200; % 5000
min_win_size = 100;
%%
% get initial segmentation bkps from DP method
% run data_1_get_prob.m
% run data_2_decide_change.m

iterative_cost = []; % n_wrong_chunk and diff_cost, 
iterative_bkps = cell(1,1);
% iteration based on the updated bkps list
for now_iter = 1: NUM_ITER
    disp(now_iter);
    if(now_iter == 1) % intial bkps from txt file; future from mat file
        fID_initial = fopen('../seg_results/Dynp_160200.txt','r'); % 'Dynp_5000.txt', 'window1000_50.txt', 'Dynp_1000.txt'
        new_bkps_final = textscan(fID_initial, '%d');
        new_bkps_final = new_bkps_final{1,1} + 1;
    end
    [label_true_sub, now_folder] = func_generate_segments(now_iter, new_bkps_final);
    tic
    func_smm_train_predict(now_folder);
    toc
    func_get_prob(now_folder, label_true_sub);
    % update several variables
    load('prob_matrix.mat'); load('combined_matrix.mat'); load('prob_seg.mat'); 
    iterative_bkps{now_iter, 1} = combined_matrix;
    [iterative_cost(now_iter, 1), iterative_cost(now_iter, 2)] = func_diff_calculation(n_frame);
    save('iterative_cost.mat', 'iterative_cost');
    % find the index of changed bkps, and refresh the bkps list
    [iterative_bkps{now_iter, 3}, iterative_bkps{now_iter, 2}, new_bkps_final] = func_decide_change(min_win_size);    
    save('iterative_bkps.mat', 'iterative_bkps');
    % save the bkps into txt file
    dlmwrite(strcat('../seg_results/proposed_method_',num2str(n_frame),'.txt'), new_bkps_final, '\t');
    
end


