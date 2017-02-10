CXX=icpc
CC=icc
CXX_OPTIONS=-qopenmp -std=c++11 -I./src/ 
BUILD_RAPL = Yes

ifeq (${debug}, 1)
  CXX_OPTIONS += -g
else
  CXX_OPTIONS += -O3 -ipo 
endif

CXX_OPTIONS += -xHost

ifeq (${timing}, 1)
  CXX_OPTIONS += -D__TIMING
else
endif

ifeq ($(BUILD_RAPL), Yes)
  PAPI_HOME=/usr/local/packages/papi/git
  CFLAGS = -I$(PAPI_HOME)/include -DPOWER_PROFILING=1 -g -Wall -ipo
  CXX_OPTIONS += -DPOWER_PROFILING=1
  LDLIBS = -L$(PAPI_HOME)/lib -Wl,-rpath,$(PAPI_HOME)/lib -lpapi -lm
endif

SRCDIR=src
BINDIR=bin

SOURCES=$(SRCDIR)/PageRank.cpp $(SRCDIR)/Degree.cpp $(SRCDIR)/BFS.cpp $(SRCDIR)/SGD.cpp $(SRCDIR)/TriangleCounting.cpp $(SRCDIR)/SSSP.cpp $(SRCDIR)/Delta.cpp

DEPS=$(SRCDIR)/SPMV.cpp $(SRCDIR)/Graph.cpp $(SRCDIR)/GraphProgram.cpp $(SRCDIR)/SparseVector.cpp $(SRCDIR)/GraphMatRuntime.cpp

EXE=$(BINDIR)/PageRank $(BINDIR)/IncrementalPageRank $(BINDIR)/BFS $(BINDIR)/TriangleCounting $(BINDIR)/SGD $(BINDIR)/SSSP $(BINDIR)/DS $(BINDIR)/LDA


all: $(EXE) graph_converter
	

graph_converter: graph_utils/graph_convert.cpp
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/graph_converter graph_utils/graph_convert.cpp

$(BINDIR)/PageRank: $(DEPS) $(MULTINODEDEPS) $(SRCDIR)/PageRank.cpp $(SRCDIR)/Degree.cpp 
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/PageRank $(SRCDIR)/PageRank.cpp 

$(BINDIR)/IncrementalPageRank: $(DEPS) $(MULTINODEDEPS) $(SRCDIR)/IncrementalPageRank.cpp $(SRCDIR)/Degree.cpp 
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/IncrementalPageRank $(SRCDIR)/IncrementalPageRank.cpp 

$(BINDIR)/BFS: $(DEPS) $(SRCDIR)/BFS.cpp $(SRCDIR)/power_rapl.c $(SRCDIR)/power_rapl.h
	$(CC) $(CFLAGS) -c -o power_rapl.o $(SRCDIR)/power_rapl.c
	$(CXX) $(CXX_OPTIONS) -c -o BFS.o $(SRCDIR)/BFS.cpp
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/BFS BFS.o power_rapl.o $(LDLIBS)

$(BINDIR)/SGD: $(DEPS) $(SRCDIR)/SGD.cpp 
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/SGD $(SRCDIR)/SGD.cpp

$(BINDIR)/LDA: $(DEPS) $(SRCDIR)/LDA.cpp 
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/LDA $(SRCDIR)/LDA.cpp

$(BINDIR)/TriangleCounting: $(DEPS) $(SRCDIR)/TriangleCounting.cpp
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/TriangleCounting $(SRCDIR)/TriangleCounting.cpp

$(BINDIR)/SSSP: $(DEPS) $(MULTINODEDEPS) $(SRCDIR)/SSSP.cpp
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/SSSP $(SRCDIR)/SSSP.cpp 

$(BINDIR)/DS: $(DEPS) $(SRCDIR)/Delta.cpp
	$(CXX) $(CXX_OPTIONS) -o $(BINDIR)/DS $(SRCDIR)/Delta.cpp

clean:
	rm -f $(EXE) bin/graph_converter BFS.o power_rapl.o
