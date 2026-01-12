## Overview

A **Workflow** in CodeMie is an automated process that chains together multiple steps (states) performed by AI assistants and built-in tools. This lets you solve complex, multi-stage tasks that a single assistant can't handle alone—for example, extracting requirements, analyzing them, and then creating tasks in a project management tool.

**Advantages:**
- **Automation:** Reduces manual, repetitive work by connecting steps (like fetching, transforming, and publishing information).
- **Specialization:** You can assign each part of a process to the best-suited assistant or tool.
- **Flexibility:** Easily adjust or swap individual steps without rebuilding the whole flow.
- **Transparency:** See the entire process—where data goes, how it's handled, and what each step does.

**Example Scenarios:**
- Compile release notes: fetch Jira issues, generate summary, format as HTML.
- Review code automatically: extract code, request AI review, post feedback to repo.
- Classify and process incoming support tickets with multiple decision points.

---

## Workflow creation

To get started, simply go to the **Workflows** page in CodeMie and click **Create Workflow**. Here, you’ll find options to launch the Visual Workflow Editor or to write your workflow YAML by hand.

![Workflow Page](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflow-codemie-basics/images/workflow_page.png)

---

## Visual Workflow Editor — Your New Superpower!

Writing YAML by hand is powerful, but sometimes you need a faster, friendlier way to design automation. That’s where the **Visual Workflow Editor** comes in! 

Use the drag-and-drop interface to instantly build and adjust complex automations—no coding required! Instead of wrestling with syntax, you can visually map out each state (assistant, tool, or decision point) and instantly see how data flows through your process.

![Workflow Editor](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflow-codemie-basics/images/workflow_editor.png)

---

### Why use the Visual Editor?
- **See the big picture:** Instantly understand how all your workflow states connect.
- **Edit with confidence:** Add, remove, or change nodes with simple clicks.
- **Fewer errors:** The editor guides you, preventing common mistakes in transitions and parameters.
- **Immediate feedback:** Preview results, spot issues, and debug more easily.

Check out this short video walkthrough of the Visual Workflow Editor in CodeMie to easily get started and see all the features in action:
[Watch Video](https://youtu.be/zacMZpM5MNU?si=dML07SgqFmL56TjQ)

---

## Types of Nodes You Can Use in Workflows (and Their Key Distinctions)

In CodeMie, the core elements of a workflow are called **states** (sometimes called "nodes" in the docs and YAML). Each state is a step and comes in several varieties:

**Node/State Types:**

![node types](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflow-codemie-basics/images/node_types.png)

---

a) **Assistant-Based State**
- Uses an AI Assistant to process or generate text, summaries, user stories, etc.
- Good for steps that need reasoning, creativity, or flexible language handling.
- Example: Summarizing requirements or content generation.

b) **Tool-Based State**
- Uses a built-in tool for a specific task (like reading from Confluence or publishing to Jira).
- Fast and precise, but requires strict input/output formats.
- Example: Grabbing data from Confluence or posting an issue to Jira.

c) **Custom Node/State**
- Executes bespoke logic/code for highly specialized processing.
- Use only if built-ins aren’t enough.

---

### Node Type Differences Table

| Type               | Best for                  | Flexibility | Speed  | Example use           |
|--------------------|--------------------------|-------------|--------|-----------------------|
| Assistant-based    | Text, analysis, language | High        | Medium | Generate summaries    |
| Tool-based         | Data transfer, API calls | Low         | High   | Post to Jira          |
| Custom             | Special logic/scripts    | Highest     | ?      | Data transformation   |

Example - *Assistant-based state for summarizing*:
```yaml
- id: summary
  assistant_id: ai_writer
  task: "Summarize the requirements."
  output_schema: |
    {"summary": "string"}
  next:
    state_id: end
```

---

## What are States? How to Connect Nodes Together

What is a State?

A **state** is one actionable step in your workflow. Each state:
- Receives input (from the user or the previous state)
- Executes its task (e.g., calls an assistant or a tool)
- Produces output for the next state

States are connected via **transitions**, which define execution order and logic.

### Connecting States—Transitions

**Transitions** determine the order and logic of execution:

a) **Linear Transitions**
- The simplest flow: State A → State B → State C
- Example: Extract → Summarize → Publish

b) **Loops**
- Repeat a state for each item in a list.
- Achieved with the `iter_key` attribute (loop over all pages/stories/etc.)
- Example: Generate user stories for every extracted requirement.

c) **Conditional Branching**
- Use `condition` blocks to direct flow based on state output.
- Example:  
  - If backend stories exist, create Jira issues.  
  - Else, prompt user review for frontend stories.

d) **Complex Decision Trees**
- Use `switch` blocks if your routing logic requires multiple outcomes.

### Transition Usage Example: 
*Loop over list of pages and branch based on story type*

```yaml
- id: extract_pages
  assistant_id: confluence_extractor
  output_schema: |
    {"all_pages": [{"page_title": "string", "summary": "string"}]}
  next:
    state_id: generate_story
    iter_key: all_pages
- id: generate_story
  assistant_id: story_generator
  task: "Generate user stories for this page."
  next:
    state_id: categorize_stories
- id: categorize_stories
  assistant_id: story_categorizer
  next:
    condition:
      expression: "be_found == True"
      then: be_jira_creation
      otherwise: fe_story_check
```

---

## Short, Practical Examples Using Real Datasets

**Goal:** Extract requirements, generate stories, categorize them into BE/FE, and push to Jira, using real integrations.

