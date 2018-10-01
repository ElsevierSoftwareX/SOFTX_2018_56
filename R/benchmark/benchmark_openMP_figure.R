rm(list = ls(all = TRUE))
require(RColorBrewer)
require(scales)
require(plyr)
load("benchmark_openMP.RData")
colo <- rev(brewer.pal(5, "Set1"))[-4]
gg$col <- colo[((gg$length-min(gg$length)))/6 +1]

mat <- array(ggg$res, c(4, 10))
pch <- c(0, 1, 4, 5)
pdf("benchmark_openMP.pdf", 4.3, 4)
par(mai = c(.6, .97, 0.2, 0.2))
plot(gg$threads, log(gg$res, 2), col = "white",
     xaxt = "n", yaxt = "n",     
     xlab = "", ylab = "", pch = 1, cex= 1.2,
     xlim = c(.9, 10.1))
mtext("Number of threads", 1, 2)
mtext("Elapsed time [s]", 2, 2.8)
abline(v = seq(1, 9, 2), col = "gray90")
# abline(v = seq(1, 9, 4), col = "gray80")
abline(h = seq(-8,8,2), col = "gray90")
# abline(h = seq(-8,8,4), col = "gray80")
points(gg$threads, log(gg$res, 2), col = alpha(gg$col, .5),
       pch = rep(pch, each = 5), cex = 1)
matplot(t(log(mat, 2)), type = "l", col = colo, add = TRUE,
        lty =1, lwd = 1.5)
axis(1, at = seq(1, 12, 4))
axis(2, at = seq(-8, 8, 4),
     lab = expression(frac(1, 256), frac(1, 16), 1, 16, 256),
     las = 2)
box()
dev.off()

pdf("benchmark_openMP_legend.pdf", 9, 6)
frame()
legend(x=.3, y = 1,
       legend = expression(2^34*phantom(A)~128~Gb,
                           2^28*phantom(oorr)~2~Gb,
                           2^22*phantom(Ao)~32~Mb,
                           2^16*phantom(A)~512*phantom(ji)*Kb),
       lty = 1, pch = pch, title.adj = 0,
       col = rev(colo), title = "Vector length / size",
       bg = "white", box.lwd=0, box.col="white", cex = 2.5, pt.cex = 3.5,
       lwd = 3)
dev.off()

gg <- ddply(gg, c("length"), function(x){
    mean0 <- rep(x[x$threads == 1, "res"], length(unique(x$threads))) 
    x$rel <- x$res / mean0
    x
})
mat1 <- mat / array(mat[,1], dim = dim(mat))
round(mat1[,10]*100)

pdf("benchmark_openMP_relative.pdf", 4.3, 4)
par(mai = c(.6, .97, 0.2, 0.2))
plot(gg$threads, log(gg$rel, 2), col = "white",
     xaxt = "n", yaxt = "n", xlim = c(.9, 10.1),     
     xlab = "", ylab = "", pch = 1, cex= 1)
mtext("Number of threads", 1, 2)
mtext("Relative elapsed time", 2, 3.6)
abline(v = seq(1, 9, 2), col = "gray90")
# abline(v = seq(1, 9, 4), col = "gray80")
abline(h = seq(-1, 4, 0.5), col = "gray90")
# abline(h = seq(-2, 4, 1), col = "gray90")
abline(h = 0, col = "black", lty = 2)
points(gg$threads, log(gg$rel, 2), col = alpha(gg$col, .5),
       pch = rep(rev(pch), each = 50), cex = 1)
matplot(log(t(mat1), 2), type = "l", col = colo, add = TRUE,
        lty = 1, lwd = 1.5)
axis(1, at = seq(1, 12, 4))
axis(2, at = seq(-2, 4, 1),
     lab = paste0(2**(seq(-2, 4, 1)) * 100, "%"),
     las = 2)
box()
dev.off()
