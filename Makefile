.PHONY: clean all
VHEADERS:=define.h parameter.h
VFILES:=test.v addrdec.v sram.v top.v timer.v busarb.v slaves.v dmactr.v decoder.v alu.v core.v

all: dump.vcd

dump.vcd: $(VFILES) $(VHEADERS)
	ncverilog +access+r $(VFILES)

clean:
	rm -rf INCA_libs ncverilog.log ncverilog.key dump.vcd sim.log
	rm -rf *.vcd *.trn *.dsn

