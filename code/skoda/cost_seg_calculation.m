% to calculate the cost of segmentation results
% by hangwei, 27-Aug-2018 16:25:49
clear all
clc
addpath(genpath(pwd))
load('bkps_true.mat');
% number_ind = 10000;
% total length
number_ind = bkps_true(size(bkps_true, 1), 1);
subfolder_str = './seg_results/';
win_size = 100;

name_of_methods = {'Binseg'; 'BottomUp'; 'Dynp'; 'KCpA'; 'Pelt'; 'Window';'proposed_method'};

% Window/Pelt cannot make sure the # are the exact number

num_methods = size(name_of_methods, 1);
results_cell = cell(1,1);
for i = 1: num_methods
    now_method = name_of_methods{i, 1};
    disp(now_method)
    if(strcmp(now_method, 'Window'))
        fID_segment = fopen(strcat(subfolder_str, now_method, '_', num2str(number_ind), '_', num2str(win_size), '.txt'),'r'); % 'Dynp_5000.txt', 'window1000_50.txt', 'Dynp_1000.txt'        
    else
        fID_segment = fopen(strcat(subfolder_str, now_method, '_', num2str(number_ind), '.txt'),'r'); % 'Dynp_5000.txt', 'window1000_50.txt', 'Dynp_1000.txt'
    end
    bkps_predict = textscan(fID_segment, '%d');
    if(max(bkps_predict{1,1}) == number_ind)
        bkps_predict = double(bkps_predict{1,1});        
    else
        bkps_predict = double(bkps_predict{1,1} + 1);
    end
    
    n_frames = max(bkps_predict);

    bkps_true_sub = bkps_true(bkps_true <= max(bkps_predict));
    if(bkps_true_sub(size(bkps_true_sub, 1), 1) == n_frames)
    else    
        bkps_true_sub = double(bkps_true_sub + 1);
        bkps_true_sub = [bkps_true_sub; n_frames];
    end
    % if the # predicted bkps > # true bkps, need to random select bkps
    if(size(bkps_true_sub, 1) < size(bkps_predict, 1)) % predicted too many
        rand_ind = (randperm(size(bkps_predict, 1)))';
        bkps_predict = sort(bkps_predict(rand_ind(1:size(bkps_true_sub, 1)), 1));
        bkps_predict(size(bkps_predict, 1), 1) = n_frames;
    elseif(size(bkps_true_sub, 1) > size(bkps_predict, 1)) % predicted too few
        tmp_num = size(bkps_true_sub, 1) -  size(bkps_predict, 1);
        rand_ind = (randperm(number_ind, tmp_num))';
        bkps_predict = sort([bkps_predict; rand_ind]);
        bkps_predict(size(bkps_predict, 1), 1) = n_frames;       
    else % two numbers are the same
        ;
    end
    assert(size(bkps_true_sub, 1) == size(bkps_predict, 1));
    n_bkps = size(bkps_true_sub, 1);

    diff = bkps_true_sub - bkps_predict;
    cost_scalar = sum(abs(diff));
    results_cell{i, 1} = now_method;
    results_cell{i, 2} = cost_scalar;
    results_cell{i, 3} = diff;
    results_cell{i, 4} = rand_index(bkps_true_sub, bkps_predict);
    results_cell{i, 5} = rand_index_new(bkps_true_sub, bkps_predict);
    results_cell{i, 6} = rand_index_new2(bkps_true_sub, bkps_predict);
    results_cell{i, 7} = diff_percent(bkps_true_sub, bkps_predict);
end
disp(results_cell);
save(strcat('results_cell_len',num2str(number_ind),'_win',num2str(win_size), '.mat'), 'results_cell');


