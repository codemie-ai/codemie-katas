# Advanced Workflows with CodeMie

Master advanced workflow patterns including multi-agent orchestration, tool integrations, iterations, conditional logic, human-in-the-loop approval, and complex state management.

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

![Challenge 1 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge1-wf.png)

**Execution Example**

![Challenge 1 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge1-exec.png)

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
   - Use JQL to filter open issues (e.g., `status = "Open" AND project = EPMCDME`)
   - Set the `integration_alias` to your configured Jira integration

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

![Challenge 2 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge2-wf.png)

**Execution Example**

![Challenge 2 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge2-exec.png)

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
      params: '{"jql": "status = \"Open\" AND project = EPMCDME", "fields": "key,summary,issuetype,status", "maxResults": 10}'
    integration_alias: personal test
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

1. **Configure MCP server connection** in CodeMie Marketplace:
   - Navigate to Marketplace → MCP Servers
   - Add a new MCP server configuration
   - Use `cli-mcp-server` as the command
   - Set the allowed directory (e.g., `/home/codemie`)
   - Configure remote connection URL if needed

2. **Create assistant** `file-reader`:
   - Assign model `gpt-4.1`
   - Add system prompt for file analysis
   - Configure `mcp_servers` section with your MCP server details
   - Use `mcp_connect_url` for remote MCP server connections

3. **Create state** `analyze-file`:
   - Assign it to the `file-reader` assistant
   - Provide a task that asks the assistant to read and analyze a specific directory (e.g., `/home/codemie`)
   - The assistant will use MCP tools automatically to access files

4. **Execute the workflow** and verify that the assistant can read and analyze real files

#### MCP Server Setup

![Challenge 3 MCP Setup](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge3-mcp-setup.png)

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 3 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge3-wf.png)

**Execution Example**

![Challenge 3 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge3-exec.png)

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

## 📝 Iteration and Reporting

**Iteration** enables "one-to-many" processing, making it easy to repeat the same step for multiple items (e.g., files, issues, records). This is essential for batch processing and creating comprehensive reports.

**Why use these?**
- Efficiently handle batch or list-based tasks
- Process collections of data systematically
- Generate consolidated reports from multiple data sources

**Use this when:**
Processing multiple related inputs (e.g., review each ticket, analyze each file) and generating summary reports.

---

## 🎯 Challenge 4: Iteration + Reporting for Jira Tasks

**🔎 Overview**

Automate the analysis of multiple Jira tickets by iterating through a list, generating a summary for each, and creating a final structured report. Learn how to process collections and aggregate results.

**Goal**

Build a workflow that demonstrates:
- Iteration over collections using `iter_key`
- Processing multiple items systematically
- Dynamic value resolution with `resolve_dynamic_values_in_prompt`
- Aggregating results into comprehensive reports
- Using `meta_iter_state_id` for iteration references

**Instructions**

1. **Create assistant** `jira_summarizer`:
   - Configure it with the `generic_jira_tool`
   - Add system prompt for summarizing tickets

2. **Create state** `fetch-my-tickets`:
   - Use the assistant to fetch last 10 tickets assigned to a specific user
   - Return a JSON array of tickets with fields: key, summary, issuetype, status, description
   - Define a clear `output_schema` for the tickets array
   - Set `next` with `iter_key: tickets` to enable iteration

3. **Create state** `summarize-ticket`:
   - Set `resolve_dynamic_values_in_prompt: true` to access iteration variables
   - Use template variables like `{{key}}`, `{{summary}}`, `{{description}}`
   - Generate a structured summary with: what_to_do, key_actions, notes
   - Link to the next state with `meta_iter_state_id` reference

4. **Create state** `generate-final-report`:
   - Aggregate all ticket summaries into a markdown report
   - Structure the report with sections: Overview, Ticket Details, Action Items
   - Format as readable markdown with proper headings and lists

5. **Execute the workflow** and verify iteration through all tickets with a final consolidated report

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 4 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge4-wf.png)

**Execution Example**

![Challenge 4 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge4-exec.png)

**Success Checklist**

- [ ] Multiple tasks are collected for processing
- [ ] Iteration is performed over the array of tasks
- [ ] Brief summary is generated for each task
- [ ] Structured report is built from all summaries
- [ ] Report is well-formatted with clear sections

#### Solution

