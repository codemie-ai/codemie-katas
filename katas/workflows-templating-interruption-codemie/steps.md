# Workflow Templating & Human Approval

Master advanced Jinja templating and human-in-the-loop patterns in CodeMie Workflows. Learn to create dynamic, template-driven content with conditional logic and implement approval checkpoints for critical operations.

**Prerequisites:** Complete **Mastering Workflows Pt. 1-3** first to understand nodes, iteration, and conditional logic - all essential for advanced templating.

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

## 🎯 Challenge: Approval Workflow + Jinja Templating + Confluence Integration

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

![Challenge Workflow](https://codemie-ai.github.io/codemie-katas/katas/workflows-templating-interruption-codemie/images/challenge-wf.png)

**Execution Example**

![Challenge Execution](https://codemie-ai.github.io/codemie-katas/katas/workflows-templating-interruption-codemie/images/challenge-exec.png)

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
        integration_alias: your-confluence-integration
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
        integration_alias: your-confluence-integration
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

## 🎓 Kata Complete!

**What You've Accomplished**

✅ **Jinja Templating** - Create dynamic content with conditional logic and loops
✅ **Human-in-the-Loop** - Add approval checkpoints for critical operations
✅ **Retry Policies** - Build resilient workflows with exponential backoff
✅ **External Integration** - Publish content to Confluence automatically
✅ **Template-Driven Workflows** - Generate different content based on parameters

### Next Steps

Continue your workflow mastery journey:
- **Mastering Workflows Pt. 5: Boss Challenge** - Combine all patterns (nodes, iteration, conditionals, templating, human approval) into a production-ready intelligent Jira ticket analysis system

Ready for production:
- **Add Error Handling**: Implement comprehensive error recovery
- **Scale Up**: Handle larger datasets and more complex logic
- **Add Monitoring**: Integrate observability and alerting

### Additional Resources

- [CodeMie Workflows Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [Jinja Templating Guide](https://jinja.palletsprojects.com/)

---

## 💡 Tips & Best Practices

- **Jinja Syntax**: Use `{% %}` for logic, `{{ }}` for variables
- **Interrupt Points**: Place `interrupt_before: true` at critical decision points
- **Retry Policies**: Always configure retry logic for external API calls
- **Template Testing**: Test all conditional branches with different parameters
- **Clear Preview**: Show comprehensive preview before approval actions
