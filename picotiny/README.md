# Tang Nano 9K PicoTiny

Minimal root-level PicoTiny example for the Tang Nano 9K.

This example keeps the pieces needed to build and run the PicoRV32 SoC:

- PicoRV32 CPU
- 8 KiB SRAM
- boot ROM ISP flasher
- SPI flash XIP interface
- UART at 115200 baud
- HDMI terminal with `svo_tcard` background

## Build FPGA Bitstream

```bash
make -C tangnano9k-picotiny
```

Output:

```text
tangnano9k-picotiny/build/picotiny.fs
```

Load to SRAM:

```bash
openFPGALoader -b tangnano9k tangnano9k-picotiny/build/picotiny.fs
```

## Build Firmware

```bash
make -C tangnano9k-picotiny firmware
```

The Makefile defaults to the Linux toolchain installed on this machine:

```text
RISCV_PATH=/usr
RISCV_NAME=riscv64-unknown-elf
```

Override them if needed:

```bash
make -C tangnano9k-picotiny firmware RISCV_PATH=/path/to/toolchain RISCV_NAME=riscv-none-elf
```

## Program User Firmware

After loading the FPGA bitstream, program the user firmware through the PicoTiny UART ISP:

```bash
make -C tangnano9k-picotiny program COMx=/dev/ttyUSB1
```

When prompted, press and release `S1` reset on the Tang Nano 9K.

## Useful Files

- `src/picotiny.v`: top-level SoC
- `src/hdmi/svo_tcard.v`: HDMI background pattern
- `fw/fw-flash/firmware.c`: user firmware
- `fw/fw-brom/isp_flasher.c`: boot ROM ISP firmware
- `sw/pico-programmer.py`: UART flash programmer
