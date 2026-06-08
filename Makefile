EXAMPLES := \
	tangnano9k-blink \
	tangnano9k-and \
	tangnano9k-or \
	tangnano9k-not \
	tangnano9k-hdmi \
	tangnano9k-pong \
	tangnano9k-picotiny

.PHONY: all hdmi pong picotiny $(EXAMPLES) clean

all: $(EXAMPLES)

hdmi:
	$(MAKE) -C tangnano9k-hdmi

pong:
	$(MAKE) -C tangnano9k-pong

picotiny:
	$(MAKE) -C tangnano9k-picotiny

$(EXAMPLES):
	$(MAKE) -C $@

clean:
	for example in $(EXAMPLES); do $(MAKE) -C $$example clean; done
