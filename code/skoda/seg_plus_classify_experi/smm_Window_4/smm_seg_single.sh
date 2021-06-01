#!/bin/sh 
# run single smm experiment with optimal fixed parameters

ulimit -c unlimited 
ulimit unlimited 
./smm-train -f 0 -i 0 -t 2 -l 2 -g 1 -k 10 -c 1 smm.train smmModel_g1_k10_c1.model >> train_smm_g1_k10_c1.txt
./smm-predict smm.test smmModel_g1_k10_c1.model test1_smm_g1_k10_c1.txt >> test2_smm_g1_k10_c1.txt
rm smmModel_g1_k10_c1.model
rm train_smm_g1_k10_c1.txt

