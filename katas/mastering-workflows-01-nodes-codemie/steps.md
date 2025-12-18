# Workflow Nodes: Building Blocks

Master the fundamental building blocks of CodeMie Workflows: Assistants, Tool Nodes, and MCP Integration. Learn to chain AI assistants, integrate external systems, and connect to live data sources.

---

## 📝 Multi-Assistant Workflows

In CodeMie Workflows, a node ("state") usually represents a single, well-defined AI task. Chaining multiple assistant states lets you break down complex processes: for example, one assistant extracts facts, and another generates a structured summary.

**Why use this pattern?**
- Clear, understandable steps
- Possibility to swap or tune assistants independently
- Accurate tracking of intermediate logic/output (via context store)

**Use this when:**
You want to split responsibilities, reuse specialized agents, or ensure each substep can be checked or reused.

---

## 🎯 Challenge 1: Build a Sequential Workflow with Two Assistants

**🔎 Overview**

Create a workflow where the first assistant extracts key points from text, and the second assistant writes a summary based on those points. Learn how to chain assistants and pass data between workflow states using the context store.

**Goal**

Build a two-step workflow that demonstrates:
- Chaining multiple assistants in sequence
- Passing data between states using the context store
- Using `output_schema` to structure responses
- Managing state transitions with `next`

**Instructions**

1. **Define two assistants:**
   - **analyst**: Extracts main points from text
   - **writer**: Generates a summary from the key points

2. **Create the first state** `extract-key-points`:
   - Assign it to the `analyst` assistant
   - Pass the input text via the `{{article}}` variable
   - Define an `output_schema` to structure the response (e.g., `{"key_points": "..."}`)
   - Use `store_in_context: true` to save the result for the next state

3. **Create the second state** `format-summary`:
   - Assign it to the `writer` assistant
   - Reference the previous output using `{{key_points}}`
   - Set `next` to transition to the end state

4. **Execute the workflow** and verify that the key points are correctly passed to the summary generation step

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 1 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge1-wf.png)

**Execution Example**

![Challenge 1 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge1-exec.png)

**Success Checklist**

- [ ] Workflow contains two different states with different assistants
- [ ] The output from the first assistant (key points) is transparently used in the next step
- [ ] Output is passed through context (`output_key` / `store_in_context`)
- [ ] The final summary is generated based on extracted key points

#### Solution

```yaml
assistants:
  - id: analyst
    model: gpt-4.1-mini
    system_prompt: |
      You are a content analyst. Extract the main points from the provided text.
  - id: writer
    model: gpt-4.1-mini
    system_prompt: |
      You are a professional writer. Turn the provided list of points into a well-written summary.

states:
  - id: extract-key-points
    assistant_id: analyst
    task: |
      Read the text and extract 3-5 key points:
      {{article}}
    output_schema: |
      {"key_points": "key points"}
    next:
      state_id: format-summary
      output_key: key_points
      store_in_context: true
  - id: format-summary
    assistant_id: writer
    task: |
      Create a final summary based on these key points:
      {{key_points}}
    next:
      state_id: end
```

---

## 📝 Tool Nodes

Tool nodes in CodeMie call external APIs or deterministic utilities (e.g., fetch issues from Jira or get GitHub data).

**Why use tool nodes?**
- For fast, reliable, automation-friendly access to systems and data
- To separate "data gathering" from "reasoning/decision-making" (handled by assistants)
- For secure use of API credentials (integration_alias)

**Use this when:**
You need real data from external services as part of your workflow.

---

## 🎯 Challenge 2: Integrate External Tool Node (Jira)

**🔎 Overview**

Build a workflow that uses a tool node to fetch Jira issues and passes them to an AI assistant for analysis. Learn how to integrate external systems into your workflows.

**Goal**

Create a workflow that demonstrates:
- Integration of external tool nodes (Jira API)
- Fetching real data from external systems
- Passing tool outputs to AI assistants for analysis
- Configuring secure API access with `integration_alias`

**Instructions**

1. **Add a tool node** `get-jira-issues`:
   - Use the `generic_jira_tool`
   - Configure it to make a GET request to `/rest/api/2/search`
   - Use JQL to filter open issues (e.g., `status = "Open" AND project = YOUR_PROJECT`)
   - Set the `integration_alias` to your configured Jira integration (Integration Tab)

2. **Create state** `fetch-issues`:
   - Assign it to the `get-jira-issues` tool
   - Store the response in the context with `output_key: issues`

3. **Create state** `analyze-issues`:
   - Assign it to an `issue-analyzer` assistant
   - Pass the issues data via `{{issues}}`
   - Let the assistant analyze and summarize the issues

4. **Execute the workflow** and verify that real Jira data is fetched and analyzed

---

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 2 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge2-wf.png)

**Execution Example**

![Challenge 2 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge2-exec.png)

**Success Checklist**

- [ ] Tool node is added for Jira API requests
- [ ] Response is fetched and passed to the next state
- [ ] Jira issues are analyzed in the second state
- [ ] Workflow successfully connects to external Jira system

### Solution

