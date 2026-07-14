HDL ?= verilog

ifeq ($(HDL),vhdl)
CONFIG := devlab-vhdl.toml
else
CONFIG := devlab.toml
endif

.PHONY: all build flash clean

all: build

build:
	devlab build -c $(CONFIG)

flash:
	devlab flash -c $(CONFIG)

clean:
	rm -rf build