```yaml
assistants:
  - id: jira_summarizer
    model: gpt-4.1-mini
    system_prompt: |
      You are a helpful BA assistant that summarizes Jira tickets.

      For each ticket, provide a brief, actionable summary of what needs to be done.
      Keep it concise (2-3 sentences maximum).

      Format:
      - What is the task about
      - Key action items
      - Any important notes
    tools:
      - name: generic_jira_tool
        integration_alias: personal test
  - id: assistant_1
    model: gpt-4.1-mini
    system_prompt: |
      You are a helpful BA assistant that summarizes Jira tickets.

      For each ticket, provide a brief, actionable summary of what needs to be done.
      Keep it concise (2-3 sentences maximum).

      Format:
      - What is the task about
      - Key action items
      - Any important notes
    mcp_servers: []
    tools:
      - name: generic_jira_tool
        integration_alias: personal test
    datasource_ids: []

states:
  - id: fetch-my-tickets
    assistant_id: assistant_1
    task: |
      Get last 10 tickets assigned to "sviatoslav_likhtarchyk@epam.com". Use project - EPMCDME
      Extract these fields: key, summary, issuetype, status, description.

      Return JSON in this format:
      {
        "tickets": [
          {
            "key": "PROJ-123",
            "summary": "Task title",
            "issuetype": "Story",
            "status": "Open",
            "description": "Task description"
          }
        ]
      }
    output_schema: |
      {
        "tickets": [
          {
            "key": "PROJ-123",
            "summary": "Task title",
            "issuetype": "Story",
            "status": "Open",
            "description": "Task description"
          }
        ]
      }
    next:
      state_id: summarize-ticket
      iter_key: tickets
    interrupt_before: false
    finish_iteration: false
    resolve_dynamic_values_in_prompt: false
    result_as_human_message: false
  - id: summarize-ticket
    assistant_id: jira_summarizer
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket: {{key}} - {{summary}}
      Type: {{issuetype}}
      Status: {{status}}
      Description: {{description}}

      Provide a brief, actionable summary of what needs to be done for this ticket.

      Format your response as:
      **What to do:** [Brief description]
      **Key actions:** [List 2-3 main steps]
      **Notes:** [Any important details]

      Return JSON:
      {
        "key": "{{key}}",
        "short_summary": "Brief one-line summary",
        "what_to_do": "Detailed explanation (2-3 sentences)",
        "key_actions": ["action1", "action2", "action3"],
        "notes": "Important notes or blockers"
      }
    output_schema: |
      {
        "key": "PROJ-123",
        "short_summary": "Implement OAuth2 authentication",
        "what_to_do": "Set up OAuth2 provider and implement JWT tokens",
        "key_actions": ["Configure OAuth2", "Generate JWT tokens", "Add middleware"],
        "notes": "Requires Redis for session storage"
      }
    next:
      state_id: generate-final-report
      meta_iter_state_id: iterator_1
  - id: generate-final-report
    assistant_id: jira_summarizer
    task: |
      Create a summary report of all tickets analyzed.

      For each ticket, include:
      - Ticket key and short summary
      - What needs to be done
      - Key action items
      - Important notes

      Format as a clear, readable markdown report with sections:

      ## 📝 My Tickets Summary

      ### Overview
      Total tickets: [count]

      ### Ticket Details

      #### [TICKET-KEY]: [Short Summary]
      - **What to do:** [Description]
      - **Key actions:**
        1. [Action 1]
        2. [Action 2]
        3. [Action 3]
      - **Notes:** [Important notes]

      ---

      Make it well-structured and easy to read.
    next:
      state_id: end
```



---

## 📝 Conditional Branching (Switch)

**Conditionals** (`switch` with cases) allow workflow logic to diverge based on output at runtime. This enables adaptive workflows that respond differently to different data conditions.

**Why use these?**
- Make workflows adaptive and context-sensitive
- Handle different scenarios with appropriate logic paths
- Provide tailored analysis based on data characteristics

**Use this when:**
When outcomes or processing paths should differ based on data attributes (e.g., ticket status, file type, priority level).

---

## 🎯 Challenge 5: Conditional Branching and Adaptive Jira Task Analysis

**🔎 Overview**

Implement conditional logic that classifies Jira tickets by status and provides different analyses for each category (not_started, in_progress, completed). Learn how to create adaptive workflows.

**Goal**

Build a workflow that demonstrates:
- Conditional branching using `switch` with `cases`
- Dynamic routing based on runtime data
- Multiple processing paths for different scenarios
- Adaptive analysis based on data attributes
- Using `meta_next_state_id` for switch references

**Instructions**

1. **Create assistant** `jira_processor`:
   - Configure with `generic_jira_tool`
   - Add system prompt for professional ticket analysis

2. **Create state** `fetch-ticket-details`:
   - Use `resolve_dynamic_values_in_prompt: true` to access `{{ticket_key}}`
   - Fetch full ticket details with all relevant fields
   - Return structured JSON with ticket information

3. **Create state** `categorize-status`:
   - Analyze the ticket status
   - Categorize into: "not_started", "in_progress", or "completed"
   - Return JSON with `status_category` field

4. **Create state** `route-by-status` with switch logic:
   - Define cases for each status category
   - Route to different handler states based on the category
   - Set default case for completed tickets

5. **Create handler states:**
   - `handle-not-started`: Provide task breakdown, key steps, effort estimate, prerequisites, risks
   - `handle-in-progress`: Provide progress assessment, remaining work, time estimate, blockers, recommendations
   - `handle-completed`: Provide completion summary and lessons learned

6. **Create state** `format-final-output`:
   - Format the analysis into a clear markdown report
   - Adapt the structure based on analysis type
   - Include all relevant sections for the specific status category

7. **Execute the workflow** with different ticket keys and verify different analysis paths

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 5 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge5-wf.png)

**Execution Example**

![Challenge 5 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge5-exec.png)

