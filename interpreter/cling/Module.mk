# Module.mk for cling module
# Copyright (c) 2011 Rene Brun and Fons Rademakers
#
# Author: Axel Naumann, 2011-10-18

MODNAME      := cling
MODDIR       := $(ROOT_SRCDIR)/interpreter/$(MODNAME)

CLINGDIR     := $(MODDIR)

##### libCling #####
CLINGS       := $(wildcard $(MODDIR)/lib/Interpreter/*.cpp) \
                $(wildcard $(MODDIR)/lib/MetaProcessor/*.cpp) \
                $(wildcard $(MODDIR)/lib/Utils/*.cpp)
CLINGO       := $(call stripsrc,$(CLINGS:.cpp=.o))

CLINGDEP     := $(CLINGO:.o=.d)

CLINGETC     := $(addprefix etc/cling/Interpreter/,\
	DynamicExprInfo.h DynamicLookupRuntimeUniverse.h \
	Interpreter.h InvocationOptions.h \
	RuntimeUniverse.h StoredValueRef.h \
	Value.h ValuePrinter.h ValuePrinterInfo.h ) \
        $(addprefix etc/cling/cint/,multimap multiset) \
	$(addprefix etc/cling/,\
clang/AST/BuiltinTypes.def \
clang/AST/CanonicalType.h \
clang/AST/NestedNameSpecifier.h \
clang/AST/TemplateName.h \
clang/AST/Type.h \
clang/AST/TypeNodes.def \
clang/Basic/Diagnostic.h \
clang/Basic/DiagnosticCommonKinds.inc \
clang/Basic/DiagnosticIDs.h \
clang/Basic/ExceptionSpecificationType.h \
clang/Basic/IdentifierTable.h \
clang/Basic/LLVM.h \
clang/Basic/Linkage.h \
clang/Basic/OperatorKinds.def \
clang/Basic/OperatorKinds.h \
clang/Basic/PartialDiagnostic.h \
clang/Basic/SourceLocation.h \
clang/Basic/Specifiers.h \
clang/Basic/TokenKinds.def \
clang/Basic/TokenKinds.h \
clang/Basic/Visibility.h \
llvm/ADT/APInt.h \
llvm/ADT/APSInt.h \
llvm/ADT/ArrayRef.h \
llvm/ADT/DenseMap.h \
llvm/ADT/DenseMapInfo.h \
llvm/ADT/FoldingSet.h \
llvm/ADT/IntrusiveRefCntPtr.h \
llvm/ADT/Optional.h \
llvm/ADT/OwningPtr.h \
llvm/ADT/PointerIntPair.h \
llvm/ADT/PointerUnion.h \
llvm/ADT/STLExtras.h \
llvm/ADT/SmallString.h \
llvm/ADT/SmallVector.h \
llvm/ADT/StringMap.h \
llvm/ADT/StringRef.h \
llvm/ADT/Twine.h \
llvm/ExecutionEngine/GenericValue.h \
llvm/Support/AlignOf.h \
llvm/Support/Allocator.h \
llvm/Support/Casting.h \
llvm/Support/Compiler.h \
llvm/Support/DataTypes.h \
llvm/Support/DynamicLibrary.h \
llvm/Support/ErrorHandling.h \
llvm/Support/MathExtras.h \
llvm/Support/Path.h \
llvm/Support/PathV1.h \
llvm/Support/PathV2.h \
llvm/Support/PointerLikeTypeTraits.h \
llvm/Support/SwapByteOrder.h \
llvm/Support/TimeValue.h \
llvm/Support/raw_ostream.h \
llvm/Support/type_traits.h \
llvm/Type.h )


# used in the main Makefile
ALLHDRS      += $(CLINGETC)

ifneq ($(LLVMDEV),)
CLINGEXES    := $(wildcard $(MODDIR)/tools/driver/*.cpp) \
                $(wildcard $(MODDIR)/lib/UserInterface/*.cpp)
CLINGEXEO    := $(call stripsrc,$(CLINGEXES:.cpp=.o))
CLINGEXE     := $(LLVMDIRO)/Debug+Asserts/bin/cling
ALLEXECS     += $(CLINGEXE)
endif

# include all dependency files
INCLUDEFILES += $(CLINGDEP)

# include dir for picking up RuntimeUniverse.h etc - need to
# 1) copy relevant headers to include/
# 2) rely on TCling to addIncludePath instead of using CLING_..._INCL below
CLINGCXXFLAGS = $(patsubst -O%,,$(shell $(LLVMCONFIG) --cxxflags) -I$(CLINGDIR)/include \
	-fno-strict-aliasing)

ifeq ($(CTORSINITARRAY),yes)
CLINGLDFLAGSEXTRA := -Wl,--no-ctors-in-init-array
endif

ifeq ($(ARCH),win32gcc)
# Hide llvm / clang symbols:
CLINGLDFLAGSEXTRA += -Wl,--exclude-libs,ALL 
endif

CLINGLIBEXTRA = $(CLINGLDFLAGSEXTRA) -L$(shell $(LLVMCONFIG) --libdir) \
	$(addprefix -lclang,\
		Frontend Serialization Driver CodeGen Parse Sema Analysis RewriteCore AST Lex Basic Edit) \
	$(patsubst -lLLVM%Disassembler,,\
	$(filter-out -lLLVMipa,\
	$(shell $(LLVMCONFIG) --libs linker jit executionengine debuginfo \
	  archive bitreader all-targets codegen selectiondag asmprinter \
	  mcparser scalaropts instcombine transformutils analysis target))) \
	$(shell $(LLVMCONFIG) --ldflags)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

all-$(MODNAME):

clean-$(MODNAME):
		@rm -f $(CLINGO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(CLINGDEP) $(CLINGETC)

distclean::     distclean-$(MODNAME)

$(CLINGDIRS)/Module.mk: $(LLVMCONFIG)

etc/cling/llvm/%: $(call stripsrc,$(LLVMDIRI))/include/llvm/%
	+@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@cp $< $@

etc/cling/clang/%: $(call stripsrc,$(LLVMDIRI))/include/clang/%
	+@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@cp $< $@

etc/cling/cint/%: $(CLINGDIR)/include/cling/cint/%
	+@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@cp $< $@

etc/cling/%.h: $(CLINGDIR)/include/cling/%.h
	+@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	@cp $< $@

$(CLINGDIR)/%.o: $(CLINGDIR)/%.cpp $(LLVMDEP)
	$(MAKEDEP) -R -f$(@:.o=.d) -Y -w 1000 -- $(CXXFLAGS) $(CLINGCXXFLAGS) -D__cplusplus -- $<
	$(CXX) $(OPT) $(CLINGCXXFLAGS) $(CXXOUT)$@ -c $<

$(call stripsrc,$(CLINGDIR)/%.o): $(CLINGDIR)/%.cpp $(LLVMDEP)
	$(MAKEDIR)
	$(MAKEDEP) -R -f$(@:.o=.d) -Y -w 1000 -- $(CXXFLAGS) $(CLINGCXXFLAGS)  -D__cplusplus -- $<
	$(CXX) $(OPT) $(CLINGCXXFLAGS) $(CXXOUT)$@ -c $<

ifneq ($(LLVMDEV),)
ifneq ($(PLATFORM),macosx)
# -Wl,-E exports all symbols, such that the JIT can find them.
# Doesn't exist on MacOS where this behavior is default.
CLINGLDEXPSYM := -Wl,-E
endif
$(CLINGEXE): $(CLINGO) $(CLINGEXEO) $(LTEXTINPUTO)
	$(RSYNC) --exclude '.svn' $(CLINGDIR) $(LLVMDIRO)/tools
	@cd $(LLVMDIRS)/tools && ln -sf ../../../cling # yikes
	@mkdir -p $(dir $@)
	$(LD) $(CLINGLDEXPSYM) -o $@ $(CLINGO) $(CLINGEXEO) $(LTEXTINPUTO) $(CLINGLIBEXTRA) 
endif

##### extra rules ######
ifneq ($(LLVMDEV),)
$(CLINGO)   : CLINGCXXFLAGS += '-DCLING_SRCDIR_INCL="$(CLINGDIR)/include"' \
	'-DCLING_INSTDIR_INCL="$(shell cd $(LLVMDIRI); pwd)/include"'
$(CLINGEXEO): CLINGCXXFLAGS += -I$(TEXTINPUTDIRS)
endif
