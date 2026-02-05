# Mastering CodeMie Code CLI: Unified Multi-Agent AI Coding Assistant

**CodeMie Code CLI** is a unified AI coding assistant that brings together multiple AI coding agents into one command-line interface. This Kata provides hands-on exercises to install, configure, and use different coding agents with enterprise SSO authentication.

**What You'll Learn:**
- Install and configure CodeMie CLI with Enterprise SSO
- Create profiles with different AI models
- Use specialized coding agents (Built-in, Claude Code, Codex, Gemini CLI)
- Track usage and costs with analytics

---

![CodeMie CLI Demo](https://codemie-ai.github.io/codemie-katas/assets/demo.gif)

---

Let's start! 🚀

---

## 🎯 Challenge 1: Installation

**Goal:** Install CodeMie CLI from npm.

### Install Globally

```bash
npm install -g @codemieai/code
```

### Verify Installation

```bash
codemie --version
codemie --help
```

**✅ Success Criteria:**
- [ ] CLI installed successfully
- [ ] Version command shows version number
- [ ] Help command displays available commands

---

## 🎯 Challenge 2: Setup with CodeMie SSO

**Goal:** Configure your first profile using Enterprise SSO authentication.

### Launch Setup

```bash
codemie setup
```

### Configure Profile

1. **Select:** Add new profile
2. **Choose:** CodeMie SSO - Enterprise SSO Authentication
3. **Authenticate:** Browser opens → Sign in with your credentials
4. **Select Model:** ⭐ claude-4-5-sonnet (Recommended)
5. **Name Profile:** `work-coding`
6. **Save**

**✅ Success Criteria:**
- [ ] Successfully authenticated via SSO
- [ ] Profile created with Claude 4.5 Sonnet
- [ ] Profile appears in list

---

## 🎯 Challenge 3: Verify Configuration

**Goal:** Ensure everything is working correctly.

### Run Health Check

```bash
codemie doctor
```

Expected checks:
- ✅ Node.js version compatible
- ✅ Configuration valid
- ✅ API authentication successful
- ✅ Model access confirmed

### View Profile

```bash
codemie profile list
codemie profile show work-coding
```

**✅ Success Criteria:**
- [ ] All health checks pass
- [ ] Profile shows as authenticated
- [ ] Ready to use agents

---

## 🎯 Challenge 4: Install Coding Agents

**Goal:** Install specialized AI coding agents.

### List Available Agents

```bash
codemie list
```

### Install Agents

```bash
codemie install claude
codemie install codex
codemie install gemini
```

### Verify Installation

```bash
codemie list --installed
codemie doctor --agent claude
```

**✅ Success Criteria:**
- [ ] Claude Code installed
- [ ] Codex installed
- [ ] Gemini installed
- [ ] All agents pass health check

---

## 🎯 Challenge 5: Test Each Coding Agent

**Goal:** Run the same task with each agent and compare results.

### Task: List Files in Current Directory

**Claude Code:**
```bash
codemie-claude
```
```bash
List all files in the current directory with their sizes
```

**OpenAI Codex:**
Switch model for Codex:
```bash
codemie-codex --model gpt-4.1
```
```bash
List all files in the current directory with their sizes
```

**Google Gemini CLI:**
Switch model for Gemini:
```bash
codemie-gemini --model gemini-2.5-flash
```
```bash
List all files in the current directory with their sizes
```

### Compare Results

Observe differences in:
- Response speed
- Output format
- Level of explanation
- Code examples provided

**✅ Success Criteria:**
- [ ] Built-in agent responded
- [ ] Claude Code responded
- [ ] Codex responded
- [ ] Gemini responded
- [ ] Noted differences between agents

**🏆 Bonus:**
- Document which agent you prefer for different tasks
- Try a more complex prompt with each agent

---

## 🎯 Challenge 6: View Usage Analytics

**Goal:** Monitor your AI usage and costs.

### View Overall Usage

```bash
codemie analytics show
```

Shows:
- Total requests
- Success/failure rates
- Token usage
- Average response time

### Filter by Agent

```bash
codemie analytics show --agent claude
codemie analytics show --agent codex
codemie analytics show --agent gemini
```

### Filter by Date Range

```bash
# Filter from
codemie analytics show --from 2025-12-12
```

### View Detailed Statistics

```bash
# Verbose output with raw model names
codemie analytics show --verbose

# JSON format for external tools
codemie analytics show --format json

# Export to file
codemie analytics show --format json --output usage-report.json
```

**✅ Success Criteria:**
- [ ] Viewed overall usage statistics
- [ ] Filtered usage by specific agent
- [ ] Checked usage for a date range
- [ ] Exported analytics to JSON file
- [ ] Understand your usage patterns

**🏆 Bonus:**
- Compare usage between different agents
- Analyze usage trends over multiple weeks
- Create monthly usage reports

---

## 🎓 Kata Complete!

### What You've Accomplished

✅ Installed CodeMie Code CLI
✅ Configured Enterprise SSO authentication
✅ Created profile with Claude 4.5 Sonnet
✅ Installed 4 specialized coding agents
✅ Tested each agent with file operations
✅ Monitored usage with advanced analytics filters

### Your AI Toolkit is Ready

You can now:
- **Use multiple AI agents** for different coding tasks
- **Switch between models** via profiles
- **Track usage** with detailed filtering
- **Choose the right agent** for each task
- **Analyze patterns** across projects and time periods

---

## 📚 Next Steps

1. **Practice Daily**: Use different agents for various coding tasks
2. **Explore Profiles**: Create profiles for different projects or teams
3. **Monitor Costs**: Regularly check analytics to optimize usage
4. **Share Knowledge**: Help teammates set up their own CodeMie CLI
5. **Advanced Features**: Explore CI/CD integration and automation

Happy coding with CodeMie! 🚀