**Success Checklist**

- [ ] Task statuses are classified correctly
- [ ] Each scenario has a separate structured response
- [ ] Report contains relevant summaries (key steps, risks, etc.)
- [ ] Switch logic routes to the correct handler state
- [ ] Different analyses are provided based on status category

#### Solution

```yaml
assistants:
  - id: jira_processor
    model: gpt-4.1
    system_prompt: |
      You are a professional BA assistant helping with Jira ticket analysis.

      Provide structured, actionable information based on ticket status.
      Always be specific and realistic in your assessments.
    tools:
      - name: generic_jira_tool
        integration_alias: personal test

states:
  - id: fetch-ticket-details
    assistant_id: jira_processor
    resolve_dynamic_values_in_prompt: true
    task: |
      Get full details for Jira ticket: {{ticket_key}}

      Extract these fields:
      - key
      - summary
      - description
      - issuetype
      - status
      - priority
      - assignee
      - created
      - updated

      Return as JSON object with all these fields.
    output_schema: |
      {
        "key": "PROJ-123",
        "summary": "Implement user authentication",
        "description": "Add OAuth2 authentication flow",
        "issuetype": "Story",
        "status": "In Progress",
        "priority": "High",
        "assignee": "sviatoslav_likhtarchuk@epam.com",
        "created": "2024-01-15",
        "updated": "2024-01-20"
      }
    next:
      state_id: categorize-status
  - id: categorize-status
    assistant_id: jira_processor
    resolve_dynamic_values_in_prompt: true
    task: |
      Analyze ticket status: {{status}}

      Categorize it as one of:
      - "not_started" - if status is: Open, To Do, Backlog, New
      - "in_progress" - if status is: In Progress, In Development, In Review, In Testing
      - "completed" - if status is: Done, Closed, Resolved, Cancelled

      Return JSON:
      {
        "status_category": "not_started | in_progress | completed"
      }
    output_schema: |
      {
        "status_category": "in_progress"
      }
    next:
      switch:
        cases:
          - condition: status_category == 'not_started'
            state_id: handle-not-started
          - condition: status_category == 'in_progress'
            state_id: handle-in-progress
        default: handle-completed
      meta_next_state_id: switch_1
  - id: handle-not-started
    assistant_id: jira_processor
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} has not been started yet.

      Summary: {{summary}}
      Description: {{description}}
      Type: {{issuetype}}
      Priority: {{priority}}

      Provide:
      1. **Brief explanation** - What needs to be done (2-3 sentences)
      2. **Key steps** - List 3-5 main steps to complete this task
      3. **Estimated effort** - Rough estimate (Small/Medium/Large or hours)
      4. **Prerequisites** - Any blockers or dependencies
      5. **Risks** - Potential challenges or issues to watch out for

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "not_started",
        "explanation": "What needs to be done",
        "key_steps": ["step1", "step2", "step3"],
        "estimated_effort": "Small/Medium/Large or X hours",
        "prerequisites": ["prereq1", "prereq2"],
        "risks": ["risk1", "risk2"]
      }
    output_schema: |
      {
        "key": "PROJ-123",
        "analysis_type": "not_started",
        "explanation": "Implement OAuth2 authentication flow with JWT tokens for user login",
        "key_steps": [
          "Set up OAuth2 provider configuration",
          "Implement JWT token generation and validation",
          "Add authentication middleware to API routes"
        ],
        "estimated_effort": "Medium (16-24 hours)",
        "prerequisites": ["Redis server setup", "SSL certificates"],
        "risks": ["Token security vulnerabilities", "Session management complexity"]
      }
    next:
      state_id: format-final-output
  - id: handle-in-progress
    assistant_id: jira_processor
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} is currently IN PROGRESS.

      Summary: {{summary}}
      Description: {{description}}
      Type: {{issuetype}}
      Priority: {{priority}}
      Started: {{created}}
      Last updated: {{updated}}

      Provide:
      1. **Progress assessment** - What has likely been done
      2. **Remaining work** - What still needs to be completed
      3. **Time estimate** - Estimated hours to completion
      4. **Confidence level** - High/Medium/Low confidence in estimate
      5. **Blockers** - Any current or potential blockers
      6. **Recommendations** - Next steps or suggestions

      Be realistic based on ticket age and complexity.

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "in_progress",
        "progress_assessment": "What's been done",
        "remaining_work": "What's left to do",
        "estimated_hours": 8,
        "confidence": "high/medium/low",
        "blockers": ["blocker1", "blocker2"],
        "recommendations": ["rec1", "rec2"]
      }
    output_schema: |
      {
        "key": "PROJ-123",
        "analysis_type": "in_progress",
        "progress_assessment": "OAuth2 provider setup completed, JWT generation implemented",
        "remaining_work": "Token refresh logic, session management, security testing",
        "estimated_hours": 6,
        "confidence": "medium",
        "blockers": ["Waiting for security review", "Redis configuration pending"],
        "recommendations": [
          "Complete token refresh implementation first",
          "Schedule security review meeting",
          "Prepare test scenarios for session management"
        ]
      }
    next:
      state_id: format-final-output
  - id: handle-completed
    assistant_id: jira_processor
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} is COMPLETED.

      Summary: {{summary}}
      Status: {{status}}
      Type: {{issuetype}}

      Provide a brief summary:
      1. **Completion status** - What was accomplished
      2. **Lessons learned** - Key takeaways (if applicable)

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "completed",
        "completion_summary": "What was accomplished",
        "lessons_learned": ["lesson1", "lesson2"]
      }
    output_schema: |
      {
        "key": "PROJ-123",
        "analysis_type": "completed",
        "completion_summary": "Successfully implemented OAuth2 authentication with JWT tokens, all tests passed",
        "lessons_learned": [
          "Token refresh logic requires careful error handling",
          "Redis session storage improved performance significantly"
        ]
      }
    next:
      state_id: format-final-output
  - id: format-final-output
    assistant_id: jira_processor
    task: |
      Format the ticket analysis into a clear, readable report.

      Use this structure based on analysis type:

      ## 🎫 Ticket Analysis: [KEY]

      ### Summary
      [Ticket summary]

      ### Details
      - **Type:** [issuetype]
      - **Status:** [status]
      - **Priority:** [priority]
      - **Assignee:** [assignee]

      ### Analysis

      [Include relevant sections based on analysis_type]:

      **For not_started:**
      - What to do
      - Key steps
      - Estimated effort
      - Prerequisites
      - Risks

      **For in_progress:**
      - Progress assessment
      - Remaining work
      - Estimated hours to completion
      - Confidence level
      - Blockers
      - Recommendations

      **For completed:**
      - Completion summary
      - Lessons learned

      Format as markdown with clear sections and bullet points.
    next:
      state_id: end
```



