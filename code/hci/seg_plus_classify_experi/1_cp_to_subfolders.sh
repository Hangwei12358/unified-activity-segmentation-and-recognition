# if permission denied, add sudo to run the .sh file

for d in */; do cp smm-predict "$d"; done
for d in */; do cp smm-train "$d"; done
for d in */; do cp smm_seg_single_hci.sh "$d"; done




