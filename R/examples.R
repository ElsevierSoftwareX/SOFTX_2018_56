## interface C code
cat("
void get_c(double *input, int *index, double *output) {
output[0] = input[index[0] - 1];
}
",
    file = "get_c.c")
system("R CMD SHLIB get_c.c")

dyn.load(paste0("get_c", .Platform$dynlib.ext))
x <- 1:10
.C("get_c", input = as.double(x), index = as.integer(9), output = double(1))$output

x_long <- double(2^31); x_long[9] <- 9; x_long[2^31] <- -1
.C("get_c",
   input = as.double(x_long), index = as.integer(9), output = double(1))$output

library("dotCall64")
.C64("get_c", SIGNATURE = c("double", "integer", "double"),
     input = x_long, index = 9, output = double(1))$output

cat("
#include <stdint.h>
void get64_c(double *input, int64_t *index, double *output) {
output[0] = input[index[0] - 1];
}
",
    file = "get64_c.c")
system("R CMD SHLIB get64_c.c")

dyn.load(paste0("get64_c", .Platform$dynlib.ext))
.C64("get64_c", SIGNATURE = c("double", "int64", "double"),
     input = x_long, index = 2^31, output = double(1))$output

.C64("get64_c", SIGNATURE = c("double", "int64", "double"),
     INTENT = c("r", "r", "w"), input = x_long, index = 2^31, 
     output = vector_dc("numeric", 1))$output

## interface Fortran code
cat("
      subroutine get_f(input, index, output)
      double precision :: input(*), output(*)
      integer :: index
      output(1) = input(index)
      end
",
    file = "get_f.f")
system("R CMD SHLIB get_f.f")

dyn.load(paste0("get_f", .Platform$dynlib.ext))

.C64("get_f", SIGNATURE = c("double", "integer", "double"),
     input = x_long, index = 9, output = double(1))$output

file.remove("get_f.so", "get_f.o")
system("MAKEFLAGS=\"PKG_FFLAGS=-fdefault-integer-8\" R CMD SHLIB get_f.f")

dyn.load(paste0("get_f", .Platform$dynlib.ext))
.C64("get_f", SIGNATURE = c("double", "int64", "double"),
     input = x_long, index = 2^31, output = double(1))$output

.C64("get_f", SIGNATURE = c("double", "int64", "double"),
     INTENT = c("r", "r", "w"), input = x_long, index = 2^31, 
     output = vector_dc("numeric", 1))$output


## clean
file.remove("get_c.c", "get_c.o",
            paste0("get_c", .Platform$dynlib.ext),
            "get64_c.c", "get64_c.o",
            paste0("get64_c", .Platform$dynlib.ext),
            "get_f.f", "get_f.o",
            paste0("get_f", .Platform$dynlib.ext))
