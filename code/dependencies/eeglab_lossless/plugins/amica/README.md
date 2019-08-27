# amica15

Adaptive Mixture ICA forked from https://github.com/japalmer29/amica to provide documentation and tools around this software. You may be able to find more details on Jason A. Palmers site here: https://sccn.ucsd.edu/~jason/amica_web.html

## Requirements

- Intel Fortran Compilers (17+ recommended)
  - provides `ifort`
- Open MPI (v1.x, v1.10 was used at time of writing)
  - provides `mpif90`
- Make (GNU Make recommended)

## Compile

If you are running on machines with AVX2 instructions consider using `make amica15-host` as you will likely recieve performance enhancements additionally, if you have static dev libraries on your machine you may compile with `make <target> STATIC=1` which will enable static linking and has been shown to provide a performance boost.  

### Linux & Mac

1. Ensure `ifort` and `mpif90` is in your `PATH`
2. Run `make` from project root directory

### Windows

Because windows is not compatible with our Makefile you will need to
refer to the original repo

## Running

`amica15` uses a parameter file generated using GUI in matlab, it can be hand edited however. Consider using the GUI with the associated EEGLAB plugin, see help here: https://sccn.ucsd.edu/~jason/amica_help.html

`amica15` is an MPI program and can be run with `mpirun` idioms. Consult Open MPI for more details.

Note that you should run with the same libraries you link with if possible however  it is possible that Open MPI will run with older / newer libraries

## Test

```
./amica15 ./amicadefs.param
```
