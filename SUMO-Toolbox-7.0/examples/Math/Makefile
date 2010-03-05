all : examples

examples :  
	for i in `ls`; do if [ -e $$i/Makefile ]; then make -C $$i; fi ; done

clean:
	for i in `ls`; do if [ -e $$i/Makefile ]; then make clean -C $$i; fi ; done
