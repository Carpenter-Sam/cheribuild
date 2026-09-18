#
# Copyright 2021, Breakaway Consulting Pty. Ltd.
#
# SPDX-License-Identifier: BSD-2-Clause
#

# make -f Makefile BUILD_DIR="/home/hazchem/Projects/cheribuild/user-scripts/hello" MICROKIT_SDK="/home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/microkit-sdk-2.0.1-dev" MICROKIT_BOARD="qemu_virt_riscv64" MICROKIT_CONFIG="cheri" CHERI=True LLVM=True
# Currently fails on the compilation. clang doesn't recognise zcherihybrid as a valid extension.
#   Make normal clang accept zcherihybrid.
#   Find special cheri clang that already accepts zcherihybrid. 

# What is BUILD_DIR? Build directory?
#   Where the build directory actually is?
#   Absolute path?
ifeq ($(strip $(BUILD_DIR)),)
    # strip removes leading and trailing whitespace, and replaces repeated internal spaces with just one space from Strings,
    #   e.g., '   hello     world    ' -> 'hello world'
    # This allows us to check if BUILD_DIR is empty without worrying about interpretting whitespace as a non-empty
    # variable.
  $(error BUILD_DIR must be specified) # Only outputs this error if BUILD_DIR is empty (excluding whitespace).
endif

# What is MICROKIT_SDK?
#  Where is my MICROKIT_SDK?
#  Current guess is that my MICROKIT_SDK is 'microkit-sdk-2.0.1-dev'.
#  Could be something like '/home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/microkit-sdk-2.0.1-dev'.
ifeq ($(strip $(MICROKIT_SDK)),)
  $(error MICROKIT_SDK must be specified)
endif

# What is my MICROKIT_BOARD?
#  Current guess is 'qemu_virt_riscv64'.
ifeq ($(strip $(MICROKIT_BOARD)),)
  $(error MICROKIT_BOARD must be specified)
endif

# Where and what is the MICROKIT_CONFIG?
#  Do I have a Microkit config?
#  Maybe it's just 'cheri'?
ifeq ($(strip $(MICROKIT_CONFIG)),)
  $(error MICROKIT_CONFIG must be specified)
endif

# Perhaps defining CHERI and setting it to true is a good idea?
ifndef CHERI
CHERI = False
endif

# Board_dir seems to just be the directory of the board.
#  Will most likely be: 'microkit-sdk-2.0.1-dev/board/qemu_virt_riscv64/cheri'.
#  Or better yet: '/home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/microkit-sdk-2.0.1-dev/board/qemu_virt_riscv64/cheri'
BOARD_DIR := $(MICROKIT_SDK)/board/$(MICROKIT_BOARD)/$(MICROKIT_CONFIG)

# Searches gen_config.h in the file path:
#  '/home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/microkit-sdk-2.0.1-dev/board/qemu_virt_riscv64/cheri/include/kernel'
# for references to CONFIG_SEL4_ARCH.
# cut -d' ' -f4 seems to split up its input into sets separate by a space and pick the fourth one. 
#  This is becase the grep will return '#define CONFIG_SEL4_ARCH  riscv64' and our required field 'riscv64' is actually
#  the 4th one here.
ARCH := ${shell grep 'CONFIG_SEL4_ARCH  ' $(BOARD_DIR)/include/kernel/gen_config.h | cut -d' ' -f4} # Returns 'riscv64' for me.
$(info ARCH is $(ARCH))
$(info CHERI is $(CHERI))

# Check if CHERI is set to true.
ifeq ($(CHERI),True)
  ifeq ($(ARCH),riscv64 ) # This is the one that will run.
    $(info ARCH correctly labelled as riscv64)
    # Build in purecap CHERI ABI
    ARCH_FLAGS := -march=rv64imafdc_zicsr_zcherihybrid -mabi=l64pc128d
    # march = Generate code for given RISC-V ISA or profile or a combination of them.
    #  rv64imafdc_zicsr_zcherihybrid
    #    rv64 = risc64, i = base integer extension (base ISA), m = integer multiplication and division extension,
    #    a = atomic ext, fd = Single and double floating point precision exts, c = compressed ext.
    #    zicsr (extension) = Control and status register access ext,
    #    zcherihybrid (extension) = CHERI hybrid ext?
    # mabi = Specify integer and floating-point calling convention.
    #  l64pc128d
    #    l64 = 'long' = 64 bits?
    #    pointers and compressed(? chars?) = 128 bits?
    #    d = ???
    #  https://gcc.gnu.org/onlinedocs/gcc/RISC-V-Options.html#index-mabi-6
  else ifeq ($(ARCH),aarch64 )
    ARCH_FLAGS := -march=morello -mabi=purecap -DCONFIG_HAVE_CHERI
  else
    $(warning No ARCH selected. ARCH is $(ARCH))
  endif
  LIBS := -lmicrokit_purecap # Add microkit_purecap archive or object file specified by namespec to the list of files to link.
else
  $(warning CHERI needs to be set to True)
  # Do not have to worry about this, as I am using CHERI.
  ifeq ($(ARCH),riscv64 )
    ARCH_FLAGS := -march=rv64imafdc_zicsr_zifencei -mabi=lp64d
  endif
  LIBS := -lmicrokit
endif

