# Workflow Iteration

Master iteration patterns in CodeMie Workflows to process collections and generate reports. Learn to iterate through lists, process each item systematically, and aggregate results into comprehensive summaries.

**Prerequisites:** Complete **Mastering Workflows Pt. 1: Nodes & Building Blocks** first to understand assistants, tool nodes, and state transitions.

---

## 📝 Iteration

**Iteration** enables "one-to-many" processing, making it easy to repeat the same step for multiple items (e.g., files, issues, records). This is essential for batch processing and creating comprehensive reports.

**Why use these?**
- Efficiently handle batch or list-based tasks
- Process collections of data systematically
- Generate consolidated reports from multiple data sources

**Use this when:**
Processing multiple related inputs (e.g., review each ticket, analyze each file) and generating summary reports.

---

## 🎯 Challenge: Iteration for Jira Tasks

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

![Challenge Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-02-iteration-codemie/images/challenge-wf.png)

**Execution Example**

![Challenge Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/mastering-workflows-02-iteration-codemie/images/challenge-exec.png)

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
        integration_alias: your-jira-integration
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
        integration_alias: your-jira-integration
    datasource_ids: []

states:
  - id: fetch-my-tickets
    assistant_id: assistant_1
    task: |
      Get last 10 tickets assigned to "your.email@example.com". Use project - YOUR_PROJECT
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

## 🎓 Kata Complete!

**What You've Accomplished**

✅ **Iteration Patterns** - Process collections of data systematically
✅ **Dynamic Value Resolution** - Access iteration variables in prompts
✅ **Report Generation** - Aggregate results into structured summaries
✅ **Meta State References** - Use `meta_iter_state_id` for proper iteration control

### Next Steps

Continue your workflow mastery journey:
- **Mastering Workflows Pt. 3: Conditional Logic** - Add branching logic to handle different scenarios
- **Mastering Workflows Pt. 4: Templating & Human Approval** - Use Jinja for dynamic content and implement approval checkpoints
- **Mastering Workflows Pt. 5: Boss Challenge** - Combine all patterns into production-ready workflows

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [Jinja Templating Guide](https://jinja.palletsprojects.com/)

---

## 💡 Tips & Best Practices

- **Use `iter_key`**: Specify which array field to iterate over
- **Enable Dynamic Resolution**: Set `resolve_dynamic_values_in_prompt: true` to access iteration variables
- **Structure Output**: Define clear `output_schema` for each state
- **Aggregate Results**: Create final reporting states to summarize all processed items
- **Test with Small Sets**: Start with 2-3 items before processing large collections
