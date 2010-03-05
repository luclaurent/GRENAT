SD_OBJECTS = StepDiscontinuity.o
INCLUDES = -I../../../src/c/include/
LIBS = 
EXES = StepDiscontinuity
GPPFLAGS = -O2

all : exes strip

exes : $(EXES)

StepDiscontinuity : $(SD_OBJECTS)
	g++ -o $@ $(SD_OBJECTS) $(LIBS)

strip : $(EXES)
	strip $(EXES)
	
%.o : %.cpp
	g++ -c $(GPPFLAGS) -o $@ $< $(INCLUDES)

clean :
	find . -name "*.o" | xargs rm -f
	rm -Rf StepDiscontinuity
