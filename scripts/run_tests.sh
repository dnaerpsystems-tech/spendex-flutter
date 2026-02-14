#!/bin/bash
# Spendex Test Runner Script
# Runs Flutter tests with coverage reporting

set -e

echo "======================================"
echo "  Spendex Test Runner"
echo "======================================"
echo ""

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous coverage data
rm -rf coverage/

echo -e "${YELLOW}[1/4] Installing dependencies...${NC}"
flutter pub get

echo ""
echo -e "${YELLOW}[2/4] Running tests with coverage...${NC}"
flutter test --coverage --reporter=expanded

echo ""
echo -e "${YELLOW}[3/4] Generating coverage report...${NC}"
if [ -f coverage/lcov.info ]; then
    # Count lines for coverage summary
    LINES_FOUND=$(grep -c "^DA:" coverage/lcov.info 2>/dev/null || echo "0")
    LINES_HIT=$(grep "^DA:" coverage/lcov.info 2>/dev/null | grep -v ",0$" | wc -l || echo "0")
    
    if [ "$LINES_FOUND" -gt 0 ]; then
        COVERAGE_PCT=$((LINES_HIT * 100 / LINES_FOUND))
        echo "Lines found: $LINES_FOUND"
        echo "Lines hit: $LINES_HIT"
        echo -e "Coverage: ${GREEN}${COVERAGE_PCT}%${NC}"
        
        # Check threshold
        THRESHOLD=80
        if [ "$COVERAGE_PCT" -lt "$THRESHOLD" ]; then
            echo -e "${RED}Warning: Coverage is below ${THRESHOLD}%${NC}"
        fi
    fi
else
    echo -e "${RED}Coverage file not found${NC}"
fi

echo ""
echo -e "${YELLOW}[4/4] Summary${NC}"
echo "======================================"

# Count test files
TEST_FILES=$(find test -name "*_test.dart" -type f 2>/dev/null | wc -l)
echo "Test files: $TEST_FILES"
echo "Coverage report: coverage/lcov.info"

echo ""
echo -e "${GREEN}Tests completed successfully!${NC}"
echo ""
echo "To view HTML coverage report:"
echo "  1. Install lcov: apt-get install lcov (or brew install lcov)"
echo "  2. Generate HTML: genhtml coverage/lcov.info -o coverage/html"
echo "  3. Open: coverage/html/index.html"
