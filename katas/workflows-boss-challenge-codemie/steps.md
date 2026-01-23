# Workflow Boss Challenge: Complex Multi-Pattern

Master all workflow patterns in one comprehensive challenge! Build an intelligent Jira ticket analysis system that combines multi-assistant orchestration, tool integration, iteration, conditional branching, dynamic templating, and report generation.

**Prerequisites:** Complete **Mastering Workflows Pt. 1-4** first. This challenge combines ALL patterns you've learned: nodes, iteration, conditionals, and templating.

---

## 📝 Complex Multi-Pattern Workflows

Advanced workflows combine multiple patterns: assistants, tools, iteration, conditionals, and reporting. These represent real-world automation scenarios.

**Why use these?**
- Multi-step automation with safeguards
- Blend AI reasoning, external data, and actions
- Scale and maintain critical business operations with transparency
- Handle complex, branching business logic

**Use this when:**
Orchestrating comprehensive digital processes from input to output—at scale, securely, and with reliability.

---

## 🎯 Boss Challenge: Intelligent Jira Ticket Analysis

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

![Challenge Workflow](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-boss-challenge-codemie/images/challenge-wf.png)

**Execution Example**

![Challenge Execution](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflows-boss-challenge-codemie/images/challenge-exec.png)

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
        integration_alias: your-jira-integration

states:
  - id: fetch-tickets
    assistant_id: jira_assistant
    task: |
      Get last 10 tickets assigned to "your.email@example.com".
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

**What You've Accomplished**

✅ **Multi-Pattern Orchestration** - Combined all workflow patterns into one system
✅ **Tool Integration** - Connected to external Jira API
✅ **Iteration** - Processed collections systematically
✅ **Conditional Logic** - Built adaptive routing with switch/case
✅ **Dynamic Templating** - Used template variables throughout
✅ **Report Generation** - Created comprehensive actionable summaries
✅ **Production Ready** - Built enterprise-grade automation

### Next Steps

Congratulations! You've mastered all workflow patterns. Now take your skills to production:

- **Error Handling**: Add error recovery and fallback logic to your workflows
- **Performance Optimization**: Use parallel execution and caching strategies
- **Observability**: Integrate monitoring, logging, and alerting
- **Custom Tools**: Build specialized tool nodes for your domain
- **Scale Up**: Handle larger datasets and more complex business logic
- **Share Your Work**: Create your own workflow katas and contribute to the community!

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [Jinja Templating Guide](https://jinja.palletsprojects.com/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)

---

## 💡 Tips & Best Practices

- **Atomic States**: Design each state to perform one clear logical action
- **Context Store**: Use variables like `{{key}}` to transfer data between steps
- **Transitions**: Master `next`, `switch`, `iter_key` for flow control
- **Structured Output**: Always define `output_schema` for clarity
- **Descriptive IDs**: Use clear, meaningful state and assistant IDs
- **Testing**: Test each branch and edge case before production
