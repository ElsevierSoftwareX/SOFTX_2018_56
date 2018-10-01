SHELL := /bin/bash
.PHONY: clean rm

R := R
RBATCH := $(R) CMD BATCH --vanilla

DATE := $(shell date "+%Y-%m-%d")
CRAN_DIR := CRAN_$(DATE)
PYTHON_OUT := run_$(DATE).txt


all: venn.pdf clean

venn.pdf: $(PYTHON_OUT)
	$(RBATCH) -$(PYTHON_OUT) visualize.R 

$(PYTHON_OUT): $(CRAN_DIR) analyze.py
	python analyze.py ./$(CRAN_DIR)/ > $(PYTHON_OUT)

$(CRAN_DIR): 
	mkdir -p $(CRAN_DIR)
	rsync -tlzv cran.r-project.org::CRAN/src/contrib/\*.tar.gz $(CRAN_DIR)

clean: 
	rm -rf $(CRAN_DIR) .Rhistory .RData *.log