function rand_index_val = rand_index_new2(bkps_true_sub, bkps_predict)
    n_seg = size(bkps_true_sub, 1);
    n_frame = bkps_true_sub(n_seg, 1);
    true_vec = [];
    predict_vec = [];
    for i = 1:n_seg
        if(i == n_seg)
            disp(n_seg)
        end
        if(i == 1)
            start_ind_true = 1;
            start_ind_predict = 1;
        else
            start_ind_true = bkps_true_sub(i-1, 1)+1;
            start_ind_predict = bkps_predict(i-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(i, 1);
        end_ind_predict = bkps_predict(i, 1);
        true_vec(start_ind_true:end_ind_true, 1) = repmat(i,[end_ind_true - start_ind_true + 1, 1]);
        predict_vec(start_ind_predict:end_ind_predict,1) = repmat(i,[end_ind_predict - start_ind_predict + 1, 1]);
    end
    % match_mat = sparse(n_frame, n_frame);
    accu_sum = 0;
    for now_seg = 1:n_seg
        if(now_seg == 1)
            start_ind_true = 1;
        else
            start_ind_true = bkps_true_sub(now_seg-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(now_seg, 1);
        
        num_same = sum(predict_vec(start_ind_true:end_ind_true,1) ~= now_seg);
        accu_sum = accu_sum + num_same .* num_same;
    end
    rand_index_val = 1.0 - 2 * accu_sum ./(n_frame * (n_frame - 1));

end
function rand_index_val = rand_index_new(bkps_true_sub, bkps_predict)
    n_seg = size(bkps_true_sub, 1);
    n_frame = bkps_true_sub(n_seg, 1);
    true_vec = [];
    predict_vec = [];
    for i = 1:n_seg
        if(i == n_seg)
            disp(n_seg)
        end
        if(i == 1)
            start_ind_true = 1;
            start_ind_predict = 1;
        else
            start_ind_true = bkps_true_sub(i-1, 1)+1;
            start_ind_predict = bkps_predict(i-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(i, 1);
        end_ind_predict = bkps_predict(i, 1);
        true_vec(start_ind_true:end_ind_true, 1) = repmat(i,[end_ind_true - start_ind_true + 1, 1]);
        predict_vec(start_ind_predict:end_ind_predict,1) = repmat(i,[end_ind_predict - start_ind_predict + 1, 1]);
    end
    % match_mat = sparse(n_frame, n_frame);
    accu_sum = 0;
    for now_seg = 1:n_seg
        if(now_seg == 1)
            start_ind_true = 1;
        else
            start_ind_true = bkps_true_sub(now_seg-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(now_seg, 1);
        
        num_same = sum(predict_vec(start_ind_true:end_ind_true,1) == now_seg);
        accu_sum = accu_sum + num_same .* num_same;
%         for i = start_ind_true:end_ind_true
%             for j = i: end_ind_true % n_frame % end_ind_true
%                 if(true_vec(i, 1) == predict_vec(j, 1))
%                     accu_sum = accu_sum + 1;
%                 end
%             end
%         end
    end
    rand_index_val = 2 * accu_sum ./(n_frame * (n_frame - 1));

end
    

function rand_index_val = rand_index(bkps_true_sub, bkps_predict)
    n_seg = size(bkps_true_sub, 1);
    n_frame = bkps_true_sub(n_seg, 1);
    true_vec = [];
    predict_vec = [];
    for i = 1:n_seg
        if(i == n_seg)
            disp(n_seg)
        end
        if(i == 1)
            start_ind_true = 1;
            start_ind_predict = 1;
        else
            start_ind_true = bkps_true_sub(i-1, 1)+1;
            start_ind_predict = bkps_predict(i-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(i, 1);
        end_ind_predict = bkps_predict(i, 1);
        true_vec(start_ind_true:end_ind_true, 1) = repmat(i,[end_ind_true - start_ind_true + 1, 1]);
        predict_vec(start_ind_predict:end_ind_predict,1) = repmat(i,[end_ind_predict - start_ind_predict + 1, 1]);
    end
    % match_mat = sparse(n_frame, n_frame);
    accu_sum = 0;
    for now_seg = 1:n_seg
        if(now_seg == 1)
            start_ind_true = 1;
        else
            start_ind_true = bkps_true_sub(now_seg-1, 1)+1;
        end
        end_ind_true = bkps_true_sub(now_seg, 1);
        for i = start_ind_true:end_ind_true
            for j = i: end_ind_true % n_frame % end_ind_true
                if(true_vec(i, 1) == predict_vec(j, 1))
                    accu_sum = accu_sum + 1;
                end
            end
        end
    end
    rand_index_val = 2 * accu_sum ./(n_frame * (n_frame - 1));

end

function diff_percent_val = diff_percent(bkps_true_sub, bkps_predict)
    n_seg = size(bkps_true_sub, 1);
    n_frame = bkps_true_sub(n_seg, 1);
    diff = bkps_true_sub - bkps_predict;
    cost_scalar = sum(abs(diff));
    diff_percent_val = cost_scalar ./ (n_seg * n_frame);
end

