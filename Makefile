# TODO: this is just the first version
FOLD = rfcfold   # Using rfcfold as the folding script
FIGURES_DIR = figures
FOLDED_DIR = folded_figures

# Create the folded_figures directory if it doesn't exist
$(FOLDED_DIR):
	mkdir -p $(FOLDED_DIR)

# Process each file from figures and output to folded_figures
$(FOLDED_DIR)/%: $(FIGURES_DIR)/% | $(FOLDED_DIR)
	@echo "Processing $< -> $@"  # Debug: Show the input and output files
	$(FOLD) -i $< -o $@

# Define a list of all input files in figures
FILES = $(wildcard $(FIGURES_DIR)/*)
FOLDED_FILES = $(patsubst $(FIGURES_DIR)/%, $(FOLDED_DIR)/%, $(FILES))

# Show all files before processing
show-files:
	@echo "Files to be processed: $(FILES)"

# Force all files to be processed
all: show-files $(FOLDED_FILES)

.PHONY: all show-files

