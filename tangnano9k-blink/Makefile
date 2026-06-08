TOP=top
HDL?=verilog

DEVICE=GW1NR-LV9QN88PC6/I5
FAMILY=GW1N-9C
CST=tangnano9k.cst

ifeq ($(HDL),vhdl)
SYNTH=yosys -m ghdl -p "ghdl $(TOP).vhd -e $(TOP); synth_gowin -top $(TOP) -json $(TOP).json"
else
SYNTH=yosys -p "read_verilog $(TOP).v; synth_gowin -top $(TOP) -json $(TOP).json"
endif

all:
	$(SYNTH)
	nextpnr-himbaechel \
		--json $(TOP).json \
		--write $(TOP)_pnr.json \
		--device $(DEVICE) \
		--vopt family=$(FAMILY) \
		--vopt cst=$(CST)

	gowin_pack -d $(FAMILY) -o $(TOP).fs $(TOP)_pnr.json

flash:
	openFPGALoader $(TOP).fs

flash-permanent:
	openFPGALoader -f $(TOP).fs

detect:
	openFPGALoader --detect

clean:
	rm -f *.json *.fs