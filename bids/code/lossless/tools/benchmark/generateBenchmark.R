# Set R Library path and install readr library
dir.create(file.path(getwd(),"analysis/support/tools/R_Packages"), showWarnings = FALSE)
.libPaths(file.path(getwd(),"analysis/support/tools/R_Packages"))
if (!file.exists("analysis/support/tools/R_Packages/.utils.exists")) {
    install.packages("R.utils",repos = "http://cran.us.r-project.org")
    file.create("analysis/support/tools/R_Packages/.utils.exists")
}
library(R.utils)
if (!isPackageInstalled("readr")) install.packages("readr",repos = "http://cran.us.r-project.org")
if (!isPackageLoaded("readr")) library(readr)

# Create benchmark.out file
outFile = "analysis/support/tools/benchmark/benchmark.out"
if (!file.exists(outFile)) file.create(outFile,'w') 
sink(outFile, append=FALSE, split=FALSE)

# Read from benchmark.csv file
benchmark <- read_delim("analysis/support/tools/benchmark/benchmark.csv","\t", escape_double = FALSE, trim_ws = TRUE)
benchmark$script=as.factor(benchmark$script)
benchmark$scheduler=as.factor(benchmark$scheduler)
factors = split(benchmark, list(benchmark$scheduler, benchmark$script))

# Create a summary of the linear regression
lapply(factors, function(j) {
  summary(lm(j$memory_MB~ j$chans + j$samples))
})
lapply(factors, function(j) {
  summary(lm(j$elapsed_time~ j$chans + j$samples))
})
system ("echo '\n--- DONE: generateBenchmark ---\n'") 
