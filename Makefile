CXX = g++
CXXFLAGS = -std=c++17 -I./include -Ofast
AR = ar
AS = as
ASFLAGS =

# CXX = clang++
# CXXFLAGS = -std=c++17 -I./include -Ofast -fno-vectorize
# AR = ar
# AS = as
# ASFLAGS =

# Windows doesn't have lsb_release or uname, skip Ubuntu detection
# ifeq ($(CXX),clang++)
#	ifeq ($(shell lsb_release -i | cut -f 2),Ubuntu)
#		UBUNTU_YEAR = $(shell lsb_release -r | cut -f 2 | cut -d '.' -f 1)
#		ifeq ($(shell expr $(UBUNTU_YEAR) \>= 17),1)
#			CXXFLAGS += -fPIC
#		endif
#	endif
# endif

# Set architecture for Windows x86_64
ARCH = x86_64
ARCHDIR = src/core/arch/$(ARCH)

# Comment out the above and uncomment the below for embedded build

# CXX = arm-none-eabi-g++
# CXXFLAGS = -std=c++17 -I./include -Os -mcpu=cortex-m0plus -mlittle-endian -mthumb -mfloat-abi=soft -mno-thumb-interwork -ffunction-sections -fdata-sections -fno-builtin -fshort-enums -fno-threadsafe-statics
# AR = arm-none-eabi-ar
# AS = arm-none-eabi-as
# ASFLAGS = -mcpu=cortex-m0plus -mlittle-endian -mthumb -mfloat-abi=soft
# ARCHDIR = src/core/arch/armv6_m

# To disable assembly optimizations, uncomment the following line (which adds -DDISABLE_ASM to CXXFLAGS)
CXXFLAGS += -DDISABLE_ASM

PAIRING_CPP_SOURCES = $(wildcard src/core/*.cpp) $(wildcard src/bls12_381/*.cpp) $(wildcard src/wkdibe/*.cpp) $(wildcard src/lqibe/*.cpp) $(wildcard $(ARCHDIR)/*.cpp)
# Skip assembly sources when DISABLE_ASM is enabled
PAIRING_ASM_SOURCES = 

CPP_SOURCES = $(PAIRING_CPP_SOURCES)
ASM_SOURCES = $(PAIRING_ASM_SOURCES)

BINDIR = bin
PAIRING_OBJECTS = $(addprefix $(BINDIR)/,$(CPP_SOURCES:.cpp=.o)) $(addprefix $(BINDIR)/,$(ASM_SOURCES:.s=.o))

all: pairing.a

pairing.a: $(PAIRING_OBJECTS)
	$(AR) rcs pairing.a $+

$(BINDIR)/%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(BINDIR)/%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf bin pairing.a