---

## 📝 Human-in-the-Loop & Advanced Templating

**Human-in-the-loop** (`interrupt_before`) pauses the workflow, requiring human approval for critical checkpoints. **Jinja templating** enables dynamic content generation with conditional logic, loops, and variable interpolation directly in prompts.

**Why use these?**
- Extra safety, compliance, and quality for business-critical actions
- Support real collaborative review/verification
- Create flexible, template-driven workflows with rich conditional logic
- Generate dynamic content based on user inputs and workflow state

**Use this when:**
You need human validation before critical actions, or want to create sophisticated document generation workflows with complex conditional logic.

---

## 🎯 Challenge 6: Approval Workflow + Jinja Templating + Confluence Integration

**🔎 Overview**

Create a sophisticated document generation workflow that uses Jinja templating for flexible content creation, pauses for human review, and publishes to Confluence. Learn advanced templating and human-in-the-loop patterns with retry policies.

**Goal**

Build a workflow that demonstrates:
- Human-in-the-loop approval with `interrupt_before`
- Advanced Jinja templating (`{% if %}`, `{% elif %}`, loops)
- Dynamic content generation based on parameters
- Retry policies for resilient API calls
- Integration with external documentation systems (Confluence)

**Instructions**

1. **Create assistant** `confluence_writer`:
   - Configure with `generic_confluence_tool`
   - Add system prompt for technical documentation

2. **Create state** `prepare-draft`:
   - Set `resolve_dynamic_values_in_prompt: true`
   - Accept input parameters: `topic`, `page_type`, `audience`, `include_code`, `tone`
   - Use Jinja templating with `{% if %}`, `{% elif %}`, `{% else %}`, `{% endif %}`
   - Conditionally structure content based on `page_type` (meeting_notes, technical_doc, project_plan)
   - Adapt tone and detail level based on `audience` and `tone` parameters
   - Generate Confluence HTML format with proper macros
   - Return structured JSON with: title, content, space_key, labels, metadata

3. **Create state** `create-confluence-page`:
   - Set `interrupt_before: true` to pause for user review
   - Set `resolve_dynamic_values_in_prompt: true`
   - Use Jinja templating to create rich preview of the draft
   - Display page details, content preview, and summary
   - Ask user to continue or cancel
   - Configure `retry_policy` with exponential backoff:
     - `initial_interval_seconds: 2`
     - `backoff_factor: 2`
     - `max_interval_seconds: 30`
     - `max_attempts: 3`
   - On approval, create the page in Confluence
   - Return success status with page URL and ID

4. **Execute the workflow** with different page types and verify:
   - Content adapts based on input parameters
   - Preview is shown before publication
   - User can approve or cancel
   - Page is created in Confluence after approval

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 6 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge6-wf.png)

**Execution Example**

![Challenge 6 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge6-exec.png)

**Success Checklist**

- [ ] All inputs for documentation are collected via variables
- [ ] Draft page follows the template with conditional sections
- [ ] Jinja templating is used for dynamic content generation
- [ ] Review step is present with approval before saving
- [ ] After confirmation, page is created in Confluence
- [ ] Retry policy is configured for resilient API calls
- [ ] Different content structures are generated based on page_type

#### Solution

