# Catalog Maintenance Guide

## Overview

The `.kata-catalog.yaml` file contains metadata about the entire kata catalog. Some sections need to be updated when katas are added, modified, or removed.

## Sections of .kata-catalog.yaml

### 1. Static Configuration (Manual Updates)

These sections are edited manually when needed:

```yaml
catalog:
  name: "Official CodeMie Kata Collection"
  description: "..."
  maintainer: "CodeMie Team"
  repository: "https://github.com/..."
  version: "1.0.0"  # Update when making breaking changes

config:
  auto_publish: true      # Change import behavior
  default_creator: "system"
  allow_updates: true
  update_strategy: "replace"  # replace | merge | skip
```

**When to update:**
- `catalog.version`: Major repository restructuring
- `catalog.repository`: Repository URL changes
- `config.*`: Change import behavior for platform

---

### 2. Auto-Generated Statistics (Automatic Updates)

These sections should be automatically updated:

```yaml
stats:
  total_katas: 1
  last_updated: "2025-12-09T15:30:00Z"
  by_level:
    beginner: 1
    intermediate: 0
    advanced: 0
  by_status:
    draft: 0
    published: 1
    archived: 0
```

**When to update:**
- After adding/removing katas
- After changing kata status or level
- Before committing changes

---

### 3. Import History (Optional Manual Updates)

Track significant imports:

```yaml
import_history:
  - date: "2025-12-09T15:30:00Z"
    imported_by: "user@example.com"
    katas_imported: 1
    notes: "Initial catalog setup"
```

**When to update:**
- After major batch imports
- When migrating from other sources
- For audit trail purposes

---

## Update Methods

### Method 1: Manual Update (Simple)

For small repositories, manually update the stats:

1. Count katas in `katas/` directory
2. Count by level (check each `kata.yaml`)
3. Count by status (check each `kata.yaml`)
4. Update timestamp to current UTC time

**Example:**
```yaml
stats:
  total_katas: 5  # Count directories in katas/
  last_updated: "2025-12-09T16:00:00Z"  # Current UTC time
  by_level:
    beginner: 3    # Count kata.yaml files with level: beginner
    intermediate: 2
    advanced: 0
  by_status:
    draft: 1
    published: 4
    archived: 0
```

---

### Method 2: Update Script (Automated)

Use the provided Python script for automatic updates.

#### Prerequisites

Install PyYAML:
```bash
pip install pyyaml
```

Or use the CodeMie platform's Python environment:
```bash
cd /path/to/codemie
source venv/bin/activate
pip install pyyaml
```

#### Run Manually

```bash
cd /Users/Vadym_Vlasenko/AI/codemie/codemie-katas

# Run update script
python3 scripts/update_catalog.py

# Verify changes
git diff .kata-catalog.yaml

# Commit if changes look correct
git add .kata-catalog.yaml
git commit -m "Update catalog statistics"
```

#### Setup Git Hook (Automatic on Commit)

Make updates automatic before each commit:

```bash
cd /Users/Vadym_Vlasenko/AI/codemie/codemie-katas

# Setup hooks (one-time)
./scripts/setup_hooks.sh

# Now catalog updates automatically before commits
git add katas/new-kata/
git commit -m "Add new kata"
# ↑ Hook runs automatically, updates .kata-catalog.yaml
```

---

### Method 3: Bash Script (No Dependencies)

If Python/PyYAML isn't available, use this bash alternative:

```bash
#!/usr/bin/env bash
# scripts/update_catalog_simple.sh

# Count katas
TOTAL=$(find katas -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# Count by level (requires grep/awk)
BEGINNER=$(grep -r "^level: .*beginner" katas/*/kata.yaml | wc -l | tr -d ' ')
INTERMEDIATE=$(grep -r "^level: .*intermediate" katas/*/kata.yaml | wc -l | tr -d ' ')
ADVANCED=$(grep -r "^level: .*advanced" katas/*/kata.yaml | wc -l | tr -d ' ')

# Count by status
DRAFT=$(grep -r "^status: .*draft" katas/*/kata.yaml | wc -l | tr -d ' ')
PUBLISHED=$(grep -r "^status: .*published" katas/*/kata.yaml | wc -l | tr -d ' ')
ARCHIVED=$(grep -r "^status: .*archived" katas/*/kata.yaml | wc -l | tr -d ' ')

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "📊 Catalog Statistics:"
echo "   Total: $TOTAL"
echo "   Beginner: $BEGINNER | Intermediate: $INTERMEDIATE | Advanced: $ADVANCED"
echo "   Draft: $DRAFT | Published: $PUBLISHED | Archived: $ARCHIVED"
echo "   Updated: $TIMESTAMP"
echo ""
echo "⚠️  Please manually update .kata-catalog.yaml with these values"
```

