# Catalog Maintenance Scripts

This directory contains scripts for maintaining the `.kata-catalog.yaml` file.

## Available Scripts

### 1. `update_catalog_simple.sh` ✅ Recommended

**Bash script that calculates catalog statistics (no dependencies required)**

```bash
./scripts/update_catalog_simple.sh
```

**What it does:**
- Scans `katas/` directory for all kata.yaml files
- Counts total katas
- Breaks down by level (beginner/intermediate/advanced)
- Breaks down by status (draft/published/archived)
- Generates timestamp
- Outputs YAML snippet for copy-paste

**Output:**
```
📊 Calculating Catalog Statistics...

✅ Catalog Statistics:

Total Katas: 1

By Level:
  • Beginner:     1
  • Intermediate: 0
  • Advanced:     0

By Status:
  • Draft:        0
  • Published:    1
  • Archived:     0

Last Updated: 2025-12-09T18:28:36Z

📋 YAML Snippet for .kata-catalog.yaml:

stats:
  total_katas: 1
  last_updated: "2025-12-09T18:28:36Z"
  ...
```

**Usage:**
1. Run the script
2. Copy the YAML snippet
3. Replace the `stats:` section in `.kata-catalog.yaml`
4. Commit changes

---

### 2. `update_catalog.py` (Advanced)

**Python script that automatically updates .kata-catalog.yaml**

**Prerequisites:**
```bash
pip install pyyaml
```

**Usage:**
```bash
python3 scripts/update_catalog.py
```

**What it does:**
- Scans and parses all kata.yaml files
- Calculates statistics
- **Automatically updates** `.kata-catalog.yaml`
- Preserves comments and formatting

**Advantages:**
- Fully automatic
- No copy-paste needed
- More accurate parsing

**Disadvantages:**
- Requires PyYAML dependency
- More complex

---

### 3. `setup_hooks.sh` (Optional)

**Sets up Git hooks for automatic catalog updates**

```bash
./scripts/setup_hooks.sh
```

**What it does:**
- Configures Git to use `.githooks/` directory
- Enables pre-commit hook
- Hook runs `update_catalog.py` before each commit

**Result:**
- `.kata-catalog.yaml` is automatically updated before every commit
- No manual intervention needed

**Requirements:**
- Python 3 with PyYAML installed
- Git repository

---

## Recommended Workflow

### For Most Users (No Dependencies)

Use the bash script before committing:

```bash
# After adding/modifying katas
./scripts/update_catalog_simple.sh

# Copy the YAML output and paste into .kata-catalog.yaml

# Commit changes
git add .kata-catalog.yaml katas/
git commit -m "Add new kata and update catalog"
```

---

### For Advanced Users (Python Available)

Install dependencies once:
```bash
pip install pyyaml
```

Then use automatic script:
```bash
# After adding/modifying katas
python3 scripts/update_catalog.py

# Catalog is automatically updated, just commit
git add .kata-catalog.yaml katas/
git commit -m "Add new kata and update catalog"
```

---

### For Power Users (Hooks)

Setup once:
```bash
pip install pyyaml
./scripts/setup_hooks.sh
```

Then forget about it:
```bash
# Just commit as normal
git add katas/new-kata/
git commit -m "Add new kata"
# ↑ Hook automatically updates catalog before commit
```

---

## Script Comparison

| Feature | Simple Bash | Python Script | Git Hook |
|---------|-------------|---------------|----------|
| **Dependencies** | None | PyYAML | PyYAML + Git |
| **Auto-update** | No | Yes | Yes |
| **Ease of use** | Easy | Easy | Setup once |
| **Reliability** | Good | Excellent | Excellent |
| **Best for** | Quick checks | Regular use | Automation |

---

## Troubleshooting

### Bash Script Shows Wrong Counts

Check kata.yaml files for proper formatting:
```bash
# Verify level field
grep "^level:" katas/*/kata.yaml

# Verify status field
grep "^status:" katas/*/kata.yaml
```

Expected format:
```yaml
level: "beginner"    # or beginner (without quotes)
status: "published"  # or published (without quotes)
```

### Python Script Fails

Install PyYAML:
```bash
pip3 install pyyaml
```

Or use the bash alternative:
```bash
./scripts/update_catalog_simple.sh
```

### Hook Not Running

Verify hook configuration:
```bash
git config core.hooksPath
# Should output: .githooks
```

If empty, run setup again:
```bash
./scripts/setup_hooks.sh
```

---

## Example: Adding a New Kata

```bash
# 1. Create kata
mkdir -p katas/my-new-kata
# ... create kata.yaml and steps.md ...

# 2. Update catalog
./scripts/update_catalog_simple.sh

# 3. Copy YAML output to .kata-catalog.yaml
# (Replace the stats section)

# 4. Commit
git add katas/my-new-kata/ .kata-catalog.yaml
git commit -m "Add kata: My New Kata"
```

---

## Files in This Directory

```
scripts/
├── README.md                     # This file
├── update_catalog_simple.sh      # Bash calculator (recommended)
├── update_catalog.py             # Python auto-updater (advanced)
└── setup_hooks.sh                # Git hooks installer (optional)
```

---

## Questions?

See `CATALOG_MAINTENANCE.md` in the repository root for detailed documentation.
