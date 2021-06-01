# if permission denied, add sudo to run the .sh file

for d in */; do cp smm-predict "$d"; done
for d in */; do cp smm-train "$d"; done
for d in */; do cp smm_seg_single_skoda.sh "$d"; done

## not working properly; use matlab code to copy to all sub sub folders as an alternative solution
# for d in ecdf*/; do cp -r svm-predict "$d"; done
# for d in ecdf*/; do cp -r svm-train "$d"; done
# for d in ecdf*/; do cp -r svm_single.sh "$d"; done




