
$(info **** amica15 Makefile ****)
$(info )
$(info OPTIONS:)
$(info -	STATIC=1	use -static flag)
$(info **************************)
$(info )

# Enables ifort if not set as the openmpi fortran compiler
ifndef OMPI_FC
  OMPI_FC=ifort 
endif

# If ifort doesn't exist throw and error
ifeq ($(shell which ifort),)
  $(error ifort is not found in the path)
endif

# Checks for version of intel compiler for -openmp flag
# -qopenmp or -openmp
INTELMAJ:=$(shell ifort --version | tr '[:space:]' ' ' | cut -d' ' -f 3 \
  | grep -Poe '[0-9]+' | head -n1)

# If using other verision of ifort you may need to alter this
# code as the author is unsure of which version they switched
# from -openmp to -qopenmp
ifeq ($(shell [ $(INTELMAJ) -ge 16 ] && echo true),true)
  OPENMP:=-qopenmp
else
  OPENMP:=-openmp
endif

# fpp - pre processor 
# openmp - enables openmp
# O3 - aggressive optimization
# mkl - math kernel library from intel
# DMKL - enables mkl in the code
REQOPTS:=-fpp $(OPENMP) -mkl -DMKL -O3 -static-intel

# Static can be defined from CLI, use STATIC=1 on make line
ifdef STATIC
  REQOPTS:=$(REQOPTS) -static
endif

# Generates for the most available instructions for AMD64 machines
amica15-default: *.f90
	LD_RUN_PATH= \
	OMPI_FC=$(OMPI_FC) \
	mpif90 $(REQOPTS) funmod2.f90 amica15.f90 \
		-o $@

# Generates code that attempts to use an advance set of instructions
# if available, if you compile on a machine that supports AVX2 you will
# likely see a speedup using these flags
FORHOST:=-march=core-avx2
amica15-avx2: *.f90
	LD_RUN_PATH= \
	OMPI_FC=$(OMPI_FC) \
	mpif90 $(FORHOST) $(REQOPTS) funmod2.f90 amica15.f90 \
		-o $@

.PHONY: all
all : amica15-default amica15-avx2

.PHONY: clean
clean :
	rm -f amica15-default amica15-avx2 funmod2.mod

