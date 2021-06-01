clear all;
clc;
tic
addpath('//home/hangwei/Documents/DataSets/ETH_series/HCI');
addpath(genpath(pwd))
load('usb_hci_guided.mat');


% remove all the columns of sensor id
tmpCol = [51; 44; 37; 30; 23; 16; 9; 2];
for kk = 1: length(tmpCol)
    usb_hci_guided(:, tmpCol(kk)) = [];
end
save('hci_hangwei.mat', 'usb_hci_guided');





