function func_smm_train_predict(now_folder)
% train and test on the segmented smm data
% by hangwei,  17-Sep-2018 15:28:41

system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/proposed_seg_method/smm_experi_exe/smm-train ./');
system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/proposed_seg_method/smm_experi_exe/smm-predict ./');
system('cp /home/hangwei/Documents/segment_Hangwei/code_final/skoda/proposed_seg_method/smm_experi_exe/smm_single.sh ./');

system('sh smm_single.sh');
cd ..
fileattrib(now_folder, '+w');


end