# Runs whether CHERI is true or not.
ifeq ($(ARCH),aarch64 )
  TARGET_TRIPLE := aarch64-none-elf # Bare metal / RTOS
  CFLAGS_ARCH := -mstrict-align $(ARCH_FLAGS)
  # -mstrict-align = Avoid generating memory accesses that may not be aligned on a natural object boundary as described in the architecture specification.
else ifeq ($(ARCH),riscv64 ) # This is what runs.
  TARGET_TRIPLE := riscv64-unknown-elf
  CFLAGS_ARCH := $(ARCH_FLAGS)
else
  $(warning Unsupported arch? Arch is $(ARCH))
  $(error Unsupported ARCH)
endif

# Checks if LLVM is set to True or not.
ifeq ($(strip $(LLVM)),True)
  # Clang is a compile for C (and C++). -target specifies the architecture to build for, which will be
  # 'riscv64-unknown-elf'.
  CC := clang -target $(TARGET_TRIPLE)
  AS := clang -target $(TARGET_TRIPLE)
  LD := ld.lld # ELF linker from the LLVM project.
else
  CC := $(TARGET_TRIPLE)-gcc # C = C complier? Compiler collection?
  LD := $(TARGET_TRIPLE)-ld # LD = linker, combines a number of object and archive files, relocates their
                            #      data and ties up symbol references. Usually the last step to compilation.
  AS := $(TARGET_TRIPLE)-as # AS = assembler, primarily intended to assemble the output of the GNU C
                            #      compiler 'gcc' for use by the linker 'ld'.
endif

# '?=' means the value is only set if it is undefined.
MICROKIT_TOOL ?= $(MICROKIT_SDK)/bin/microkit

# Names of all the intermediary object files that will be created.
HELLO_OBJS := hello.o

# Names of all the intermediary ELF files that will be created.
IMAGES := hello.elf
# Flags used for compiling the C files?
CFLAGS := -nostdlib -ffreestanding -g -O3 -Wall  -Wno-unused-function -Werror -I$(BOARD_DIR)/include $(CFLAGS_ARCH)
  # -nostdlib = don't search standard system directories for include files.
  # -ffreestanding = compile for a freestanding (as opposed to a hosted one, freestanding means just the language and
  #                  nothing else) environment, though will still need to link with a C standard library.
  # -g = Generate debug info.
  # -O3 = Highly optimise the code
  # -Wall = Enables all compiler warnings.
  # -Wno-unused-function = Turns off GCC warnings about unused functions. 
  # -Werror = Treats all warnings as errors.
  # -I = Add the board directory's include directory to the search path for include files.
  # CFLAGS_ARCH = Build in purecap CHERI ABI. 
# Flags for the linker.
LDFLAGS := -L$(BOARD_DIR)/lib # Adds the /lib directory as a list of paths that ld will search for archive libraries and ld control scripts.
# Libraries to use?
LIBS := $(LIBS) -Tmicrokit.ld # Adds microkit_purecap then states to use microkit.ld as the linker script.

# Location of where the image and report files will be.
IMAGE_FILE = $(BUILD_DIR)/loader.img
REPORT_FILE = $(BUILD_DIR)/report.txt

$(info Generating files...)

all: $(IMAGE_FILE) # Something to do with having the MAKEFILE continue even if the IMAGE_FILE is present and seems to be up to date?

$(BUILD_DIR)/%.o: %.c Makefile # To make the object file, the files .c and Makefile need to exist first.
	$(CC) -c $(CFLAGS) $< -o $@ # Compile and generate an object file with the specified flags.
# $(CC) = Run the specified C compiler.
# -c = Create an object file.
# $(CFLAGS) = List specified flags.
# $< = Compile the first prerequisite (which is the .c file).
# -o $@ = Write output to the target being generated (which is the .o file).

$(BUILD_DIR)/hello.elf: $(addprefix $(BUILD_DIR)/, $(HELLO_OBJS)) # The object file 'hello.o' (compiled in previous command) is needed to construct the ELF file.
	$(LD) $(LDFLAGS) $^ $(LIBS) -o $@ # Links the object files and libraries using the linker script to generate an ELF file.
# $(LD) = Run the specified linker.
# $(LDFLAGS) = List specified flags. 
# $^ = Link all object files (lists all pre-requisites with spaces between them).
# $(LIBS) = Link microkit_purecap and use microkit.ld as the linker script.
# -o $@ = Write output to the target being generated (hello.elf).   

$(IMAGE_FILE) $(REPORT_FILE): $(addprefix $(BUILD_DIR)/, $(IMAGES)) hello.system # The previously generated images and, a .system file are needed to create the image and report file.
	$(MICROKIT_TOOL) hello.system --search-path $(BUILD_DIR) --board $(MICROKIT_BOARD) --config $(MICROKIT_CONFIG) -o $(IMAGE_FILE) -r $(REPORT_FILE) # Uses microkit to create a .img file.
# $(MICROKIT_TOOL) = Microkit binary inside the Microkit SDK. 
# hello.system = Name of the system file to use.
# --search-path $(BUILD_DIR) = Build directory? Places to search for the .elf files produced?
# --board $(MICROKIT_BOARD) = Board to use (qemu_virt_riscv64).
# --config $(MICROKIT_CONFIG) = Config to use (cheri).
# -o $(IMAGE_FILE) = Location to output the created .img file.
# -r $(REPORT_FILE) = Location to output report to.
