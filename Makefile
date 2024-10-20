PREFIX=/usr
CXX=g++

CPPFLAGS=-std=c++20 -I$(PREFIX)/include
CPPFLAGS_PPROF=-O0 -g
CPPFLAGS_PERF=-O0 -g
CPPFLAGS_GPROF=-O0 -g -pg

LDFLAGS=-L$(PREFIX)/lib -L$(PREFIX)/lib64 -Wl,-rpath=$(PREFIX)/lib,-rpath=$(PREFIX)/lib64 -pthread
LDFLAGS_PPROF=-lprofiler
LDFLAGS_PERF=
LDFLAGS_GPROF=-pg

.PHONY: all clean
all: pprof perf gprof

main-pprof.o: main.cpp
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_PPROF)
main-pprof: main-pprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_PPROF)
main-perf.o: main.cpp
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_PERF)
main-perf: main-perf.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_PERF)
main-gprof.o: main.cpp
	$(CXX) $(CPPFLAGS) -c -o $@ $< $(CPPFLAGS_GPROF)
main-gprof: main-gprof.o
	$(CXX) -o $@ $< $(LDFLAGS) $(LDFLAGS_GPROF)

pprof: main-pprof
	mkdir -p output
	CPUPROFILE=main-pprof.out ./main-pprof
	pprof --dot ./main-pprof main-pprof.out | dot -Tpng -o output/main-pprof.png
	pprof --callgrind ./main-pprof main-pprof.out | gprof2dot --colormap=gray --strip --color-nodes-by-selftime -f callgrind | dot -Tpng -o output/main-pprof2.png
	#pprof --web ./main-pprof main-pprof.out
perf: main-perf
	mkdir -p output
	perf record -F 1000 -g ./main-perf
	perf script | c++filt | gprof2dot --colormap=gray --strip --color-nodes-by-selftime -f perf | dot -Tpng -o output/main-perf.png
gprof: main-gprof
	mkdir -p output
	./main-gprof
	gprof ./main-gprof | gprof2dot --colormap=gray --strip --color-nodes-by-selftime -f prof | dot -Tpng -o output/main-gprof.png