```yaml
assistants:
  - id: confluence_writer
    model: gpt-4.1
    system_prompt: |
      You are a technical documentation specialist who creates clear, well-structured Confluence pages.

      Your pages should include:
      - Clear title and introduction
      - Well-organized sections
      - Proper formatting
      - Actionable content

      Always follow the template structure provided and fill in the content appropriately.
    mcp_servers: []
    tools:
      - name: generic_confluence_tool
        integration_alias: personal test
    datasource_ids: []
  - id: assistant_1
    model: gpt-4.1
    system_prompt: |
      You are a technical documentation specialist who creates clear, well-structured Confluence pages.

      Your pages should include:
      - Clear title and introduction
      - Well-organized sections
      - Proper formatting
      - Actionable content

      Always follow the template structure provided and fill in the content appropriately.
    mcp_servers: []
    tools:
      - name: generic_confluence_tool
        integration_alias: personal test
    datasource_ids: []

states:
  - id: prepare-draft
    assistant_id: assistant_1
    resolve_dynamic_values_in_prompt: true
    task: |
      Prepare a Confluence page draft using the following parameters:

      **User Input:**
      - Topic: {{topic}}
      - Page Type: {{page_type}}
      - Target Audience: {{audience}}
      - Include Code Examples: {{include_code}}
      - Tone: {{tone}}

      {% if page_type == "meeting_notes" %}
      Create meeting notes with these sections:
      - Meeting Date and Attendees
      - Agenda Items
      - Discussion Summary
      - Action Items
      - Next Steps
      {% elif page_type == "technical_doc" %}
      Create technical documentation with:
      - Overview
      - Technical Requirements
      - Implementation Details
      {% if include_code == "yes" %}
      - Code Examples
      {% endif %}
      - Best Practices
      - Troubleshooting
      {% elif page_type == "project_plan" %}
      Create project plan with:
      - Project Overview
      - Goals and Objectives
      - Timeline and Milestones
      - Team Members and Roles
      - Risks and Mitigation
      {% else %}
      Create a general page with:
      - Introduction
      - Main Content
      - Summary
      {% endif %}

      **Tone Guidelines:**
      {% if tone == "formal" %}
      Use professional, formal language. Avoid casual expressions.
      {% elif tone == "casual" %}
      Use friendly, conversational language. Be approachable.
      {% else %}
      Use clear, neutral language. Balance professionalism with readability.
      {% endif %}

      **Audience Consideration:**
      {% if audience == "developers" %}
      Include technical details, code examples, and API references.
      {% elif audience == "managers" %}
      Focus on high-level overview, business impact, and metrics.
      {% elif audience == "general" %}
      Keep it accessible to all technical levels. Explain jargon.
      {% endif %}

      Return JSON with:
      {
        "title": "Descriptive page title based on topic and type",
        "content": "Full page content in Confluence storage format (HTML)",
        "space_key": "{{space_key}}",
        "parent_page_id": "{{parent_page_id}}",
        "labels": ["label1", "label2"],
        "metadata": {
          "page_type": "{{page_type}}",
          "audience": "{{audience}}",
          "created_by_workflow": true
        }
      }

      Use proper Confluence formatting:
      - Headings: <h1>, <h2>, <h3>
      - Paragraphs: <p>
      - Lists: <ul><li>, <ol><li>
      - Bold: <strong>, Italic: <em>
      - Code blocks: <ac:structured-macro ac:name="code"><ac:plain-text-body><![CDATA[code here]]></ac:plain-text-body></ac:structured-macro>
      - Info panels: <ac:structured-macro ac:name="info"><ac:rich-text-body><p>Info text</p></ac:rich-text-body></ac:structured-macro>
    output_schema: |
      {
        "title": "Q1 2025 Planning Meeting Notes",
        "content": "<h1>Meeting Overview</h1><p>Date: January 15, 2025</p>...",
        "space_key": "TEAM",
        "parent_page_id": "123456",
        "labels": ["meeting-notes", "q1-2025", "planning"],
        "metadata": {
          "page_type": "meeting_notes",
          "audience": "managers",
          "created_by_workflow": true
        }
      }
    next:
      state_id: create-confluence-page
    interrupt_before: false
    finish_iteration: false
    result_as_human_message: false
  - id: create-confluence-page
    assistant_id: confluence_writer
    interrupt_before: true
    resolve_dynamic_values_in_prompt: true
    task: |
      📄 **Confluence Page Draft Ready for Review**

      ---

      ### Page Details:
      - **Title**: {{title}}
      - **Space**: {{space_key}}
      - **Parent Page ID**: {{parent_page_id}}
      - **Page Type**: {{page_type}}
      - **Target Audience**: {{audience}}
      - **Tone**: {{tone}}

      {% if labels %}
      - **Labels**: {% for label in labels %}#{{label}}{% endfor %}
      {% endif %}

      ---

      ### Page Content Preview:

      ```html
      {{content}}
      ```

      ---

      ### Summary:
      {% if page_type == "meeting_notes" %}
      This page will document meeting notes with agenda, discussion points, and action items.
      {% elif page_type == "technical_doc" %}
      This page will provide technical documentation{% if include_code == "yes" %} with code examples{% endif %}.
      {% elif page_type == "project_plan" %}
      This page will outline the project plan with timeline, team roles, and risk assessment.
      {% else %}
      This page will cover the topic: {{topic}}
      {% endif %}

      **Target Audience**: {{audience}}
      **Writing Tone**: {{tone}}

      ---

      **Please review the draft above.**

      ✅ If you're satisfied, click **"Continue"** to create this page in Confluence.
      ❌ If you want to cancel, click **"Cancel"**.

      ---

      After your approval, I will:
      1. Create the page in space "{{space_key}}"
      2. Set parent page to "{{parent_page_id}}"
      3. Apply labels: {% for label in labels %}{{label}}{% if not loop.last %}, {% endif %}{% endfor %}
      4. Add metadata about page type and audience

      Return after creation:
      {
        "status": "success",
        "page_url": "URL of the created page",
        "page_id": "ID of the created page",
        "page_title": "{{title}}",
        "message": "Page created successfully with {{labels|length}} labels"
      }
    output_schema: |
      {
        "status": "success",
        "page_url": "https://yourcompany.atlassian.net/wiki/spaces/TEAM/pages/123456789",
        "page_id": "123456789",
        "page_title": "Q1 2025 Planning Meeting Notes",
        "message": "✅ Page created successfully with 3 labels"
      }
    retry_policy:
      initial_interval_seconds: 2
      backoff_factor: 2
      max_interval_seconds: 30
      max_attempts: 3
    next:
      state_id: end
    finish_iteration: false
    result_as_human_message: false
```



