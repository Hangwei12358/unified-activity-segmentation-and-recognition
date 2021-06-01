#!/bin/sh 
# run single smm experiment with optimal fixed parameters

ulimit -c unlimited 
ulimit unlimited 
# for ecdf, 0.01, 10
# for sax, 0.1, 10
./svm-train -s 0 -t 2 -g 0.1 -c 10 svm.train svmModel.model >> train_svm_g0.1_c10.txt
./svm-predict svm.test svmModel.model test1_svm_g0.1_c10.txt >> test2_svm_g0.1_c10.txt
rm svmModel.model

