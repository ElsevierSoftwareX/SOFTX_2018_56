rm(list = ls(all = TRUE))
require("dotCall64")
require("microbenchmark"); mb <- microbenchmark
require("OpenMPController"); omp_set_num_threads(1)


## functions to print latex tables with brackets
Round <- function(x, k) format(round(x, k), nsmall=k)
xxtab <- function(x, b, digits){
    x <- Round(x, digits)
    b <- paste0(" (", Round(b, digits), ") ", c(rep("& ", length(b)-1), "\\\\"))
    paste(c(rbind(x, b)), collapse = "")
}
xxxtab <- function(xmat, bmat, digits = 1){
    for(i in 1:nrow(xmat))
        cat(xxtab(xmat[i,], bmat[i,], digits = digits) , "\n")
}
## xxtab(1:5, 6:10, 3)
## xxxtab(array(1:4, c(2,2))/7,array(1:4, c(2,2))+10 /7, 2)


## read / read and write -------------------------------------------
times <- 100
len <- 2^28

fd_mb <- mb(
    .C("BENCHMARK", a = numeric(len), NAOK = TRUE,
       PACKAGE = "dotCall64"),
    .C64("BENCHMARK", SIGNATURE = "double", a = numeric(len),
         INTENT = "rw", NAOK = TRUE, PACKAGE = "dotCall64", VERBOSE = 0),
    .C64("BENCHMARK", SIGNATURE = "double", a = numeric_dc(len),
         INTENT = "w", NAOK = TRUE,  PACKAGE = "dotCall64", VERBOSE = 0),
    times = times)
fd_df <- as.data.frame(fd_mb)
levels(fd_df$expr) <- c(".C", ".C64", ".C64w")
fd_median <- c(unlist(by(fd_df[[2]], fd_df[[1]], median)))
fd_IQR <- c(unlist(by(fd_df[[2]], fd_df[[1]], IQR)))


fi_mb <- mb(
    .C("BENCHMARK", a = integer(len), NAOK = TRUE,
       PACKAGE = "dotCall64"),
    .C64("BENCHMARK", SIGNATURE = "integer", a = integer(len),
         INTENT = "rw", NAOK = TRUE, PACKAGE = "dotCall64", VERBOSE = 0),
    .C64("BENCHMARK", SIGNATURE = "integer", a = integer_dc(len),
         INTENT = "w", NAOK = TRUE,  PACKAGE = "dotCall64", VERBOSE = 0),
    times = times)
fi_df <- as.data.frame(fi_mb)
levels(fi_df$expr) <- c(".C", ".C64", ".C64w")
fi_median <- c(unlist(by(fi_df[[2]], fi_df[[1]], median)))
fi_IQR <- c(unlist(by(fi_df[[2]], fi_df[[1]], IQR)))

fi64_mb <- mb(
    .C64("BENCHMARK", SIGNATURE = "int64", a = numeric(len),
         INTENT = "rw", NAOK = TRUE, PACKAGE = "dotCall64", VERBOSE = 0),
    .C64("BENCHMARK", SIGNATURE = "int64", a = numeric_dc(len),
         INTENT = "w", NAOK = TRUE, PACKAGE = "dotCall64", VERBOSE = 0),
              times = times)
fi64_df <- as.data.frame(fi64_mb)
levels(fi64_df$expr) <- c(".C64", ".C64w")
fi64_median <- c(unlist(by(fi64_df[[2]], fi64_df[[1]], median)))
fi64_IQR <- c(unlist(by(fi64_df[[2]], fi64_df[[1]], IQR)))


tab <- round(rbind(fd_median, fi_median,
                   fi64_median = fi64_median[c(NA,1,2)]) / 1e9, 2)
tabIQR <- round(rbind(fd_IQR, fi_IQR, fi64_IQR = fi64_IQR[c(NA,1,2)]) / 1e9, 2)
tab
tabIQR

## units: seconds
xxxtab(tab, tabIQR, 2)

sessionInfo()
system("head -n25 /proc/cpuinfo")  ## works on Linux
