SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: help docker-check setup env-check prepare-adder-wave verify-saved
help:
	@printf '%s\n' \
	  'make docker-check / setup / env-check' \
	  'make sim DESIGN=my_cpu4|adder_lab|selector_lab|cpu_program_lab' \
	  'make sim DESIGN=adder_lab ADDER_TEST=publication|one|five' \
	  'make sim DESIGN=adder_lab ADDER_VARIANT=drop-carry (expected failure)' \
	  'make sim DESIGN=cpu_program_lab PROGRAM_ADD=4' \
	  'make synth-adder / synth-adder-sky130' \
	  'make compare-adder SYNTH_RUN=<saved or newly synthesized run>' \
	  'make gds JOBS=2' \
	  'make prepare-adder-wave / verify-saved (Python 3 only)'
docker-check:
	docker version
setup:
	bash scripts/portable-eda.sh setup
env-check:
	bash scripts/portable-eda.sh versions
prepare-adder-wave:
	python3 scripts/prepare-adder-wave.py
verify-saved:
	python3 scripts/verify-saved.py
	python3 scripts/prepare-adder-wave.py --check

# Experimental TD4 core flow; programs/ROM remain outside the physical core.
DESIGN ?= my_cpu4
JOBS ?= 2
ADDER_TEST ?= five
ADDER_VARIANT ?= good
PROGRAM_ADD ?= 3
.PHONY: sim gds
.PHONY: synth-adder synth-adder-sky130 compare-adder
synth-adder:
	DESIGN=adder_lab bash scripts/portable-eda.sh synth

synth-adder-sky130:
	DESIGN=adder_lab bash scripts/portable-eda.sh synth-sky130

compare-adder:
	DESIGN=adder_lab SYNTH_RUN="$(SYNTH_RUN)" bash scripts/portable-eda.sh compare

sim:
	DESIGN="$(DESIGN)" ADDER_TEST="$(ADDER_TEST)" ADDER_VARIANT="$(ADDER_VARIANT)" PROGRAM_ADD="$(PROGRAM_ADD)" bash scripts/portable-eda.sh sim

gds:
	DESIGN="$(DESIGN)" bash scripts/portable-eda.sh gds "$(JOBS)"
