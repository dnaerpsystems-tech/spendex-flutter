#!/bin/bash
# Spendex Code Analysis Script
# Runs static analysis and formatting checks

set -e

echo "======================================"
echo "  Spendex Code Analyzer"
echo "======================================"
echo ""

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Navigate to project root
cd "$(dirname "$0")/.."

# Track if any checks fail
FAILED=0

echo -e "${YELLOW}[1/4] Checking dependencies...${NC}"
flutter pub get

echo ""
echo -e "${YELLOW}[2/4] Running static analysis...${NC}"
if flutter analyze --fatal-infos; then
    echo -e "${GREEN}Static analysis passed!${NC}"
else
    echo -e "${RED}Static analysis failed!${NC}"
    FAILED=1
fi

echo ""
echo -e "${YELLOW}[3/4] Checking code formatting...${NC}"
if dart format --set-exit-if-changed .; then
    echo -e "${GREEN}Code formatting is correct!${NC}"
else
    echo -e "${RED}Code formatting issues found!${NC}"
    echo "Run 'dart format .' to fix formatting issues
    FAILED=1
fi

echo 
echo -e [4/4] Checking for unused dependencies...
flutter pub outdated || true

echo 
echo ======================================
if [  -eq 0 ]; then
    echo -e  All checks passed/srv/spendex/scripts/build_release.sh  {NC}"
else
    echo -e "${RED}  Some checks failed!${NC}"
    exit 1
fi
echo "======================================"
