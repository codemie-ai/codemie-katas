# Workflow Conditional Logic

Master conditional branching in CodeMie Workflows with switch/case and if-else patterns. Learn to build adaptive workflows that make decisions based on data and route execution through different paths for different scenarios.

**Prerequisites:** Complete **Mastering Workflows Pt. 1: Nodes & Building Blocks** and **Pt. 2: Iteration & Reporting** first to understand state management and data flow.

---

## 📝 Conditional Branching

**Conditionals** allow workflow logic to diverge based on output at runtime. This enables adaptive workflows that respond differently to different data conditions.

**Why use these?**
- Make workflows adaptive and context-sensitive
- Handle different scenarios with appropriate logic paths
- Provide tailored analysis based on data characteristics

**Use this when:**
When outcomes or processing paths should differ based on data attributes (e.g., ticket status, file type, priority level).

---

## 🎯 Challenge 1: Switch/Case - Adaptive Jira Task Analysis

**🔎 Overview**

Implement conditional logic that classifies Jira tickets by status and provides different analyses for each category (not_started, in_progress, completed). Learn how to create adaptive workflows with switch/case logic.

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

![Challenge 1 Workflow](https://codemie-ai.github.io/codemie-katas/katas/workflows-conditionals-codemie/images/challenge1-wf.png)

**Execution Example**

![Challenge 1 Execution](https://codemie-ai.github.io/codemie-katas/katas/workflows-conditionals-codemie/images/challenge1-exec.png)

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
        integration_alias: your-jira-integration

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
        "assignee": "user@example.com",
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

## 🎯 Challenge 2: If-Else - Priority-Based Task Routing

**🔎 Overview**

Build a simpler conditional workflow using if-else logic to route tasks based on priority level. Learn when to use if-else versus switch/case patterns.

**Goal**

Build a workflow that demonstrates:
- Simple if-else conditional branching
- Priority-based routing (high priority vs normal priority)
- Two-path decision logic
- Clear boolean conditions

**Instructions**

1. **Create assistant** `task_router`:
   - Configure with `generic_jira_tool`
   - Add system prompt for task prioritization

2. **Create state** `fetch-task`:
   - Fetch ticket details including priority field
   - Return JSON with task information

3. **Create state** `check-priority`:
   - Analyze the priority field
   - Determine if it's "high_priority" (High, Highest, Critical) or "normal" (Medium, Low, Lowest)
   - Return JSON with `priority_level` field

4. **Create state** `route-by-priority` with if-else logic:
   - Use condition: `priority_level == 'high_priority'`
   - Route to `handle-urgent-task` if true
   - Route to `handle-normal-task` if false (no explicit else needed)

5. **Create handler states:**
   - `handle-urgent-task`: Flag as urgent, provide immediate action plan
   - `handle-normal-task`: Add to regular queue, provide standard analysis

6. **Execute the workflow** with different priority tickets and verify routing

### 🎯 Challenge Additional context

**Workflow Diagram**

![Challenge 2 Workflow](https://codemie-ai.github.io/codemie-katas/katas/workflows-conditionals-codemie/images/challenge2-wf.png)

**Execution Example**

![Challenge 2 Execution](https://codemie-ai.github.io/codemie-katas/katas/workflows-conditionals-codemie/images/challenge2-exec.png)

**Success Checklist**

- [ ] Priority is correctly identified (high vs normal)
- [ ] If condition routes high-priority tasks to urgent handler
- [ ] Normal-priority tasks go to standard handler
- [ ] Each handler provides appropriate response
- [ ] Workflow demonstrates simple boolean branching

#### Solution

```yaml
assistants:
  - id: task_router
    model: gpt-4.1-mini
    system_prompt: |
      You are a task management assistant that routes tasks based on priority.

      For high-priority tasks: flag as urgent and provide immediate action plan
      For normal tasks: add to regular queue and provide standard analysis
    tools:
      - name: generic_jira_tool
        integration_alias: your-jira-integration

states:
  - id: fetch-task
    assistant_id: task_router
    resolve_dynamic_values_in_prompt: true
    task: |
      Get Jira ticket: {{ticket_key}}

      Extract: key, summary, priority, status, assignee

      Return JSON:
      {
        "key": "PROJ-123",
        "summary": "Task title",
        "priority": "High",
        "status": "Open",
        "assignee": "user@example.com"
      }
    output_schema: |
      {
        "key": "string",
        "summary": "string",
        "priority": "string",
        "status": "string",
        "assignee": "string"
      }
    next:
      state_id: check-priority

  - id: check-priority
    assistant_id: task_router
    resolve_dynamic_values_in_prompt: true
    task: |
      Check priority level: {{priority}}

      If priority is "High", "Highest", or "Critical" → priority_level = "high_priority"
      Otherwise → priority_level = "normal"

      Return JSON:
      {
        "priority_level": "high_priority or normal"
      }
    output_schema: |
      {
        "priority_level": "string"
      }
    next:
      state_id: route-by-priority

  - id: route-by-priority
    assistant_id: task_router
    task: |
      Route based on priority_level
    next:
      condition: priority_level == 'high_priority'
      then: handle-urgent-task
      else: handle-normal-task

  - id: handle-urgent-task
    assistant_id: task_router
    resolve_dynamic_values_in_prompt: true
    task: |
      🚨 URGENT TASK: {{key}}

      Summary: {{summary}}
      Priority: {{priority}}
      Status: {{status}}
      Assignee: {{assignee}}

      This is a HIGH PRIORITY task requiring immediate attention.

      Provide:
      1. Immediate action required
      2. Estimated time to complete (rush mode)
      3. Resources needed
      4. Escalation contacts

      Return JSON:
      {
        "urgency": "high",
        "immediate_action": "What to do right now",
        "rush_estimate": "X hours",
        "resources_needed": ["resource1", "resource2"],
        "escalation": ["contact1", "contact2"]
      }
    output_schema: |
      {
        "urgency": "high",
        "immediate_action": "string",
        "rush_estimate": "string",
        "resources_needed": ["string"],
        "escalation": ["string"]
      }
    next:
      state_id: end

  - id: handle-normal-task
    assistant_id: task_router
    resolve_dynamic_values_in_prompt: true
    task: |
      📋 Regular Task: {{key}}

      Summary: {{summary}}
      Priority: {{priority}}
      Status: {{status}}
      Assignee: {{assignee}}

      This is a NORMAL priority task for regular queue.

      Provide:
      1. Brief description of work
      2. Estimated time to complete (normal pace)
      3. Dependencies
      4. Suggested timeline

      Return JSON:
      {
        "urgency": "normal",
        "description": "What needs to be done",
        "estimate": "X hours/days",
        "dependencies": ["dep1", "dep2"],
        "timeline": "Suggested schedule"
      }
    output_schema: |
      {
        "urgency": "normal",
        "description": "string",
        "estimate": "string",
        "dependencies": ["string"],
        "timeline": "string"
      }
    next:
      state_id: end
```

---

## 🎓 Kata Complete!

**What You've Accomplished**

✅ **Switch/Case Logic** - Build multi-path workflows with complex branching
✅ **If-Else Logic** - Implement simple boolean conditionals
✅ **Adaptive Routing** - Make data-driven decisions in workflows
✅ **Multiple Handlers** - Create different processing paths for different scenarios

### Next Steps

Continue your workflow mastery journey:
- **Mastering Workflows Pt. 4: Templating & Human Approval** - Use Jinja for dynamic content and implement approval checkpoints
- **Mastering Workflows Pt. 5: Boss Challenge** - Combine all patterns (nodes, iteration, conditionals, templating) for production use

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [Jinja Templating Guide](https://jinja.palletsprojects.com/)

---

## 💡 Tips & Best Practices

- **Switch vs If-Else**: Use switch/case for 3+ paths, if-else for binary decisions
- **Clear Conditions**: Write explicit, testable conditions
- **Default Cases**: Always provide a default path in switch statements
- **Test All Paths**: Execute workflow with data that triggers each branch
