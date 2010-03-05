# Makefile for building the Matlab mex interface to the NNSYSID library
# Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>

MATLABDIR ?= /opt/matlab
CXX = gcc
CFLAGS = -Wall -fPIC -O3 -I$(MATLABDIR)/extern/include

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)" -lm
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

all: marq.$(MEX_EXT) nnarmax2.$(MEX_EXT) nnoe.$(MEX_EXT) nnssif.$(MEX_EXT)

marq.$(MEX_EXT):        marq.c matrix.o nnmisc.o
	$(MEX) $(MEX_OPTION) marq.c matrix.o nnmisc.o

nnssif.$(MEX_EXT):        nnssif.c matrix.o nnmisc.o
	$(MEX) $(MEX_OPTION) nnssif.c matrix.o nnmisc.o

nnoe.$(MEX_EXT):        nnoe.c matrix.o nnmisc.o
	$(MEX) $(MEX_OPTION) nnoe.c matrix.o nnmisc.o

nnarmax2.$(MEX_EXT):        nnarmax2.c matrix.o nnmisc.o
	$(MEX) $(MEX_OPTION) nnarmax2.c matrix.o nnmisc.o

nnmisc.o:     nnmisc.c nnmisc.h
	$(CXX) $(CFLAGS) -c nnmisc.c

matrix.o:     matrix.c matrix2.h
	$(CXX) $(CFLAGS) -c matrix.c

clean:
	rm -f *~ *.o; rm -f *.mex*; rm -f *obj

