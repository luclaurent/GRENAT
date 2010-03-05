IP_OBJECTS = InductivePosts.o
INCLUDES = -I../../../src/c/include/
LIBS = 
EXES = InductivePosts
GPPFLAGS = -O2

all : exes strip

exes : $(EXES)

InductivePosts: $(IP_OBJECTS)
	g++ -o $@ $(IP_OBJECTS) $(LIBS)

strip : $(EXES)
	strip $(EXES)
	
%.o : %.cpp
	g++ -c $(GPPFLAGS) -o $@ $< $(INCLUDES)

clean :
	find . -name "*.o" | xargs rm -f
	rm -Rf bin/*
