rm(list = ls())

CRAN <- "CRAN_2018-01-09"
call_pkgs <- 1872

pkgs <- list.files(CRAN)

out <- data.frame(matrix(NA, length(pkgs), 2))
colnames(out) <- c("pkg", "Rcpp")

tt <- "a"
for(i in 1:length(pkgs)){
    p <- pkgs[i]
    pname <- strsplit(p, "_")[[1]][1]
    system(paste0("tar -zxf ",
                  CRAN,"/",p,
                  " ",pname,"/DESCRIPTION"))
    d <- paste0(pname, "/DESCRIPTION")
    d2 <- paste0(pname, "/D")
    system(paste0("iconv -f utf-8 -t utf-8 -c ", d, " > ", d2))
    D <- readChar(d2, file.info(d2)$size)
    system(paste0("rm -rf ", pname))
    out[i, 1] <- pname; out[i, 2] <- grepl("Rcpp", D)
    if(tolower(substr(pname, 1, 1)) != tt){
        tt <- tolower(substr(pname, 1, 1))
        print(tt)
    }
}
sum(out$Rcpp, na.rm=T)
sum(out$Rcpp, na.rm=T)/call_pkgs

