EXAMPLES := \
	blink \
	and \
	or \
	not \
	hdmi \
	pong \
	picotiny \
	digital-labs

.PHONY: all $(EXAMPLES) clean

all: $(EXAMPLES)

$(EXAMPLES):
	$(MAKE) -C $@

clean:
	for example in $(EXAMPLES); do $(MAKE) -C $$example clean; done
