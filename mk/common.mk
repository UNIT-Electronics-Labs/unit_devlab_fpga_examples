SHELL=/bin/bash

TOP?=top
HDL?=vhdl
OSS_CAD_SUITE?=$(HOME)/oss-cad-suite
OSS_ENV?=$(OSS_CAD_SUITE)/environment
RUN=if [ -f "$(OSS_ENV)" ]; then . "$(OSS_ENV)"; fi &&
BUILD_DIR?=build
SYNTH_JSON=$(BUILD_DIR)/$(TOP).json
PNR_JSON=$(BUILD_DIR)/$(TOP)_pnr.json
BITSTREAM=$(BUILD_DIR)/$(TOP).fs
VERILOG_SOURCES?=$(TOP).v
VHDL_SOURCE?=$(TOP).vhd
VERILOG_INCLUDE_DIRS?=
READ_VERILOG=read_verilog $(addprefix -I,$(VERILOG_INCLUDE_DIRS)) $(VERILOG_SOURCES)
NEXTPNR_SDC=$(if $(strip $(SDC)),--sdc $(SDC),)

DEVICE?=GW1NR-LV9QN88PC6/I5
FAMILY?=GW1N-9C
CST?=pins.cst

ifeq ($(HDL),vhdl)
SYNTH=$(RUN) yosys -m ghdl -p "ghdl $(VHDL_SOURCE) -e $(TOP); synth_gowin -top $(TOP) -json $(SYNTH_JSON)"
else
SYNTH=$(RUN) yosys -p "$(READ_VERILOG); synth_gowin -top $(TOP) -json $(SYNTH_JSON)"
endif

.PHONY: all flash flash-permanent detect clean

all:
	mkdir -p $(BUILD_DIR)
	$(SYNTH)
	$(RUN) nextpnr-himbaechel \
		--json $(SYNTH_JSON) \
	--write $(PNR_JSON) \
	--device $(DEVICE) \
	--vopt family=$(FAMILY) \
	--vopt cst=$(CST) $(NEXTPNR_SDC)

	$(RUN) gowin_pack -d $(FAMILY) -o $(BITSTREAM) $(PNR_JSON)

flash:
	$(RUN) openFPGALoader $(BITSTREAM)

flash-permanent:
	$(RUN) openFPGALoader -f $(BITSTREAM)

detect:
	$(RUN) openFPGALoader --detect

clean:
	rm -rf $(BUILD_DIR) *.json *.fs
