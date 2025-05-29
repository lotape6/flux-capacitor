# Build system for Flux Capacitor Cheatsheet

LATEX = pdflatex
LATEX_FLAGS = -shell-escape -interaction=nonstopmode

SRC_DIR = src
BUILD_DIR = build
OUTPUT_DIR = .

MAIN_TEX = $(SRC_DIR)/main.tex
OUTPUT_PDF = $(OUTPUT_DIR)/flux-capacitor-cheatsheet.pdf

# Default target
.PHONY: all
all: $(OUTPUT_PDF)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build the PDF
$(OUTPUT_PDF): $(MAIN_TEX) $(SRC_DIR)/flux-cheatsheet-template.tex | $(BUILD_DIR)
	cd $(SRC_DIR) && $(LATEX) $(LATEX_FLAGS) -output-directory=../$(BUILD_DIR) main.tex
	cd $(SRC_DIR) && $(LATEX) $(LATEX_FLAGS) -output-directory=../$(BUILD_DIR) main.tex  # Run twice for references
	cp $(BUILD_DIR)/main.pdf $(OUTPUT_PDF)

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(OUTPUT_PDF)

# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Preview (open PDF if it exists)
.PHONY: preview
preview: $(OUTPUT_PDF)
	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open $(OUTPUT_PDF); \
	elif command -v open >/dev/null 2>&1; then \
		open $(OUTPUT_PDF); \
	else \
		echo "PDF created: $(OUTPUT_PDF)"; \
		echo "Open with your preferred PDF viewer"; \
	fi

# Check prerequisites
.PHONY: check
check:
	@echo "Checking prerequisites..."
	@command -v $(LATEX) >/dev/null 2>&1 || (echo "Error: pdflatex not found. Install texlive-latex-base or similar." && exit 1)
	@echo "✓ pdflatex found"
	@command -v python3 >/dev/null 2>&1 && echo "✓ python3 found" || echo "⚠ python3 not found (optional)"
	@kpsewhich tikz.sty >/dev/null 2>&1 && echo "✓ tikz package found" || (echo "Error: tikz package not found. Install texlive-pictures or similar." && exit 1)
	@kpsewhich tcolorbox.sty >/dev/null 2>&1 && echo "✓ tcolorbox package found" || (echo "Error: tcolorbox package not found. Install texlive-latex-extra or similar." && exit 1)
	@kpsewhich fontawesome.sty >/dev/null 2>&1 && echo "✓ fontawesome package found" || echo "⚠ fontawesome package not found (optional, may cause issues)"
	@echo "Prerequisites check complete!"

# Help
.PHONY: help
help:
	@echo "Flux Capacitor Cheatsheet Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all      - Build the PDF cheatsheet (default)"
	@echo "  clean    - Remove build artifacts and output PDF"  
	@echo "  rebuild  - Clean and build from scratch"
	@echo "  preview  - Build and open the PDF"
	@echo "  check    - Check if required LaTeX packages are installed"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Output: $(OUTPUT_PDF)"