---

## 📝 Complex Multi-Pattern Workflows

Advanced workflows combine multiple patterns: assistants, tools, MCP, iteration, conditionals, templating, and human checkpoints. These represent real-world automation scenarios.

**Why use these?**
- Multi-step automation with safeguards
- Blend AI reasoning, external data, actions, and human validation
- Scale and maintain critical business operations with transparency
- Handle complex, branching business logic

**Use this when:**
Orchestrating comprehensive digital processes from input to output—at scale, securely, and with human oversight.

---

## 🎯 Challenge 7: Advanced Multi-Pattern Workflow - Intelligent Jira Ticket Analysis

**🔎 Overview**

Build a comprehensive Jira ticket analysis workflow that automatically categorizes and analyzes tickets based on their status, providing different insights for different work stages. This workflow demonstrates mastery of all advanced patterns in a real-world scenario.

**Goal**

Create an intelligent ticket analysis system that demonstrates:
- Fetching tickets from Jira using AI assistants with tool integration
- Iterating through ticket collections with context enrichment
- Conditional routing based on work stage classification
- Multi-path analysis with different strategies per status
- Comprehensive report generation with actionable insights

#### What This Challenge Tests

This is an integration challenge that combines:
- ✅ Multi-assistant orchestration (single specialized assistant used across states)
- ✅ Tool node integration (Jira API via generic_jira_tool)
- ✅ Iteration over collections (processing multiple tickets)
- ✅ Conditional branching (switch/cases based on work_stage)
- ✅ Dynamic value resolution (template variables in prompts)
- ✅ Complex state transitions (fetch → enrich → route → analyze → report)
- ✅ Report generation (comprehensive markdown summary)

**Instructions**

Build a workflow that analyzes Jira tickets with intelligent routing:

1. **Fetch Tickets** (Assistant with Tool Integration):
   - Create assistant `jira_assistant` with `generic_jira_tool`
   - Fetch last 10 tickets assigned to a specific user
   - Extract fields: key, summary, issuetype, status
   - Return structured JSON with tickets array
   - Set up iteration with `iter_key: tickets`

2. **Enrich Ticket Data** (Classification):
   - For each ticket, determine the work stage:
     - "not_started" - Open, To Do, Backlog
     - "in_progress" - In Progress, In Development, In Review
     - "other" - Completed, Done, Closed
   - Use `resolve_dynamic_values_in_prompt: true` to access ticket variables
   - Return enriched JSON with work_stage field

3. **Route by Work Stage** (Conditional Branching):
   - Create `route-by-work-stage` state with switch logic
   - Define cases:
     - `work_stage == 'not_started'` → analyze-opened-ticket
     - `work_stage == 'in_progress'` → estimate-in-progress-ticket
     - Default → skip-ticket
   - Use `meta_next_state_id` and `meta_iter_state_id` for proper routing

4. **Multi-Path Analysis** (Different Analysis Strategies):

   **Path 1 - Not Started Tickets:**
   - Provide task breakdown with what needs to be done
   - List 3-5 key steps to complete the task
   - Identify potential challenges or blockers

   **Path 2 - In Progress Tickets:**
   - Estimate time to completion (hours)
   - Provide confidence level (high/medium/low)
   - Give brief reasoning for the estimate

   **Path 3 - Other Tickets:**
   - Mark as skipped with appropriate message
   - Indicate ticket is not actionable

5. **Generate Final Report** (Aggregation & Reporting):
   - Create comprehensive markdown report with sections:
     - Overview with ticket breakdown
     - Not Started Tickets with task breakdowns
     - In Progress Tickets with time estimates
     - Total Estimated Work summary
     - Action Items & Recommendations
   - Use emojis and clear formatting for readability

**Workflow Flow**

