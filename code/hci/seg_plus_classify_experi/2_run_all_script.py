# -*- coding: utf-8 -*-
"""
Created on Oct 3 2018

@author: hangwei
"""

import os
# add packages for parallel running for loop
from joblib import Parallel, delayed
import multiprocessing
import subprocess

cwd = os.getcwd()
################################### the part that you need to modify for different data sets ############################
numRuns = 6
# NProjs = [1]
# trainRatio = str(0.7)

#########################################################################################################################
totalRuns = range(1, (numRuns + 1)) # 
# name_of_methods = ['Binseg', 'BottomUp', 'KCpA', 'Pelt', 'Window', 'Dynp'] # 'Dynp'
name_of_methods = ['e_divisive', 'ks_cp3o_delta', 'e_cp3o_delta'];  

frameFolders = []
frameStart = 'smm_'
nowFolders = [frameStart + now_method_name  for now_method_name in name_of_methods]

for now_folder in nowFolders:
    for nowRun in totalRuns:
        frameFolders.append(now_folder+'_'+str(nowRun))        
number_subfolders = len(frameFolders)    

def run_in_a_subfolder(now_folder):
    print('now:', now_folder)
    os.chdir(now_folder)
    subprocess.call(['./smm_seg_single_hci.sh'])
    os.chdir(cwd) # this line can be removed when paralleling; no difference
    
Parallel(n_jobs=-1)(delayed(run_in_a_subfolder)(now_folder = folder_ind) for folder_ind in frameFolders)



'''
## debug in a non-parallel way
for now_folder in frameFolders:
    os.chdir(now_folder)
    subprocess.call(['./smm_seg_single.sh'])
    os.chdir(cwd)

'''