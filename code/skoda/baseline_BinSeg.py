#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Apr  5 20:00:50 2018

@author: hangwei
"""
import os
import matplotlib.pyplot as plt
import ruptures as rpt
import numpy as np
import scipy.io
import pandas as pd
from collections import OrderedDict

from ruptures.metrics import randindex
from ruptures.metrics import hausdorff
from ruptures.metrics import precision_recall

# add packages for parallel running for loop
from joblib import Parallel, delayed
import multiprocessing


import_data = scipy.io.loadmat('unordered_frame.mat')
series_data_full = import_data['unordered_frame']
import_bkps = scipy.io.loadmat('bkps_true.mat')
bkps_true_full = import_bkps['bkps_true']

results_folder = './seg_results/'
if not os.path.exists(results_folder):
    os.makedirs(results_folder)



## create a dictionary to store results
results_dict = OrderedDict([('Method', 'optimal_measure'), ('cost', 0), ('Hausdorff',0), ('Rand',0), ('P',0), ('R',0)])
results_table = pd.DataFrame(data = results_dict, index = [0])
# add a new piece of results in the table
# results_table.loc[1] = ['method', 3, 0, 0, 0,0]
now_ind = 1

# use a subset of data
# number_ind =  4500 # 99568 # full: 99568
# use full data
number_ind =  np.shape(series_data_full)[0] # 99568 # full: 99568

n_parallel_chunk = 5000


series_data = series_data_full[1:(number_ind+1), :]
bkps_true = bkps_true_full[bkps_true_full < number_ind]
bkps_true = np.append(bkps_true, (number_ind - 1)) # the last segment is the end of data
n_bkps = len(bkps_true) - 1

model = "rbf"
c = rpt.costs.CostRbf()  
now_method = "Binseg"



def combine_txts():
    results_list = []
    if number_ind > n_parallel_chunk: 
        number_chunks = int((number_ind-number_ind % n_parallel_chunk)/n_parallel_chunk + 1)
    for now_file_ind in range(number_chunks):
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

def runPartData(now_chunk_ind):
    print('now:', now_chunk_ind)
    start_ind = now_chunk_ind * n_parallel_chunk + 1
    end_ind = min((now_chunk_ind + 1) * n_parallel_chunk, number_ind)
    now_series_data = series_data[(start_ind-1):(end_ind+1), :]
    now_bkps_true = bkps_true_full[ (start_ind < bkps_true_full) & (bkps_true_full < end_ind)]
    now_bkps_true = np.append(now_bkps_true, (end_ind-1))
    now_n_bkps = len(now_bkps_true) - 1
    algo = rpt.Binseg(model = model, custom_cost = c, jump = 1).fit(now_series_data)
    my_bkps = algo.predict(n_bkps=now_n_bkps)
    # add the offset
    my_bkps = [xxx + start_ind -1  for xxx in my_bkps]
    print('my_bkps:',my_bkps, 'now_bkps_true', now_bkps_true)
    # p, r = precision_recall(my_bkps, now_bkps_true)
    # results_table.loc[now_chunk_ind] = ['Dynp', c.sum_of_costs(my_bkps), hausdorff(my_bkps, now_bkps_true), randindex(my_bkps, now_bkps_true), p, r]
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'_'+str(now_chunk_ind) +'.txt', my_bkps, fmt='%d')
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'_'+str(now_chunk_ind) +'.txt', my_bkps, fmt='%d')
    # results_table.to_csv(results_folder + 'results_table_'+ now_method + '_'+ str(number_ind) + '.csv', sep = '\t')

if number_ind > n_parallel_chunk: 
    # num_cores = multiprocessing.cpu_count()
    number_chunks = int((number_ind-number_ind % n_parallel_chunk)/n_parallel_chunk + 1)
    Parallel(n_jobs=-1)(delayed(runPartData)(now_chunk_ind = i) for i in range(number_chunks))
    combine_txts()
else:
    algo = rpt.Binseg(model = model, custom_cost = c, jump = 1).fit(series_data)
    my_bkps = algo.predict(n_bkps=n_bkps)
    p, r = precision_recall(my_bkps, bkps_true)
    results_table.loc[now_ind] = ['Binseg', c.sum_of_costs(my_bkps),hausdorff(my_bkps, bkps_true), randindex(my_bkps, bkps_true), p, r]
    now_ind +=1
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'.txt', my_bkps, fmt='%d')
    np.savetxt(results_folder + now_method + '_'+ str(number_ind)+'.txt', my_bkps, fmt='%d')
    results_table.to_csv(results_folder + 'results_table_'+ now_method + '.csv', sep = '\t')

