# written by hangwei on Aug.17.2018
# only the 1st dimension of data is used

rm(list=ls())
library(Rcpp)
library(ecp)
library(R.matlab)
library(Segmentor3IsBack)

# path <- system.file("mat-files", package="R.matlab")
# pathname <- file.path("/home/hangwei/Documents/segment_Hangwei/pDPA_baseline", "series_data.mat")  # 1000*1 dim data

data_path <- file.path(".", "unordered_frame.mat")
segments_path <- file.path(".", "bkps_true.mat")
# data_path <- file.path("/home/hangwei/Documents/segment_Hangwei/pDPA_baseline", "skoda_frame.mat")
# segments_path <- file.path("/home/hangwei/Documents/segment_Hangwei/pDPA_baseline", "bkps_true.mat")

data <- readMat(data_path)
current_data = data[["unordered.frame"]]
bkps_data <- readMat(segments_path)
current_bkps = bkps_data[["bkps.true"]]

# use a subset of data
number_ind = dim(current_data)[1]
current_mul_data = current_data[1:number_ind, 1:1] # only can handle 1-D data
current_mul_bkps = current_bkps[current_bkps < number_ind]
n_bkps = length(current_mul_bkps)


results = Segmentor(data = current_mul_data, model = 3, Kmax = n_bkps)
bkps_all = getBreaks(results)

# bkps_all[n_bkps, 1:n_bkps]

# write to txt files
write.table(bkps_all[n_bkps, 1:n_bkps], file = paste("./pDPA", toString(number_ind), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = FALSE, qmethod = c("escape", "double"),
            fileEncoding = "")

