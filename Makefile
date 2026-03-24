.PHONY: help clean

.DEFAULT_GOAL := help

help:
	@echo "========================================"
	@echo "   DSCI 525 Milestone 1 - Makefile"
	@echo "========================================"
	@echo "Commands List:"
	@echo "  make help  - This help information"
	@echo "  make clean - Clean up all data in data directory"

clean:
	@echo "Cleaning up data directory..."
	rm -rf data/*
	@echo "Data directory is now empty."