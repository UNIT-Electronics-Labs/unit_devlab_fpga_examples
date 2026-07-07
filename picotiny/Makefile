TOP=picotiny
HDL?=verilog
CST=src/picotiny.cst
SDC=src/picotiny.sdc
VERILOG_INCLUDE_DIRS=src src/hdmi
VERILOG_SOURCES= \
	src/gowin_ip/bootram_2kx8_0/bootram_2kx8_0.v \
	src/gowin_ip/bootram_2kx8_1/bootram_2kx8_1.v \
	src/gowin_ip/bootram_2kx8_2/bootram_2kx8_2.v \
	src/gowin_ip/bootram_2kx8_3/bootram_2kx8_3.v \
	src/gowin_ip/gowin_clkdiv/gowin_clkdiv.v \
	src/gowin_ip/gowin_rpll/gowin_rpll.v \
	src/gowin_ip/sram_2kx8/sram_2kx8.v \
	src/hdmi/svo_enc.v \
	src/hdmi/svo_hdmi_top.v \
	src/hdmi/svo_openldi.v \
	src/hdmi/svo_tcard.v \
	src/hdmi/svo_term.v \
	src/hdmi/svo_tmds.v \
	src/hdmi/svo_utils.v \
	src/hdmi/svo_vdma.v \
	src/picomemory.v \
	src/picoperipheral.v \
	src/picorv32.v \
	src/simpleuart.v \
	src/spimemio_puya.v \
	src/picotiny.v

PYTHON_NAME ?= python
RISCV_NAME ?= riscv64-unknown-elf
RISCV_PATH ?= /usr

FW_FILE = fw/fw-flash/build/fw-flash.v
PROG_FILE ?= $(FW_FILE)
COMx ?= /dev/ttyUSB1

export PYTHON_NAME
export RISCV_NAME
export RISCV_PATH

include ../mk/common.mk

.PHONY: firmware brom user-fw program clean-firmware clean-all

firmware: brom user-fw

brom:
	$(MAKE) -C fw/fw-brom

user-fw:
	$(MAKE) -C fw/fw-flash

$(FW_FILE): user-fw

program: $(PROG_FILE)
	$(PYTHON_NAME) sw/pico-programmer.py $(PROG_FILE) $(COMx)

clean-firmware:
	$(MAKE) -C fw/fw-brom clean
	$(MAKE) -C fw/fw-flash clean

clean-all: clean clean-firmware
