# CodeMie Kata Catalog

Welcome to the official CodeMie Kata Catalog! This repository contains curated AI development katas that can be imported into the CodeMie platform.

## 📚 What are Katas?

Katas are hands-on coding challenges designed to help developers learn and practice AI development skills. Each kata is a self-contained exercise with clear learning objectives, step-by-step instructions, and success criteria.

## 🗂️ Repository Structure

```
codemie-katas/
├── README.md                    # This file
├── .kata-catalog.yaml          # Catalog metadata
└── katas/                      # Kata collection
    ├── mastering-codemie-code-cli/
    │   ├── kata.yaml           # Kata metadata
    │   └── steps.md            # Step-by-step instructions
    └── [other-katas]/
```

## 🚀 Using This Catalog

### For CodeMie Platform Administrators

Import katas from this repository into your CodeMie instance:

```bash
# Via API
curl -X POST https://your-codemie-instance.com/v1/katas/import \
  -H "user-id: your-admin-id" \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/codemie/codemie-katas",
    "branch": "main",
    "auto_publish": true,
    "allow_updates": true
  }'
```

Or configure automatic import on startup in `config/kata-sources.yaml`:

```yaml
sources:
  - repository: "https://github.com/codemie/codemie-katas"
    branch: "main"
    auto_publish: true
    allow_updates: true
    enabled: true
```

### For Kata Authors

To contribute a new kata:

1. Create a new directory under `katas/` with a kebab-case name
2. Create `kata.yaml` with kata metadata (see format below)
3. Create `steps.md` with step-by-step instructions
4. Submit a pull request

## 📝 Kata Format

Each kata consists of two files:

### `kata.yaml` - Metadata

```yaml
id: "your-kata-id"              # Unique identifier (kebab-case)
version: "1.0.0"                # Semantic versioning
title: "Your Kata Title"
description: "Brief description of what students will learn"
level: "beginner"               # beginner | intermediate | advanced
duration_minutes: 30            # Estimated completion time (5-240)
tags:                           # Up to 10 tags
  - "tag-id-1"
  - "tag-id-2"
roles:                          # Up to 10 target roles
  - "developer"
  - "ai-engineer"
image_url: "https://..."        # Card image (400x300px recommended)
links:                          # External resources
  - title: "Documentation"
    url: "https://..."
    type: "documentation"
references:                     # Further reading
  - "Reference 1"
  - "Reference 2"
status: "published"             # draft | published | archived
```

### `steps.md` - Instructions

Markdown file with step-by-step instructions, code examples, and success criteria.

**Format Guidelines:**
- Use `## Step N:` headers for main steps
- Include estimated time for each step (e.g., `## Step 1: Setup (5 min)`)
- Add code blocks with syntax highlighting
- Use checkboxes for success criteria: `- [ ] Task completed`
- Include troubleshooting tips where relevant

## 🏷️ Available Tags

See the CodeMie platform configuration for the complete list of available tags and roles:
- Tags: `config/categories/kata-tags.yaml`
- Roles: `config/categories/kata-roles.yaml`

Common tags include:
- `getting-started`, `ai-agents`, `langchain`, `langgraph`
- `prompt-engineering`, `rag`, `vector-search`
- `production`, `observability`, `optimization`

Common roles include:
- `developer`, `ai-engineer`, `data-scientist`
- `product-manager`, `devops`, `architect`

## 🔄 Version Control

When updating an existing kata:
1. Increment the `version` field in `kata.yaml` (semantic versioning)
2. Update the kata content as needed
3. Submit a pull request with a clear description of changes

The CodeMie platform will detect changes and update the kata automatically if configured to do so.

## 📊 Catalog Statistics

- **Total Katas**: 1
- **Last Updated**: 2025-12-09

## 🤝 Contributing

We welcome contributions! Please:
1. Follow the kata format guidelines
2. Ensure all code examples are tested
3. Use clear, concise language
4. Include relevant links and references
5. Submit a pull request with a descriptive title

## 📄 License

This catalog is licensed under the MIT License. Individual katas may have their own licenses as specified in their metadata.

## 📞 Support

For questions or issues:
- Open an issue in this repository
- Contact the CodeMie team
- Visit the CodeMie documentation

---

**Maintained by**: CodeMie Team
**Repository**: https://github.com/codemie/codemie-katas
