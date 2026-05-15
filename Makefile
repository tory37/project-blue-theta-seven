# Godot Project Makefile
# Use 'make help' to see available commands

GDLINT = $(shell which gdlint 2>/dev/null || echo ~/.local/bin/gdlint)

.PHONY: help test lint

help:
	@echo "Available commands:"
	@echo "  make test      Run all GUT unit tests headlessly"
	@echo "  make lint      Run gdlint on the project"

test:
	@echo "Running GUT tests..."
	@godot --headless -s addons/gut/gut_cmdln.gd -gexit

lint:
	@echo "Running gdlint..."
	@$(GDLINT) .
