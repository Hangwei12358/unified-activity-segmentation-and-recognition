#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Oct 30 2018
To run the codes in server, to use             time python3 ....py

This code is for contatenate results by R scripts

% previous:
This code use parallelling to run DP which cannot be conducted for a long sequence; results are stored in multiple
txts, and then the code later combines the txts into a single txt file.

@author: hangwei
"""
import os
import numpy as np
import scipy.io

import_data = scipy.io.loadmat('unordered_frame.mat')
series_data_full = import_data['unordered_frame']
import_bkps = scipy.io.loadmat('bkps_true.mat')
bkps_true_full = import_bkps['bkps_true']

results_folder = './seg_results/'
if not os.path.exists(results_folder):
    os.makedirs(results_folder)
    
now_ind = 1

number_ind =  np.shape(series_data_full)[0] # 99568 # full: 99568
n_parallel_chunk = 5000

series_data = series_data_full[1:(number_ind+1), :]
bkps_true = bkps_true_full[bkps_true_full < number_ind]
bkps_true = np.append(bkps_true, (number_ind - 1)) # the last segment is the end of data
n_bkps = len(bkps_true) - 1

now_methods = ['e_divisive', 'e_cp3o_delta', 'ks_cp3o_delta']
def combine_txts():
    results_list = []
    if number_ind > n_parallel_chunk: 
        number_chunks = int((number_ind-number_ind % n_parallel_chunk)/n_parallel_chunk + 1)
    for now_file_ind in range(1, number_chunks+1):
        now_file_name = now_method+'_'+str(number_ind)+'_'+str(now_file_ind)+'.txt'
        print(now_file_name)
        now_data = np.loadtxt(results_folder+now_file_name, dtype='int')
        if now_file_ind < number_chunks-1: # need to remove the last ind
            # results_list.append(now_data[0:now_data.shape[0]-1], axis = 0)
            results_list = np.concatenate((results_list, now_data[0:now_data.shape[0]-1]), axis = 0)
            print(now_data[0:now_data.shape[0]-1])
        else: # keep all the data
            results_list = np.concatenate((results_list, now_data), axis = 0)
            print(now_data)
    print(results_list)
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'.txt', results_list, fmt='%d')
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'.txt', results_list, fmt='%d')

for now_method in now_methods:
    combine_txts()





