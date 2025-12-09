#!/usr/bin/env bash
#
# Simple catalog statistics calculator (no Python required)
# This script counts katas and provides statistics for manual update
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Calculating Catalog Statistics...${NC}\n"

# Find repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
cd "$REPO_ROOT"

# Check if katas directory exists
if [ ! -d "katas" ]; then
    echo "❌ Error: katas/ directory not found"
    exit 1
fi

# Count total katas (directories with kata.yaml and steps.md)
TOTAL=0
for dir in katas/*/; do
    if [ -f "${dir}kata.yaml" ] && [ -f "${dir}steps.md" ]; then
        TOTAL=$((TOTAL + 1))
    fi
done

# Count by level
BEGINNER=0
INTERMEDIATE=0
ADVANCED=0

for kata_file in katas/*/kata.yaml; do
    if [ -f "$kata_file" ]; then
        if grep -q "^level: ['\"]beginner['\"]" "$kata_file" || grep -q "^level: beginner" "$kata_file"; then
            BEGINNER=$((BEGINNER + 1))
        elif grep -q "^level: ['\"]intermediate['\"]" "$kata_file" || grep -q "^level: intermediate" "$kata_file"; then
            INTERMEDIATE=$((INTERMEDIATE + 1))
        elif grep -q "^level: ['\"]advanced['\"]" "$kata_file" || grep -q "^level: advanced" "$kata_file"; then
            ADVANCED=$((ADVANCED + 1))
        fi
    fi
done

# Count by status
DRAFT=0
PUBLISHED=0
ARCHIVED=0

for kata_file in katas/*/kata.yaml; do
    if [ -f "$kata_file" ]; then
        if grep -q "^status: ['\"]draft['\"]" "$kata_file" || grep -q "^status: draft" "$kata_file"; then
            DRAFT=$((DRAFT + 1))
        elif grep -q "^status: ['\"]published['\"]" "$kata_file" || grep -q "^status: published" "$kata_file"; then
            PUBLISHED=$((PUBLISHED + 1))
        elif grep -q "^status: ['\"]archived['\"]" "$kata_file" || grep -q "^status: archived" "$kata_file"; then
            ARCHIVED=$((ARCHIVED + 1))
        fi
    fi
done

# Get current timestamp (UTC)
if command -v date &> /dev/null; then
    if date --version &> /dev/null 2>&1; then
        # GNU date
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    else
        # BSD date (macOS)
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    fi
else
    TIMESTAMP="YYYY-MM-DDTHH:MM:SSZ"
fi

# Display results
echo -e "${GREEN}✅ Catalog Statistics:${NC}"
echo ""
echo "Total Katas: $TOTAL"
echo ""
echo "By Level:"
echo "  • Beginner:     $BEGINNER"
echo "  • Intermediate: $INTERMEDIATE"
echo "  • Advanced:     $ADVANCED"
echo ""
echo "By Status:"
echo "  • Draft:        $DRAFT"
echo "  • Published:    $PUBLISHED"
echo "  • Archived:     $ARCHIVED"
echo ""
echo "Last Updated: $TIMESTAMP"
echo ""

# Check if numbers add up
LEVEL_TOTAL=$((BEGINNER + INTERMEDIATE + ADVANCED))
STATUS_TOTAL=$((DRAFT + PUBLISHED + ARCHIVED))

if [ "$LEVEL_TOTAL" -ne "$TOTAL" ] || [ "$STATUS_TOTAL" -ne "$TOTAL" ]; then
    echo -e "${YELLOW}⚠️  Warning: Counts don't match. Some katas may have invalid level/status.${NC}"
    echo "   Level total: $LEVEL_TOTAL (expected: $TOTAL)"
    echo "   Status total: $STATUS_TOTAL (expected: $TOTAL)"
    echo ""
fi

# Provide YAML snippet for copy-paste
echo -e "${BLUE}📋 YAML Snippet for .kata-catalog.yaml:${NC}"
echo ""
cat <<EOF
stats:
  total_katas: $TOTAL
  last_updated: "$TIMESTAMP"
  by_level:
    beginner: $BEGINNER
    intermediate: $INTERMEDIATE
    advanced: $ADVANCED
  by_status:
    draft: $DRAFT
    published: $PUBLISHED
    archived: $ARCHIVED
EOF
echo ""
echo -e "${YELLOW}⚠️  Please manually update the 'stats' section in .kata-catalog.yaml${NC}"
echo ""
