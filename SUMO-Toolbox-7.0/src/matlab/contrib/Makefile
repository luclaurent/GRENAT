# ARCH_LIST = glnx86 glnxa64 mac maci maci64 sol2 sol64
PLATFORM = $(shell uname -s)
ifeq ($(PLATFORM),Linux)
  SUBPLATFORM = $(shell uname -m)
  ifeq ($(SUBPLATFORM),x86_64)
    ARCH = glnxa64
  else
    ARCH = glnx86
  endif
else
  ARCH = TODO
endif

#ARCH = $(shell MATLABROOT=$(MATLABDIR) $(MATLABDIR)/bin/util/arch.sh)
#source $(MATLABDIR)/bin/mexext.sh

MEX = $(MATLABDIR)/bin/mex
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)


MEX_OPTIONS = 
MEX_LIBS = -lm $(MATLABDIR)/bin/$(ARCH)/mkl.so

# -g -DDEBUG
CFLAGS = -Wall -fPIC
INCLUDE = -I$(MATLABDIR)/extern/include

debug: CFLAGS += -g -DDEBUG
debug: MEX_OPTIONS += -v
debug:cholincsp.$(MEX_EXT)

release: CFLAGS += -O3
release: cholincsp.$(MEX_EXT)

cholincsp.$(MEX_EXT): cholincsp.o
	echo arch: $(ARCH)
	echo platform: $(PLATFORM)
	echo subplatform: $(SUBPLATFORM)
	$(MEX) $(MEX_OPTIONS) $(MEX_LIBS) -output cholincsp $^

cholincsp.o: cholincsp.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $^

clean:
	rm -f *~ *.o; rm -f *.mex*; rm -f *obj