```
fetch-tickets (fetch 10 tickets)
    ↓
enrich-ticket (classify work_stage) [iterate each ticket]
    ↓
route-by-work-stage (switch on work_stage)
    ↓
    ├→ analyze-opened-ticket (task breakdown)
    ├→ estimate-in-progress-ticket (time estimate)
    └→ skip-ticket (not actionable)
    ↓
generate-report (comprehensive summary)
```

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 7 Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge7-wf.png)

**Execution Example**

![Challenge 7 Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-codemie-advanced/images/challenge7-exec.png)

**Success Checklist**

- [ ] Fetches tickets from Jira using assistant with tool integration
- [ ] Demonstrates iteration over ticket collection with `iter_key`
- [ ] Enriches each ticket with work_stage classification
- [ ] Implements conditional branching (switch/cases) based on work_stage
- [ ] Routes to 3 different analysis paths (not_started, in_progress, skip)
- [ ] Uses `resolve_dynamic_values_in_prompt` for dynamic context access
- [ ] Uses `meta_iter_state_id` and `meta_next_state_id` for proper state management
- [ ] Provides different analysis for each work stage
- [ ] Generates comprehensive final report with structured sections
- [ ] Workflow handles real-world complexity with multiple state transitions

**Hints**

- Start by mapping out your workflow on paper before implementing
- Use `output_schema` consistently to maintain structured data flow
- Test each branch of your conditional logic
- Use descriptive state IDs and clear task prompts
- Consider error cases and edge conditions
- Document your workflow purpose and logic

#### Solution

This solution demonstrates a production-ready workflow that combines all patterns: iteration, conditional branching, tool integration, dynamic templating, and comprehensive reporting.

```yaml
assistants:
  - id: jira_assistant
    model: gpt-4.1
    system_prompt: |
      You are a professional BA assistant helping with Jira operations.

      When analyzing tickets, provide structured information:
      - Current status
      - Work stage (opened vs in progress)
      - Task complexity
      - Time estimates

      Always return results in valid JSON format for easy processing.
    tools:
      - name: generic_jira_tool
        integration_alias: personal test

states:
  - id: fetch-tickets
    assistant_id: jira_assistant
    task: |
      Get last 10 tickets assigned to "sviatoslav_likhtarchyk@epam.com".
      Extract these fields: key, summary, issuetype, status.

      Return JSON in this exact format:
      {
        "tickets": [
          {
            "key": "PROJ-123",
            "summary": "Task title",
            "issuetype": "Story",
            "status": "Open"
          }
        ]
      }
    output_schema: |
      {
        "type": "object",
        "properties": {
          "tickets": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "key": {"type": "string"},
                "summary": {"type": "string"},
                "issuetype": {"type": "string"},
                "status": {"type": "string"}
              },
              "required": ["key", "summary", "issuetype", "status"]
            }
          }
        },
        "required": ["tickets"]
      }
    next:
      state_id: enrich-ticket
      iter_key: tickets
  - id: enrich-ticket
    assistant_id: jira_assistant
    resolve_dynamic_values_in_prompt: true
    task: |
      Analyze ticket: {{key}} - {{summary}}
      Current status: {{status}}
      Issue type: {{issuetype}}

      Determine the work stage based on status:
      - If status is "Open", "To Do", "Backlog" → work_stage = "not_started"
      - If status is "In Progress", "In Development", "In Review" → work_stage = "in_progress"
      - Otherwise → work_stage = "other"

      Return JSON:
      {
        "key": "{{key}}",
        "summary": "{{summary}}",
        "issuetype": "{{issuetype}}",
        "status": "{{status}}",
        "work_stage": "not_started or in_progress or other"
      }
    output_schema: |
      {
        "type": "object",
        "properties": {
          "key": {"type": "string"},
          "summary": {"type": "string"},
          "issuetype": {"type": "string"},
          "status": {"type": "string"},
          "work_stage": {"type": "string", "enum": ["not_started", "in_progress", "other"]}
        },
        "required": ["key", "work_stage"]
      }
    next:
      state_id: route-by-work-stage
      iter_key: tickets
      meta_iter_state_id: iterator_3
  - id: route-by-work-stage
    assistant_id: jira_assistant
    resolve_dynamic_values_in_prompt: true
    task: |
      Route ticket {{key}} based on work_stage: {{work_stage}}
    next:
      switch:
        cases:
          - condition: work_stage == 'not_started'
            state_id: analyze-opened-ticket
            iter_key: tickets
          - condition: work_stage == 'in_progress'
            state_id: estimate-in-progress-ticket
            iter_key: tickets
        default: skip-ticket
      meta_next_state_id: switch_1
      meta_iter_state_id: iterator_3
  - id: analyze-opened-ticket
    assistant_id: jira_assistant
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} is OPENED but work hasn't started yet.

      Summary: {{summary}}
      Type: {{issuetype}}
      Status: {{status}}

      Please provide:
      1. Brief explanation of what needs to be done (2-3 sentences)
      2. Key steps to complete this task (list 3-5 steps)
      3. Potential challenges or blockers

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "task_breakdown",
        "what_to_do": "Brief description of what needs to be done",
        "key_steps": ["step1", "step2", "step3"],
        "challenges": ["challenge1", "challenge2"]
      }
    output_schema: |
      {
        "type": "object",
        "properties": {
          "key": {"type": "string"},
          "analysis_type": {"type": "string"},
          "what_to_do": {"type": "string"},
          "key_steps": {"type": "array", "items": {"type": "string"}},
          "challenges": {"type": "array", "items": {"type": "string"}}
        },
        "required": ["key", "analysis_type", "what_to_do"]
      }
    next:
      state_id: generate-report
  - id: estimate-in-progress-ticket
    assistant_id: jira_assistant
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} is IN PROGRESS.

      Summary: {{summary}}
      Type: {{issuetype}}
      Status: {{status}}

      Please provide:
      1. Estimated time to completion (in hours, be realistic)
      2. Confidence level (high/medium/low)
      3. Brief reasoning for the estimate

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "estimation",
        "estimated_hours": 8,
        "confidence": "medium",
        "reasoning": "Based on current progress and remaining work"
      }
    output_schema: |
      {
        "type": "object",
        "properties": {
          "key": {"type": "string"},
          "analysis_type": {"type": "string"},
          "estimated_hours": {"type": "number"},
          "confidence": {"type": "string", "enum": ["high", "medium", "low"]},
          "reasoning": {"type": "string"}
        },
        "required": ["key", "analysis_type", "estimated_hours", "confidence"]
      }
    next:
      state_id: generate-report
  - id: skip-ticket
    assistant_id: jira_assistant
    resolve_dynamic_values_in_prompt: true
    task: |
      Ticket {{key}} has status "{{status}}" - not actionable (completed or other).

      Return JSON:
      {
        "key": "{{key}}",
        "analysis_type": "skipped",
        "message": "Ticket status is not actionable"
      }
    output_schema: |
      {
        "type": "object",
        "properties": {
          "key": {"type": "string"},
          "analysis_type": {"type": "string"},
          "message": {"type": "string"}
        },
        "required": ["key", "analysis_type"]
      }
    next:
      state_id: generate-report
  - id: generate-report
    assistant_id: jira_assistant
    task: |
      Generate a comprehensive summary report of all analyzed tickets assigned to you.

      Review all ticket analyses from previous steps and create a detailed report.

      Structure the report as follows:

      ## 📊 Ticket Analysis Summary

      ### Overview
      - Total tickets analyzed
      - Breakdown: Not started / In progress / Other

      ### 🆕 Not Started Tickets
      For each not-started ticket:
      - **[Key]**: [Summary]
        - What to do: [Description]
        - Key steps: [List]
        - Challenges: [List]

      ### 🔄 In Progress Tickets
      For each in-progress ticket:
      - **[Key]**: [Summary]
        - Estimated hours: [Number]
        - Confidence: [Level]
        - Reasoning: [Explanation]

      ### 📈 Total Estimated Work
      - Total hours for in-progress tickets
      - Average confidence level

      ### 🎯 Action Items & Recommendations
      - Priority tickets needing immediate attention
      - Blockers or risks identified
      - Suggested next steps

      Format as clear, well-structured markdown with emojis for better readability.
    output_schema: |
      {
        "type": "object",
        "properties": {
          "report": {"type": "string"}
        },
        "required": ["report"]
      }
    next:
      state_id: end
```

