ulimit -c unlimited 
ulimit unlimited 

## with -b 0
# ./smm-train -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 100 -c 10 smm.train train_b0.model >> train_b0.txt
# ./smm-predict smm.train train_b0.model test1_b0.txt >> test2_b0.txt
# ./smm-train -f 0  -i 0 -t 2 -l 2 -g 0.01 -k 100 -c 10 smm.gt gt_b0.model >> train_b0_gt.txt
# ./smm-predict smm.gt gt_b0.model test1_b0_gt.txt >> test2_b0_gt.txt


### with -b 1
./smm-train -b 1 -f 0 -i 0 -t 2 -l 2 -g 0.01 -k 100 -c 10 smm.train train_b1.model # >> train_b1.txt

./smm-predict -b 1 smm.train train_b1.model test1_b1.txt >> test2_b1.txt


# ./smm-train -b 1 -f 0  -i 0 -t 2 -l 2 -g 0.01 -k 100 -c 10 smm.gt gt_b1.model >> train_b1_gt.txt

# ./smm-predict -b 1 smm.gt gt_b1.model test1_b1_gt.txt >> test2_b1_gt.txt

