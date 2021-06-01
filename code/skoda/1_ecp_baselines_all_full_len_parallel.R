
rm(list=ls())

library(Rcpp)
library(ecp)
library(R.matlab)

# path <- system.file("mat-files", package="R.matlab")
# pathname <- file.path("/home/hangwei/Desktop/ecp", "series_data.mat")  # 1000*1 dim data
data_path <- file.path(".", "unordered_frame.mat")
segments_path <- file.path(".", "bkps_true.mat")

data <- readMat(data_path)
current_data = data[["unordered.frame"]]
bkps_data <- readMat(segments_path)
current_bkps = bkps_data[["bkps.true"]]

# use a subset of data
number_ind = dim(current_data)[1]
n_parallel_chunk = 5000L

current_mul_data = current_data[1:number_ind, 1:10] # 1:60
current_mul_bkps = current_bkps[current_bkps < number_ind]
n_bkps = length(current_mul_bkps)

if(number_ind > n_parallel_chunk){
  # number_chunks = int((number_ind-number_ind %% n_parallel_chunk)/n_parallel_chunk + 1)
  number_chunks = as.integer((number_ind-number_ind %% n_parallel_chunk)/n_parallel_chunk + 1 + 0.5)
  for (now_chunk in 1:number_chunks) {
    first_ind = (now_chunk-1) * 5000 + 1
    last_ind = min(number_ind, now_chunk * 5000)
    cur_chunk_data = current_data[first_ind:last_ind, 1:10]
    cur_chunk_bkps = current_mul_bkps[(first_ind < current_mul_bkps) & (current_mul_bkps < last_ind)]
    cur_chunk_bkps <- c(cur_chunk_bkps, last_ind)
    cur_chunk_n_bkps = length(cur_chunk_bkps) - 1
    y1 = e.divisive(cur_chunk_data, sig.lvl = 0.05, R = 199,  k = cur_chunk_n_bkps, min.size = 10, alpha =1)
    write.table(y1[["estimates"]], file = paste("./seg_results/e_divisive_", toString(number_ind),"_", toString(now_chunk), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
                eol = "\n", na = "NA", dec = ".", row.names = FALSE,
                col.names = FALSE, qmethod = c("escape", "double"),
                fileEncoding = "")
    print("y1 done!\n")
    y2 = e.cp3o_delta(cur_chunk_data, K = cur_chunk_n_bkps, delta = 50, alpha = 1, verbose = TRUE)
    write.table(y2[["cpLoc"]][cur_chunk_n_bkps], file = paste("./seg_results/e_cp3o_delta_", toString(number_ind),"_", toString(now_chunk), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
                eol = "\n", na = "NA", dec = ".", row.names = FALSE,
                col.names = FALSE, qmethod = c("escape", "double"),
                fileEncoding = "")
    print("y2 done\n")
    y3 = ks.cp3o_delta(cur_chunk_data, K = cur_chunk_n_bkps, minsize = 10, verbose = TRUE)
    write.table(y3[["cpLoc"]][cur_chunk_n_bkps], file = paste("./seg_results/ks_cp3o_delta_", toString(number_ind),"_", toString(now_chunk), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
                eol = "\n", na = "NA", dec = ".", row.names = FALSE,
                col.names = FALSE, qmethod = c("escape", "double"),
                fileEncoding = "")
  }
}
