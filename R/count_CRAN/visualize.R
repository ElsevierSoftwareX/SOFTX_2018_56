rm(list = ls(all = TRUE))
require(VennDiagram)
args <- commandArgs(FALSE)
print(args)
ll <- read.csv(sub("-", "", args[length(args)]))
n <- nrow(ll)
rownames(ll) <- ll[,1]
ll <- ll[,-1]
names(ll) <- paste0(".", names(ll), "()")

summary(ll)
summary(ll>0)
ll[apply(ll, 2, which.max),]
 
bll <- ll>0

tt <- apply(bll, 2, sum)
sum(tt[1:2])
sum(tt)
sum(tt[1:2])/sum(tt)

apply(bll, 2, mean)
ftable(xtabs(~., data=bll),row.vars=1:4)


vv <- venn.diagram((lapply(as.data.frame(bll), which)[c(2,3,1,4)]),
                   filename = NULL,
                   cat.fontfamily = "mono", fontfamily = rep("mono", 15),
                   cex = 1.5, cat.cex = 1.7,
                   fill = rep(c("lightblue", "lightgoldenrod1"), 2))
pdf("venn.pdf", width = 10, height = 5)
grid.draw(vv)
dev.off()

## require(gplots)
## venn( as.data.frame(bll))

bsimple <- data.frame(ffi = bll[,1] | bll[,2],
                      mic = bll[,3] | bll[,4])
ftable(xtabs(~., data=bsimple),row.vars=1:2)
round(xtabs(~., data=bsimple>0)/n*100)