Save and run:
```bash
chmod +x scripts/update_catalog_simple.sh
./scripts/update_catalog_simple.sh
```

---

## Workflow Examples

### Adding a New Kata

```bash
# 1. Create kata
mkdir -p katas/new-kata
# ... create kata.yaml and steps.md ...

# 2. Update catalog (choose one method)

# Method A: Automatic (if hooks installed)
git add katas/new-kata/
git commit -m "Add kata: New Kata"
# ↑ Hook updates catalog automatically

# Method B: Manual script
python3 scripts/update_catalog.py
git add .kata-catalog.yaml katas/new-kata/
git commit -m "Add kata: New Kata"

# Method C: Manual edit
# Edit .kata-catalog.yaml, update stats section
# total_katas: 1 → 2
# by_level.beginner: 1 → 2  (if beginner level)
# by_status.published: 1 → 2  (if published)
# last_updated: current timestamp
git add .kata-catalog.yaml katas/new-kata/
git commit -m "Add kata: New Kata"
```

### Updating Kata Status

```bash
# Changed kata from draft to published

# Update kata.yaml
sed -i '' 's/status: draft/status: published/' katas/my-kata/kata.yaml

# Update catalog
python3 scripts/update_catalog.py
# Or manually: draft: 1→0, published: 1→2

git add katas/my-kata/kata.yaml .kata-catalog.yaml
git commit -m "Publish kata: My Kata"
```

### Removing a Kata

```bash
# Remove kata directory
git rm -r katas/old-kata/

# Update catalog
python3 scripts/update_catalog.py
# Or manually: total_katas: 5→4, adjust by_level/by_status

git add .kata-catalog.yaml
git commit -m "Remove kata: Old Kata"
```

---

## Troubleshooting

### Script Fails with "ModuleNotFoundError: No module named 'yaml'"

Install PyYAML:
```bash
pip3 install pyyaml
```

Or use bash alternative (see Method 3 above).

### Hook Not Running

Check if hooks are enabled:
```bash
git config core.hooksPath
# Should show: .githooks

# If empty, run setup again
./scripts/setup_hooks.sh
```

### Statistics Don't Match

Manually verify:
```bash
# Count katas
ls -la katas/ | grep "^d" | wc -l

# Count beginner katas
grep -r "^level: beginner" katas/*/kata.yaml | wc -l

# Count published katas
grep -r "^status: published" katas/*/kata.yaml | wc -l
```

---

## Best Practices

1. **Update Before Push**
   - Always ensure catalog is current before pushing to GitHub
   - Prevents merge conflicts and confusion

2. **Verify After Updates**
   - Check `git diff .kata-catalog.yaml` before committing
   - Ensure numbers make sense

3. **Use Hooks for Automation**
   - Setup hooks once, forget about manual updates
   - Hooks ensure consistency

4. **Track Major Changes**
   - Add entries to `import_history` for significant updates
   - Helps with audit trail and troubleshooting

5. **Keep Config Static**
   - Only change `config` section when needed
   - Document reasons for config changes in commits

---

## Platform Import Behavior

When the CodeMie platform imports this repository:

1. **Reads Configuration**
   ```yaml
   config:
     auto_publish: true      # Publish katas on import
     allow_updates: true     # Update existing katas
     update_strategy: replace  # How to handle updates
   ```

2. **Uses Statistics for Validation**
   - Compares `stats.total_katas` with actual count
   - Warns if mismatch detected

3. **May Update Catalog**
   - Platform can optionally update statistics
   - Pushes changes back to repository (if configured)

---

## Summary

| Update Method | Pros | Cons | Best For |
|--------------|------|------|----------|
| **Manual** | No dependencies, simple | Error-prone, tedious | Small repos (1-5 katas) |
| **Python Script** | Accurate, fast | Requires PyYAML | Medium+ repos (5+ katas) |
| **Git Hook** | Fully automatic | Initial setup needed | All repos (best practice) |
| **Bash Script** | No Python needed | Less accurate, platform-specific | Linux/Mac environments |

**Recommendation**: Use Git hooks for automatic updates (Method 2).

---

## Questions?

- Check `scripts/update_catalog.py` for implementation details
- Review `.githooks/pre-commit` for hook behavior
- See example `.kata-catalog.yaml` for expected format

---

**Last Updated**: 2025-12-09
**Applies To**: CodeMie Kata Catalog v1.0.0