---

## 🎓 Kata Complete!

### What You've Accomplished

✅ **Multi-Assistant Workflows** - Chain specialized AI agents for complex tasks
✅ **Tool Integration** - Connect workflows to external systems (Jira, Confluence)
✅ **MCP Integration** - Enable AI agents to access live file systems and data
✅ **Iteration Patterns** - Process collections and generate aggregated reports
✅ **Conditional Logic** - Build adaptive workflows with branching logic
✅ **Jinja Templating** - Create dynamic, context-aware content
✅ **Human-in-the-Loop** - Add approval checkpoints for critical operations
✅ **Complex Orchestration** - Combine all patterns into production-ready workflows

### Next Steps

- **Explore Error Handling**: Add error recovery and fallback logic to your workflows
- **Optimize Performance**: Use parallel execution and caching strategies
- **Add Monitoring**: Integrate observability and alerting
- **Build Custom Tools**: Create specialized tool nodes for your domain
- **Scale Up**: Handle larger datasets and more complex business logic

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [Jinja Templating Guide](https://jinja.palletsprojects.com/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)

---

## 💡 General Tips & Best Practices

- **Atomic States**: Design each state to perform one clear logical action
- **Context Store**: Use variables like `{{key}}` to transfer data between steps
- **Transitions**: Master `next`, `condition`, `switch`, `iter_key` for flow control
- **Human Review**: Place `interrupt_before` at critical safety/compliance points
- **External Integration**: Only use MCP/tools when you need external data or actions
- **Structured Output**: Always define `output_schema` for clarity and type safety
- **Descriptive IDs**: Use clear, meaningful state and assistant IDs
- **Error Handling**: Configure retry policies for resilient external API calls
- **Testing**: Test each branch and edge case before production deployment
- **Documentation**: Comment complex logic and document workflow purpose