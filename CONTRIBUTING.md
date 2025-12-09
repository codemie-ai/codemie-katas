# Contributing to CodeMie Kata Catalog

Thank you for your interest in contributing to the CodeMie Kata Catalog! This guide will help you create high-quality katas that provide value to the developer community.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Kata Structure](#kata-structure)
- [Writing Guidelines](#writing-guidelines)
- [Submission Process](#submission-process)
- [Review Criteria](#review-criteria)

## 🚀 Getting Started

### Prerequisites

1. Familiarity with Git and GitHub
2. Understanding of the topic you want to create a kata about
3. Basic knowledge of YAML and Markdown

### Setting Up

1. Fork this repository
2. Clone your fork locally
3. Create a new branch for your kata

```bash
git clone https://github.com/YOUR_USERNAME/codemie-katas.git
cd codemie-katas
git checkout -b kata/your-kata-name
```

## 📁 Kata Structure

Each kata consists of two files in a dedicated directory:

```
katas/
└── your-kata-name/
    ├── kata.yaml    # Metadata and configuration
    └── steps.md     # Step-by-step instructions
```

### Directory Naming

- Use **kebab-case** (lowercase with hyphens)
- Be descriptive but concise
- Examples: `mastering-codemie-code-cli`, `build-rag-pipeline`, `deploy-langchain-agent`

### kata.yaml Format

```yaml
id: "your-kata-name"              # Must match directory name
version: "1.0.0"                  # Semantic versioning
title: "Your Kata Title"
description: "Brief description of learning objectives"
level: "beginner"                 # beginner | intermediate | advanced
duration_minutes: 30              # Realistic estimate (5-240 minutes)
tags:                             # 1-10 tags from kata-tags.yaml
  - "tag-1"
  - "tag-2"
roles:                            # 1-10 roles from kata-roles.yaml
  - "developer"
  - "ai-engineer"
image_url: "https://..."          # Optional: 400x300px recommended
links:                            # Optional: External resources
  - title: "Documentation"
    url: "https://..."
    type: "documentation"         # documentation | guide | video | blog | tutorial
references:                       # Optional: Further reading
  - "Reference 1"
  - "Reference 2"
status: "published"               # draft | published | archived
author:                           # Optional but recommended
  name: "Your Name"
  email: "your.email@example.com"
  github: "yourusername"
```

### steps.md Format

Use Markdown with the following structure:

```markdown
# Kata Title

Brief introduction explaining what the kata is about and what learners will achieve.

## 🎯 Challenge 1: Title (X min)

**Goal:** Clear objective for this challenge

### Instructions

Step-by-step instructions with code examples:

\`\`\`bash
command-example
\`\`\`

\`\`\`python
# Code example
def example():
    pass
\`\`\`

**✅ Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**🏆 Bonus:** (Optional)
- Extra challenges for advanced learners

---

## 🎯 Challenge 2: Title (X min)

...

---

## 🎓 Kata Complete!

### What You've Accomplished

✅ Achievement 1
✅ Achievement 2
✅ Achievement 3

### Next Steps

Suggestions for what to do next...
```

## ✍️ Writing Guidelines

### Content Quality

1. **Clear Learning Objectives**
   - State what learners will accomplish
   - Explain the practical value
   - Set realistic expectations

2. **Step-by-Step Instructions**
   - Break down complex tasks into manageable steps
   - Provide context for each step
   - Include time estimates
   - Use clear, concise language

3. **Code Examples**
   - Test all code examples before submission
   - Use proper syntax highlighting
   - Include comments for complex code
   - Provide complete, runnable examples

4. **Success Criteria**
   - Define clear, measurable outcomes
   - Use checkboxes for tracking progress
   - Include verification steps

5. **Troubleshooting**
   - Anticipate common issues
   - Provide solutions or workarounds
   - Include helpful error messages

### Formatting

- Use **emoji sparingly** for visual markers (🎯, ✅, 🏆, 🎓)
- Use **bold** for emphasis and **code blocks** for commands
- Include **screenshots or diagrams** where helpful
- Keep paragraphs short and scannable

### Accessibility

- Use descriptive link text
- Provide alt text for images
- Ensure code examples are readable
- Test with different screen sizes

## 📤 Submission Process

1. **Create Your Kata**
   ```bash
   mkdir -p katas/your-kata-name
   # Create kata.yaml and steps.md
   ```

2. **Test Your Kata**
   - Complete the kata yourself
   - Verify all commands work
   - Check timing estimates
   - Test on different environments if possible

3. **Validate Format**
   - Ensure YAML is valid
   - Check that all tags/roles exist in the platform
   - Verify links are accessible
   - Proofread for typos and clarity

4. **Commit and Push**
   ```bash
   git add katas/your-kata-name/
   git commit -m "Add kata: Your Kata Title"
   git push origin kata/your-kata-name
   ```

5. **Create Pull Request**
   - Use a descriptive title: "Add kata: Your Kata Title"
   - Fill out the PR template
   - Provide context and rationale
   - Link to related issues if applicable

## 🔍 Review Criteria

Your kata will be reviewed for:

### Technical Accuracy
- [ ] All code examples are correct and tested
- [ ] Instructions are technically sound
- [ ] Prerequisites are clearly stated
- [ ] Dependencies are documented

### Educational Value
- [ ] Clear learning objectives
- [ ] Appropriate difficulty level
- [ ] Good progression of concepts
- [ ] Practical, real-world application

### Quality Standards
- [ ] Well-structured and organized
- [ ] Clear, concise writing
- [ ] Proper formatting and syntax
- [ ] Complete and accurate metadata

### Completeness
- [ ] All required fields in kata.yaml
- [ ] Success criteria defined
- [ ] Time estimates provided
- [ ] Links and references included

## 🎯 Best Practices

### Do's ✅

- **Test everything** - Complete your own kata before submitting
- **Be specific** - Provide exact commands and clear instructions
- **Consider your audience** - Match content to the stated difficulty level
- **Provide context** - Explain why, not just how
- **Include examples** - Show, don't just tell
- **Verify links** - Ensure all external links work
- **Use consistent formatting** - Follow the established patterns

### Don'ts ❌

- **Don't assume knowledge** - Explain prerequisites clearly
- **Don't skip steps** - Even "obvious" steps should be documented
- **Don't use vague language** - Be precise and specific
- **Don't forget error handling** - Include troubleshooting tips
- **Don't ignore timing** - Provide realistic time estimates
- **Don't copy without attribution** - Always credit sources
- **Don't submit untested content** - Test before submitting

## 🔄 Updating Existing Katas

To update an existing kata:

1. Increment the `version` field in `kata.yaml`
2. Document changes in your commit message
3. Submit a PR with clear description of updates

Version format:
- **Major (1.0.0 → 2.0.0)**: Breaking changes, significant restructuring
- **Minor (1.0.0 → 1.1.0)**: New content, additional challenges
- **Patch (1.0.0 → 1.0.1)**: Fixes, clarifications, minor updates

## 📞 Questions?

- Open an issue for general questions
- Tag maintainers in your PR for specific feedback
- Check existing katas for examples and inspiration

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as this repository (MIT License).

---

Thank you for contributing to the CodeMie Kata Catalog! Your efforts help developers worldwide learn and grow their AI development skills. 🚀
