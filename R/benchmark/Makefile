.PHONY: all rm tmp


RSCRIPT = ~/R/R-3.3.1/bin/Rscript
R = ~/R/R-3.3.1/bin/R
RBATCH = $(R) CMD BATCH --vanilla

all: benchmark_n1.Rout benchmark_n2_28.Rout benchmark_n2_28_w.Rout benchmark_memory.Rout benchmark_openMP.pdf 

benchmark_n1.Rout: benchmark_n1.R
	$(RBATCH) benchmark_n1.R

benchmark_n2_28.Rout: benchmark_n2_28.R
	$(RBATCH) benchmark_n2_28.R

benchmark_n2_28_w.Rout: benchmark_n2_28_w.R
	$(RBATCH) benchmark_n2_28_w.R

benchmark_memory.Rout: benchmark_memory.R
	$(RBATCH) benchmark_memory.R

benchmark_openMP.Rout benchmark_openMP.RData: benchmark_openMP.R
	$(RBATCH) benchmark_openMP.R

benchmark_openMP.pdf: benchmark_openMP.RData
	$(RBATCH) benchmark_openMP_figure.R


clean: 
	rm -f .RData .Rhistory

# rm: 
# 	rm .RData *.RData *.Rout -f
