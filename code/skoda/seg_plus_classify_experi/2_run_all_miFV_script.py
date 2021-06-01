# -*- coding: utf-8 -*-
"""
Created on Oct 3 2018

@author: hangwei
"""

import os

cwd = os.getcwd()
################################### the part that you need to modify for different data sets ############################
numRuns = 6

#########################################################################################################################
totalRuns = range(1, (numRuns + 1)) # 
name_of_methods = ['Binseg', 'BottomUp', 'KCpA', 'Pelt', 'Window', 'Dynp'] # 'Dynp'

frameFolders = []
frameStart = 'miFV_'
nowFolders = [frameStart + now_method_name  for now_method_name in name_of_methods]

for now_folder in nowFolders:
    for nowRun in totalRuns:
        frameFolders.append(now_folder+'_'+str(nowRun))        
number_subfolders = len(frameFolders)    


f_segBased = open(os.path.join(cwd, 'runAllFolders_miFV.m'), 'w+')



for nowFolder in frameFolders:
    f_segBased.write('cd ' + nowFolder + '\n')
    f_segBased.write('run miFV_skoda_imbalanced_has0.m \n')
    f_segBased.write('cd .. \n')
  


'''
## debug in a non-parallel way
for now_folder in frameFolders:
    os.chdir(now_folder)
    subprocess.call(['./smm_seg_single.sh'])
    os.chdir(cwd)

'''