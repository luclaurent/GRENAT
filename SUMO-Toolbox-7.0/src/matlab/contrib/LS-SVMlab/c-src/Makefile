#SRC = lssvm.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c 
SRC-TRAIN = lssvm.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c 
SRC-SIM = simclssvm.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c 
SRC-FILE = lssvmFILE.c cga.c kernels.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c 
 SRC-SIMFILE = simFILE.c lssvm_classificator.c lssvm_fctest.c lssvm_timeserie.c lssvm_NARX.c kernel_cache.c kernels.c cga.c

CC = $$MATLABDIR/bin/mex

all : lssvm.mexglx simclssvm.mexglx lssvmFILE.x simFILE.x

lssvm.mexglx : $(SRC-TRAIN)
	cp memSpecMEX.h memSpec.h
	$(CC) -O $(SRC-TRAIN)

simclssvm.mexglx: $(SRC-SIM)
	cp memSpecMEX.h memSpec.h
	$(CC) -O $(SRC-SIM)


lssvmFILE.x : $(SRC-FILE)
	cp memSpecX.h memSpec.h
	gcc -lm -O3 -o lssvmFILE.x $(SRC-FILE)

simFILE.x: $(SRC-SIMFILE)
	cp memSpecX.h memSpec.h
	gcc -lm -O3 -o simFILE.x $(SRC-SIMFILE)

clean :
	rm -f lssvmFILE.x lssvm.mex* simclssvm.mex* simFILE.x memSpec.h
