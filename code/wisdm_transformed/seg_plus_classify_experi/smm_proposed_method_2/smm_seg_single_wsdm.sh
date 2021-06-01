#!/bin/sh 
# run single smm experiment with optimal fixed parameters

ulimit -c unlimited 
ulimit unlimited 
./smm-train -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 10 -c 1 smm.train smmModel.model >> train_smm.txt
./smm-predict smm.test smmModel.model test1_smm.txt >> test2_smm.txt
rm smmModel.model
rm train_smm.txt

