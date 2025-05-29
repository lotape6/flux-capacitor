#!/usr/bin/env bash
# Test_cheatsheet_build.sh - Test that the cheatsheet can be built successfully

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test cheatsheet build
test_cheatsheet_build() {
    echo "Testing cheatsheet build..."
    
    cd "$PROJECT_ROOT/docs/cheatsheet"
    
    # Check if required LaTeX tools are available
    if ! command -v pdflatex >/dev/null 2>&1; then
        echo "SKIP: pdflatex not available, skipping cheatsheet build test"
        return 0
    fi
    
    # Clean and build
    make clean
    if make check; then
        if make all; then
            # Check if PDF was created
            if [ -f "flux-capacitor-cheatsheet.pdf" ]; then
                echo "✓ Cheatsheet PDF successfully created"
                
                # Check PDF file size (should be reasonable size)
                pdf_size=$(stat -c%s "flux-capacitor-cheatsheet.pdf")
                if [ "$pdf_size" -gt 10000 ]; then
                    echo "✓ PDF file size is reasonable ($pdf_size bytes)"
                else
                    echo "✗ PDF file size too small ($pdf_size bytes)"
                    return 1
                fi
                
                return 0
            else
                echo "✗ PDF file was not created"
                return 1
            fi
        else
            echo "✗ Make build failed"
            return 1
        fi
    else
        echo "SKIP: LaTeX prerequisites not available, skipping cheatsheet build test"
        return 0
    fi
}

# Run test
test_cheatsheet_build