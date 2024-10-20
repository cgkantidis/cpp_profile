PREFIX=/usr
CXX=g++

CPPFLAGS=-std=c++20 -I$(PREFIX)/include
CPPFLAGS_PPROF=-O0 -g
CPPFLAGS_GPROF=-O0 -g -pg
CPPFLAGS_PERF=-O0 -g

LDFLAGS=-L$(PREFIX)/lib -L$(PREFIX)/lib64 -Wl,-rpath=$(PREFIX)/lib,-rpath=$(PREFIX)/lib64 -pthread
LDFLAGS_PPROF=-lprofiler
LDFLAGS_GPROF=-pg
LDFLAGS_PERF=

.PHONY: all clean pprof gprof perf
all: main-pprof main-gprof main-perf
clean:
	rm -f *.o *.out main-gprof main-pprof main-perf flamegraph.html perf.data

main-pprof.o: main.cpp Makefile
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_PPROF)
main-pprof: main-pprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_PPROF)
main-gprof.o: main.cpp Makefile
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_GPROF)
main-gprof: main-gprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_GPROF)
main-perf.o: main.cpp Makefile
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_PERF)
main-perf: main-perf.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_PERF)

pprof: main-pprof
	mkdir -p output
	CPUPROFILE=main-pprof.out ./main-pprof
	pprof --dot ./main-pprof main-pprof.out | dot -Tpng -o output/main-pprof.png
	pprof --web ./main-pprof main-pprof.out
gprof: main-gprof
	mkdir -p output
	./main-gprof
	gprof --graph main-gprof >output/main-gprof.txt
	head -64 output/main-gprof.txt
perf: main-perf
	perf record -F 1000 -g ./main-perf
	perf script report flamegraph --allow-download
	xdg-open flamegraph.html

