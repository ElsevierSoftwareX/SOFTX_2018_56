rm(list = ls(all = TRUE))
require("dotCall64")
require("microbenchmark")
require("xtable"); options(xtable.NA.string = "--")
require("OpenMPController"); omp_set_num_threads(1)
mem <- function(...){
    ## measure peak memory usage with gctorture()
    
    exprs <- c(as.list(match.call(expand.dots = FALSE)$...))
    exprnm <- sapply(exprs, function(e) paste(deparse(e), collapse = " "))

    ## give names
    nm <- names(exprs)
    if (is.null(nm))
        nm <- exprnm
    else nm[nm == ""] <- exprnm[nm == ""]

    n <- length(exprs)

    out <- data.frame(expr = rep(NA, n), mem.peak = rep(NA, n),
                      mem.end = rep(NA, n))
    out[, "expr"] <- nm
    for(i in 1:n){
        mem.before <- gc(reset=TRUE)[2,2]
        gctorture(TRUE)
        eval(exprs[[i]])
        gctorture(FALSE)
        gc.report <- gc()
        mem.max <- gc.report[2,6]
        mem.after <- gc.report[2,2]
        out[i, "mem.peak"] <- mem.max - mem.before
        out[i, "mem.end"]<- mem.after - mem.before
    }
    out
}

## table memory usage ---
len <- 2^27
num <- numeric(len)
int <- integer(len)


mfd0 <- expression({
    .C("BENCHMARK", a = num, NAOK = FALSE, PACKAGE = "dotCall64")
})
mfd_rw <- expression({
    .C64("BENCHMARK", "double", a = num, INTENT = "rw",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfd_r <- expression({
    .C64("BENCHMARK", "double", a = num, INTENT = "r",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfd0C <- expression({
    .C("BENCHMARK", a = numeric(len), NAOK = FALSE, PACKAGE = "dotCall64")
})
mfd_w <- expression({
    .C64("BENCHMARK", "double", a = numeric_dc(len), INTENT = "w",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
fd_mm <- mem(eval(mfd0), eval(mfd_rw), eval(mfd_r), eval(mfd0C), eval(mfd_w))


mfi0 <- expression({
    .C("BENCHMARK", a = int, NAOK = FALSE, PACKAGE = "dotCall64")
})
mfi_rw <- expression({
    .C64("BENCHMARK", "integer", a = int, INTENT = "rw",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfi_r <- expression({
    .C64("BENCHMARK", "integer", a = int, INTENT = "r",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfi0C <- expression({
    .C("BENCHMARK", a = integer(len), NAOK = FALSE, PACKAGE = "dotCall64")
})
mfi_w <- expression({
    .C64("BENCHMARK", "integer", a = integer_dc(len), INTENT = "w",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
fi_mm <- mem(eval(mfi0), eval(mfi_rw), eval(mfi_r), eval(mfi0C), eval(mfi_w))


mfi64_rw <- expression({
    .C64("BENCHMARK", "int64", a = num, INTENT = "rw",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfi64_r <- expression({
    .C64("BENCHMARK", "int64", a = num, INTENT = "r",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})
mfi64_w <- expression({
    .C64("BENCHMARK", "int64", a = numeric_dc(len), INTENT = "w",
         NAOK = FALSE, PACKAGE = "dotCall64", VERBOSE = 0)
})

fi64_mm <- mem(eval(mfi64_rw), eval(mfi64_r), eval(mfi64_w))


tab_mem <- rbind(fd_mm$mem.peak / mem(double(len))$mem.peak,
                 fi_mm$mem.peak / mem(integer(len))$mem.peak,
                 c(fi64_mm$mem.peak / mem(double(len))$mem.peak)[c(NA,1,2,NA,3)]) 
tab_mem <- data.frame(tab_mem)
colnames(tab_mem) <- c(".C()", ".C64(rw)", ".C64(r)",
                       ".C()", ".C64(w NAOK)")
tab_mem

xtable(tab_mem, digits = 0)

sessionInfo()
system("head -n25 /proc/cpuinfo")  ## works on Linux
