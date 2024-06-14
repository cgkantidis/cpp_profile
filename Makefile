PREFIX=${RHOME}/.local/install
CXX=g++

CPPFLAGS=-I$(PREFIX)/include
CPPFLAGS_PPROF=-O3
CPPFLAGS_GPROF=-O0 -g -pg

LDFLAGS=-L$(PREFIX)/lib -L$(PREFIX)/lib64 -lprofiler -Wl,-rpath=$(PREFIX)/lib,-rpath=$(PREFIX)/lib64
LDFLAGS_PPROF=-lprofiler
LDFLAGS_GPROF=-pg

.PHONY: all clean pprof gprof
all: main-pprof main-gprof
clean:
	rm -f *.o *.out main-gprof main-pprof

main-pprof.o: main.cpp Makefile
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_PPROF)
main-pprof: main-pprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_PPROF)
main-gprof.o: main.cpp Makefile
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_GPROF)
main-gprof: main-gprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_GPROF)

pprof: main-pprof
	CPUPROFILE=main-pprof.out ./main-pprof
	pprof --web ./main-pprof main-pprof.out
gprof: main-gprof
	./main-gprof
	gprof main-gprof
