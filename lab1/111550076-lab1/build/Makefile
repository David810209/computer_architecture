#=========================================================================
# Makefile for Verilog Packages
#=========================================================================
# This is a simple start to a much more sophisticated Verilog build
# system. For most packages, a developer will not need to make any
# changes to this file except to make sure that the subpkgs make variable
# correctly lists the desired subpackages to include in this package.
# Developers also need to make sure each subpackage makefile fragment
# (e.g., vc.mk) is uptodate with a list of all of the subpackage
# dependencies, Verilog source files, test source files, and program
# source files. The key targets for this Makefile are as follows:
#
#  - default   : build all programs
#  - check     : build and run all unit tests
#  - clean     : remove all generated content
#

#-------------------------------------------------------------------------
# Basic setup
#-------------------------------------------------------------------------

# Remove all default implicit rules since they can cause subtle bugs
# and they just make things run slower
.SUFFIXES:
% : %,v
% : RCS/%,v
% : RCS/%
% : s.%
% : SCCS/s.%

# Default is to build the prereqs of the all target (defined at bottom)
default : all
.PHONY : default

topdir = ..

#-------------------------------------------------------------------------
# List of subpackages
#-------------------------------------------------------------------------

subpkgs = \
  vc \
  imuldiv \

#-------------------------------------------------------------------------
# Programs
#-------------------------------------------------------------------------

COMP       = iverilog
COMP_FLAGS = -g2005 -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array

#-------------------------------------------------------------------------
# Makefile fragments from subpackages
#-------------------------------------------------------------------------

subpkgs_mk := \
  $(join $(addprefix $(topdir)/, $(subpkgs)), \
         $(patsubst %, /%.mk, $(subpkgs)))

-include $(subpkgs_mk)
VPATH := $(addprefix $(topdir)/, $(subpkgs))

#-------------------------------------------------------------------------
# Template for per subpackage rules
#-------------------------------------------------------------------------

# Helper template for collecting sources from subpackage dependencies

define subpkg_template_collect_deps
$(1)_deps_srcs += $$($(2)_srcs)
endef

# Main subpackage template

define subpkg_template

# Subpackage subdirectory

$(2)_dir := $$(addprefix $(topdir)/, $(1))

# Subpackage dependencies

$(2)_incs := $$(addprefix -I $(topdir)/, $$($(2)_deps))

$$(foreach dep,$$($(2)_deps), \
  $$(eval $$(call subpkg_template_collect_deps,$(2),$$(dep))))

# Build unit tests

$(2)_test_exes := $$(patsubst %.t.v,%-utst,$$($(2)_test_srcs))

$$($(2)_test_exes) : %-utst : $$($(2)_dir)/%.t.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/vc -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_test_exes)

# Run unit tests

$(2)_test_outs := $$(addsuffix .out, $$($(2)_test_exes))

$$($(2)_test_outs) : %.out : %
	./$$< +verbose=2 > $$@

$(2)_junk += $$($(2)_test_outs)

# Build programs

$(2)_prog_exes := $$(patsubst %.v, %, $$($(2)_prog_srcs))

$$($(2)_prog_exes) : % : $$($(2)_dir)/%.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_prog_exes)

# Other subpkg specific targets

all-$(1) : $$($(2)_prog_exes)

check-$(1) : $$($(2)_test_outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $($(2)_test_outs)
	@echo;

clean-$(1) :
	rm -rf $$($(2)_junk)

.PHONY : all-$(1) check-$(1) clean-$(1)

# Update running variables

exes += $$($(2)_prog_exes)
outs += $$($(2)_test_outs)
junk += $$($(2)_junk)

endef

# Call template for each subpackage

$(foreach subpkg,$(subpkgs), \
  $(eval $(call subpkg_template,$(subpkg),$(subst -,_,$(subpkg)))))

#-------------------------------------------------------------------------
# Check
#-------------------------------------------------------------------------

check : $(outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $(outs)
	@echo;

.PHONY : check

#-------------------------------------------------------------------------
# Default
#-------------------------------------------------------------------------

all : $(exes)
.PHONY : all

#-------------------------------------------------------------------------
# Makefile debugging
#-------------------------------------------------------------------------
# This handy rule will display the contents of any make variable by
# using the target debug-<varname>. So for example, make debug-junk will
# display the contents of the junk variable.

debug-% :
	@echo $* = $($*)

#-------------------------------------------------------------------------
# Clean up junk
#-------------------------------------------------------------------------

clean :
	rm -rf *~ \#* *.vcd $(junk)

.PHONY : clean