```yaml
assistants:
  - id: issue-analyzer
    model: gpt-4.1
    system_prompt: |
      You analyze current Jira issues.

tools:
  - id: get-jira-issues
    tool: generic_jira_tool
    tool_args:
      method: GET
      relative_url: /rest/api/2/search
      params: '{"jql": "status = \"Open\" AND project = YOUR_PROJECT", "fields": "key,summary,issuetype,status", "maxResults": 10}'
    integration_alias: your-jira-integration
    trace: false
    tool_result_json_pointer: ''
    resolve_dynamic_values_in_response: false

states:
  - id: fetch-issues
    tool_id: get-jira-issues
    next:
      state_id: analyze-issues
      output_key: issues
    task: ''
    output_schema: ''
    interrupt_before: false
    finish_iteration: false
    resolve_dynamic_values_in_prompt: false
    result_as_human_message: false
  - id: analyze-issues
    assistant_id: issue-analyzer
    task: |
      Analyze these Jira issues:
      {{issues}}
    next:
      state_id: end
```

---

## 📝 MCP (Model Context Protocol) Integration

MCP servers extend workflow capabilities by connecting LLMs to advanced, live data or services (like file systems, databases, APIs).

**Why use MCP?**
- Enable agents to act as "smart operators" in real environments
- Access up-to-date, real-world content
- Great for automation or semi-automated agentic tasks

**Use this when:**
You want LLM agents to read/write files, inspect codebases, or access protected business data.

---

## 🎯 Challenge 3: Use MCP for File System Access

**🔎 Overview**

Create a workflow where an AI assistant uses MCP (Model Context Protocol) to access and analyze files in a remote file system. Learn how to connect LLMs to live data sources.

**Goal**

Build a workflow that demonstrates:
- MCP (Model Context Protocol) integration for file system access
- Connecting AI assistants to live data sources
- Remote server configuration with `mcp_connect_url`
- Using MCP tools automatically within assistants

**Instructions**

1. **Create assistant** `file-reader`:
   - Assign model `gpt-4.1`
   - Add system prompt for file analysis
   - Configure `mcp_servers` section with your MCP server details
   - Use `cli-mcp-server` as the command
   - Set the allowed directory (e.g., `/home/codemie`)
   - Configure remote connection URL if needed
   - Use `mcp_connect_url` for remote MCP server connections

2. **Create state** `analyze-file`:
   - Assign it to the `file-reader` assistant
   - Provide a task that asks the assistant to read and analyze a specific directory (e.g., `/home/codemie`)
   - The assistant will use MCP tools automatically to access files

3. **Execute the workflow** and verify that the assistant can read and analyze real files

#### MCP Server Setup

![Challenge 3 MCP Setup](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge3-mcp-setup.png)

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 3 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge3-wf.png)

**Execution Example**

![Challenge 3 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-01-nodes-codemie/images/challenge3-exec.png)

**Success Checklist**

- [ ] MCP server is connected and configured
- [ ] Assistant works with real files via MCP
- [ ] Specific file path is passed in the prompt
- [ ] File system access is demonstrated successfully

#### Solution

```yaml
assistants:
  - id: file-reader
    model: gpt-4.1
    system_prompt: |
      You analyze code files.
    mcp_servers:
      - name: mcp-server-filesystem
        config:
          command: uvx
          args:
            - cli-mcp-server
          env:
            ALLOWED_DIR: /home/codemie
        settings: null
        enabled: true
        description: mcp server which connects to remote server
        mcp_connect_url: http://codemie-mcp-connect-service-1.codemie-mcp-connect-service-headless.codemie:3000
    tools: []
    datasource_ids: []

states:
  - id: analyze-file
    assistant_id: file-reader
    task: |
      Read and analyze the current dir: /home/codemie
      Use the available MCP tools to access file content.
    next:
      state_id: end
    output_schema: ''
    interrupt_before: false
    finish_iteration: false
    resolve_dynamic_values_in_prompt: false
    result_as_human_message: false
```

---

## 🎓 Kata Complete!

**What You've Accomplished**

✅ **Multi-Assistant Workflows** - Chain specialized AI agents for complex tasks
✅ **Tool Integration** - Connect workflows to external systems (Jira)
✅ **MCP Integration** - Enable AI agents to access live file systems and data
✅ **State Transitions** - Master workflow control flow and context store

### Next Steps

Continue your workflow mastery journey:
- **Mastering Workflows Pt. 2: Iteration & Reporting** - Process collections of data systematically
- **Mastering Workflows Pt. 3: Conditional Logic** - Build adaptive workflows with branching logic
- **Mastering Workflows Pt. 4: Templating & Human Approval** - Implement approval checkpoints for critical operations
- **Mastering Workflows Pt. 5: Boss Challenge** - Combine all patterns into production-ready workflows

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)

---

## 💡 General Tips & Best Practices

- **Atomic States**: Design each state to perform one clear logical action
- **Context Store**: Use variables like `{{key}}` to transfer data between steps
- **Structured Output**: Always define `output_schema` for clarity and type safety
- **Descriptive IDs**: Use clear, meaningful state and assistant IDs
- **External Integration**: Only use MCP/tools when you need external data or actions
