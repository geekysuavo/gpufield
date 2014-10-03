
# define the compiler name and library flags.
CC=nvcc
LIBS=-lm -lcuda

# define the binary and object file names.
BIN=gpufield mutual
OBJ=log.o cmd.o vec3.o wires.o shapes.o grid.o
BINOBJ=$(addsuffix .o,$(BIN))

# define the tests that may be run.
TST=coil-1.0 gradx-1.0 grady-1.0 gradz-1.0
TESTS=$(addsuffix .out,$(addprefix out/,$(TST)))

# define all phony (non-file) target names.
.PHONY: all test plots clean distclean dist again

# define the suffixes that 'make' should recognize.
.SUFFIXES: .cu .o .in .out

# all: default target.
all: $(BIN)

# .cu.o: compilation of cuda-c to object code.
.cu.o:
	@echo " NVCC $^"
	@$(CC) -c $^ -o $@

# gpufield: linking rule for the gpufield binary.
gpufield: $(OBJ) $(BINOBJ)
	@echo " NVLD $@"
	@$(CC) $(OBJ) $(addsuffix .o,$@) -o $@ -lm -lreadline -lhistory -lcuda

# mutual: linking rule for the mutual binary.
mutual: $(OBJ) $(BINOBJ)
	@echo " NVLD $@"
	@$(CC) $(OBJ) $(addsuffix .o,$@) -o $@ -lm

# test: the test target.
test: all out $(TESTS)

# out: the output directory.
out:
	@install -d out

# %.out: execution of test input files.
%.out:
	@echo " TEST $(subst out,in,$@)"
	@./gpufield < $(subst out,in,$@) 2> $@

# plots: quick way to rebuild all plotted images.
plots: test
	@for g in x y z; do \
	   echo " PLOT grad$${g} traj"; \
	   gnuplot -e "dim='$${g}'" plt/traj-grad.plt; \
	   for d in x y z; do \
	     echo " PLOT grad$${g} grid $${d}"; \
	     gnuplot -e "gdim='$${g}';dim='$${d}'" plt/grid-grad.plt; \
	   done; \
	 done
	@echo " PLOT coil traj"
	@gnuplot plt/traj-coil.plt
	@for d in x y z; do \
	   echo " PLOT coil grid $${d}"; \
	   gnuplot -e "dim='$${d}'" plt/grid-coil.plt; \
	 done

# clean: rule to clean all compiled results.
clean:
	@echo " CLEAN"
	@rm -f $(BIN) $(OBJ) $(BINOBJ)

# distclean: rule to clean all compiled results and computed data.
distclean: clean
	@echo " DISTCLEAN"
	@rm -rf out plt/*.png

# dist: rule to prepare a dated tarball of the current source tree.
dist: distclean
	@echo " DIST $$(date +%Y%m%d)"
	@cd .. && \
	 rm -f gpufield-$$(date +%Y%m%d).tar.gz && \
	 tar cf gpufield-$$(date +%Y%m%d).tar gpufield && \
	 gzip -9 gpufield-$$(date +%Y%m%d).tar && \
	 cd gpufield

# again: recompilation rule.
again: clean all

