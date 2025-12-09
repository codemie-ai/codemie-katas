#!/usr/bin/env bash
#
# Setup Git hooks for automatic catalog updates
#

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.githooks"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "🔧 Setting up Git hooks..."

# Configure Git to use .githooks directory
git config core.hooksPath "$HOOKS_DIR"

echo "✅ Git hooks configured"
echo "   Hooks directory: $HOOKS_DIR"
echo ""
echo "Pre-commit hook will now automatically update .kata-catalog.yaml"
echo "before each commit."
