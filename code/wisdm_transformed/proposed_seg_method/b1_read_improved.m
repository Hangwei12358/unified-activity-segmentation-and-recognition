% read probabilities and true/predicted labels in the test1.txt
% by Hangwei, 10-May-2018 13:22:46

clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% params that may need to specify for specific applications %%%%%%%%
numClass = 2; % 7
fID_all_names = fopen('test1_b1_iter1.txt','r'); % 'test1_b1_dynp_5000', 'test1_b1_window.txt', 'test1_b1_dynp.txt'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the data in cells
numInputCol = numClass + 2;
inputStr = repmat('%s ', [1, numInputCol]);

all_contents = textscan(fID_all_names, inputStr);
fclose(fID_all_names);
% detele the first 2 rows
[~, n_col] = size(all_contents);
[n_row, ~] = size(all_contents{1,1});
true_label = str2num(cell2mat(all_contents{1,1}(3:end)));
calcu_label = str2num(cell2mat(all_contents{1, 2}(3:end)));
prob_matrix = [];
numClass = n_col - 2;

for i = 3:n_row
    for j = 1:numClass
       prob_matrix(i, j) = str2num(cell2mat(all_contents{1, (j+2)}(i, 1)));
    end
end
prob_matrix(1:2, :) = [];
save('prob_matrix.mat', 'prob_matrix','true_label','calcu_label');
