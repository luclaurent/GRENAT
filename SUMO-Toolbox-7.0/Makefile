# This is the top level Makefile that builds the whole SUMO Toolbox
#
# If the MATLABDIR environment variable is not set
# set it to some default value
#
# Note note that the JAVA_HOME environment variable is assumed to be set
# to the path of your Java SDK installation
#
# Revision: $Rev: 6387 $
# Last changed on $Date: 2009-12-11 15:59:07 +0100 (Fri, 11 Dec 2009) $ by $Author: ilm $

MATLABDIR ?= /opt/matlab7/

all: test-matlab-dir java contrib cexamples mexfiles

java:
	@echo "";
	@echo "[I] Matlab directory set to ${MATLABDIR}";
	@echo "[I] JAVA_HOME set to ${JAVA_HOME}";
	@echo "";
	@echo "";
	@echo "[I] Building java sources";
	ant -DMATLABDIR=${MATLABDIR}

contrib:
	@echo "";
	@echo "[I] Compiling SVM codes";
	make -C src/matlab/contrib/libsvm MATLABDIR=${MATLABDIR}
	make -C src/matlab/contrib/LS-SVMlab/c-src MATLABDIR=${MATLABDIR}
	@echo "";
	@echo "[I] Compiling FANN";
	cd src/matlab/contrib/fann;./configure
	make -C src/matlab/contrib/fann
	@echo "";
	@echo "[I] Compiling FANN Mex files";
	make -C src/matlab/contrib/fann/mex MATLABDIR=${MATLABDIR}
	@echo "";
	@echo "[I] Compiling NNSYSID Mex files";
	make -C src/matlab/contrib/NNSYSID20 MATLABDIR=${MATLABDIR}

mexfiles:
	@echo "";
	@echo "[I] Compiling Kriging Mex files";
	make -C src/matlab/contrib MATLABDIR=${MATLABDIR} release


cexamples:
	@echo "";
	@echo "[I] Compiling examples";
	make -C examples

javadoc:
	@echo "";
	@echo "[I] Building javadoc";
	ant -DMATLABDIR=${MATLABDIR} javadoc
	
clean:
	ant clean
	rm -rf doc/apidoc
	make -C src/matlab/contrib/libsvm clean
	make -C src/matlab/contrib/LS-SVMlab/c-src clean
	make -C src/matlab/contrib/fann clean
	make -C src/matlab/contrib/fann/mex clean
	make -C src/matlab/contrib/NNSYSID20 clean
	make -C examples clean
	make -C src/matlab/models/@Kriging/private clean

test-matlab-dir : 
	@if [ ! -e ${MATLABDIR}/bin/matlab ]; then \
		echo "Please set the MATLABDIR variable, either as environment variable or in the Makefile"; false;\
	fi;	
