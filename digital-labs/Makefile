PRACTICAS := \
	01_sumador_n_bits \
	02_restador_n_bits \
	03_comparador_n_bits \
	04_decodificador_7_segmentos \
	05_decodificador_16_segmentos \
	06_restador_a_7_segmentos \
	07_alu_n_bits \
	08_senal_reloj \
	09_contador_ascendente \
	10_contador_descendente \
	11_contador_ascendente_descendente \
	12_contador_arranque_paro_reset \
	13_maquina_moore \
	14_maquina_mealy

.PHONY: all clean $(PRACTICAS)

all: $(PRACTICAS)

$(PRACTICAS):
	$(MAKE) -C $@

clean:
	for practica in $(PRACTICAS); do $(MAKE) -C $$practica clean; done
