
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
current_mul_data = current_data[1:number_ind, 1:10] # 1:48
current_mul_bkps = current_bkps[current_bkps < number_ind]
n_bkps = length(current_mul_bkps)

# set.seed(100)
# x1 = matrix(c(rnorm(100),rnorm(100,3),rnorm(100,0,2)))
# y1 = e.divisive(X=x1,sig.lvl=0.05,R=199,k=NULL,min.size=30,alpha=1)
# x2 = rbind(MASS::mvrnorm(100,c(0,0),diag(2)),
#            MASS::mvrnorm(100,c(2,2),diag(2)))
# y2 = e.divisive(X=x2,sig.lvl=0.05,R=499,k=NULL,min.size=30,alpha=1)

y1 = e.divisive(current_mul_data, sig.lvl = 0.05, R = 199,  k = n_bkps, min.size = 10, alpha =1)

y2 = e.cp3o_delta(current_mul_data, K = n_bkps, delta = 10, alpha = 1, verbose = TRUE)

y3 = ks.cp3o_delta(current_mul_data, K = n_bkps, minsize = 10, verbose = TRUE)

# y1[["estimates"]]
write.table(y1[["estimates"]], file = paste("./e_divisive", toString(number_ind), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = FALSE, qmethod = c("escape", "double"),
            fileEncoding = "")


# y2[["cpLoc"]][n_bkps]
write.table(y2[["cpLoc"]][n_bkps], file = paste("./e_cp3o_delta", toString(number_ind), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = FALSE, qmethod = c("escape", "double"),
            fileEncoding = "")
# show immediate results
# y3[["cpLoc"]][n_bkps]
# write to txt files   paste("./kscp3o_delta", toString(number_ind), ".txt", sep = "")
write.table(y3[["cpLoc"]][n_bkps], file = paste("./ks_cp3o_delta", toString(number_ind), ".txt", sep = ""), append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = FALSE, qmethod = c("escape", "double"),
            fileEncoding = "")