**Assistants block sample:**
```yaml
assistants:
  - id: confluence_extractor
    assistant_id: 928f6ee1-6e46-429a-a7f9-d3468e0cd1f9 # ID of existing Assistant
  - id: story_generator
    model: gpt-4.1
    system_prompt: |
      "Analyze business requirements and produce user story descriptions."
  - id: story_categorizer
    model: gpt-4.1
    system_prompt: |
      "Categorize user stories into FE/BE."
  - id: jira_publisher
    model: gpt-4.1
    system_prompt: |
      "Create Jira Story tickets."
    tools:
      - name: generic_jira_tool
        integration_alias: Jira1
```

---

**States block sample:** 

*State 1: Extract summaries, looping over all pages*
```yaml
- id: extract_pages
  assistant_id: confluence_extractor
  task: |
    Extract main requirements from each provided page.
  output_schema: |
    {"all_pages": [{"page_title": "string", "summary_requirements": "list"}]}
  next:
    state_id: generate_story
    iter_key: all_pages
```

*State 2: Generate stories*

```yaml
- id: generate_story
  assistant_id: story_generator
  task: "Generate user stories for this page."
  output_schema: |
    {"user_stories": [{"title": "string", "description": "string"}]}
  next:
    state_id: categorize_stories
```

---

## Configuring a Full Example and Explanation of Each Step

Below is a compact but realistic workflow that extracts, analyzes, and publishes requirements, with line-by-line breakdowns included.

Workflow execution logic:

![Full configuration](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflow-codemie-basics/images/flowchart_with_notes.png)


### Full YAML Example

Actual result on platform (scroll down to see yaml):

![Full configuration](https://raw.githubusercontent.com/codemie-ai/codemie-katas/refs/heads/main/katas/workflow-codemie-basics/images/full_workflow_example.png)

---

Full YAML Example:

```yaml
assistants:
  - id: confluence_extractor
    assistant_id: 928f6ee1-6e46-429a-a7f9-d3468e0cd1f9  # ID of existing Assistant
  - id: story_generator
    model: gpt-4.1
    system_prompt: |
      "Analyze requirements and generate user stories."
  - id: story_categorizer
    model: gpt-4.1
    system_prompt: |
      "Review stories and split into FE/BE."
  - id: jira_publisher
    model: gpt-4.1
    system_prompt: |
      "Publish user stories to Jira."
    tools:
      - name: generic_jira_tool
        integration_alias: Jira1

states:
  - id: extract_pages
    assistant_id: confluence_extractor
    task: |
      Generate a summary with the main requirements from each page.
    output_schema: |
      {"all_pages": [{"page_title": "string", "summary_requirements": "list"}]}
    next:
      state_id: generate_story
      iter_key: all_pages # loop over all pages

  - id: generate_story
    assistant_id: story_generator
    task: |
      Generate user stories for this page.
    output_schema: |
      {"user_stories": [{"title": "string", "description": "string"}]}
    next:
      state_id: categorize_stories

  - id: categorize_stories
    assistant_id: story_categorizer
    task: |
      Categorize stories. Output both fe_stories and be_stories.
    output_schema: |
      {
        "be_found": "True | False",
        "be_stories": [{"title": "string", "description": "string"}],
        "fe_stories": [{"title": "string", "description": "string"}]
      }
    next:
      condition:
        expression: "be_found == True"
        then: be_jira_creation
        otherwise: fe_story_check

  - id: be_jira_creation
    assistant_id: jira_publisher
    task: Create Jira tickets for all BE stories.
    output_schema: |
      {"jira_links": ["string"]}
    retry_policy:
      initial_interval_seconds: 5.0
      backoff_factor: 2.0
      max_interval_seconds: 50.0
      max_attempts: 5
    next:
      state_id: end

  - id: fe_story_check
    assistant_id: story_categorizer
    task: List out all FE stories.
    output_schema: |
      {"fe_stories": [{"title": "string", "description": "string"}]}
    next:
      state_id: fe_jira_creation

  - id: fe_jira_creation
    assistant_id: jira_publisher
    task: Create Jira tickets for all FE stories.
    interrupt_before: true # requires user approval before creating
    output_schema: |
      {"jira_links": ["string"]}
    retry_policy:
      initial_interval_seconds: 5.0
      backoff_factor: 2.0
      max_interval_seconds: 50.0
      max_attempts: 5
    next:
      state_id: end
```

### Step-by-Step Explanation

1. **Define Assistants** – Four total: one to extract, one to generate, one to categorize, and one to publish to Jira.
2. **Extract Pages (State 1)** – Loops over every Confluence page, summarizes requirements.
3. **Generate Story (State 2)** – Creates user stories for each summary.
4. **Categorize Stories (State 3)** – Splits stories into BE/FE, then uses condition:
   - If backend stories found → go to BE Jira creation.
   - Else → go to frontend story check.
5. **Create BE Jira issues (State 4)** – Publishes to Jira, with retry policy.
6. **FE Story Check (State 5)** – Lists out FE stories for checking.
7. **Create FE Jira issues (State 6)** – Publishes to Jira, with user review (`interrupt_before: true`).

---

## Tips, Insights & Motivation

- Use descriptive IDs for both assistants and states—this helps with maintenance!
- Always use `output_schema` to clearly define what each state produces for the next.
- Remember: you can combine built-in assistants with your own.
- Take advantage of the platform’s templates for common patterns.
- Use loops (`iter_key`) and conditions for more power and less manual work!

---

## Success Criteria Checklist

- [ ] Can explain workflows and their benefits
- [ ] Can distinguish between assistant, tool, and custom nodes
- [ ] Understands how to structure and connect states
- [ ] Recognizes basic linear, looping, and branching patterns in workflows
- [ ] Can read and adapt simple workflow YAML
- [ ] Can set up and run a workflow that automates a multi-step process (with real integrations)

---

**You’re now ready to build or modify CodeMie workflows with confidence, using both the theory and hands-on YAML examples provided!**