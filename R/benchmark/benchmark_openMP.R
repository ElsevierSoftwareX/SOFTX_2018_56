rm(list = ls(all = TRUE))
require("dotCall64")
require("microbenchmark")
require("OpenMPController"); omp_set_num_threads(1)
mb <- microbenchmark

times <- 5
gg <- expand.grid(rep = 1:times, length = seq(34, 16, -6),
                  threads = 1:10)
gg$res <- NA
dimnames(gg)[[1]] <- paste(1:nrow(gg))
ggg <- gg[!duplicated(gg[,c("length", "threads")]),
          c("length", "threads")]
rownames(ggg) <- 1:nrow(ggg)
for(i in 1:nrow(ggg)){
    cat(i, "\n")
    gc()
    a <- numeric(2^ggg[i,"length"]-1)            
    omp_set_num_threads(ggg[i,"threads"])
    gc()
    mm <- mb(.C64("BENCHMARK", SIGNATURE = "int64", a = a,
                  INTENT = "rw", NAOK = TRUE,  PACKAGE = "dotCall64",
                  VERBOSE = 0), times = times)
    rm(a)
    gc()
    gg[gg$length == ggg[i,"length"] & gg$threads == ggg[i,"threads"], "res"] <- as.data.frame(mm)$time
}

gg$res <- gg$res / 1e9 # seconds
ggg$res <- c(unlist(by(gg$res, gg[,c("length", "threads")], mean)))

save(gg, ggg, file = "benchmark_openMP.RData")

sessionInfo()
system("head -n25 /proc/cpuinfo") # works on linux
