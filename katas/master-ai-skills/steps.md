# Master AI Skills: Build Modular, Reusable AI Knowledge

Welcome to the world of **Skills** - the game-changing feature that revolutionizes how you build AI assistants!

## What Skills are

**Skills** are reusable, modular instruction sets that:
- ✨ **Load on-demand** - Only activate when relevant to the user's request
- 🔄 **Reusable** - Create once, use across multiple assistants
- 🚀 **Shareable** - Distribute via Marketplace or within teams
- 🎯 **Focused** - Each skill has one clear purpose
- 📦 **Lightweight** - Keep your assistants fast and efficient

Think of Skills as specialized tools in a toolbox - you don't carry every tool everywhere, you grab what you need when you need it!

Let's master this powerful feature together.

---

## 🎯 Challenge 1: Discover the Skills Interface

**Goal:** Locate Skills in the CodeMie platform and understand their structure

### Instructions

Let's explore where Skills live and what they can do!

1. **Find the Skills menu** in the left sidebar
   - Click to open the Skills page

2. **Explore the Two Tabs:**
   
   **Project Skills Tab:**
   - This is your personal/project skill library
   
   **Marketplace Tab:**
   - Browse publicly shared skills from the community
   ![Skill1](https://codemie-ai.github.io/codemie-katas/katas/master-ai-skills/images/skills-interface.png)
3. **Understand Skill Configuration:**
   
   Every skill has three key elements:
   
   - **Name**: Descriptive identifier (e.g., "Jira Ticket Structure")
   - **Description**: Helps the AI recognize WHEN to use this skill
   - **Instructions**: The actual prompt/guidelines the AI follows

**💡 Pro Tip:** The description and Instructions are crucial! It tells the AI assistant when this skill is relevant. Make it clear and specific.

**✅ Success Criteria:**
- [ ] Located the Skills menu in the sidebar
- [ ] Explored both Project Skills and Marketplace tabs
- [ ] Understand skill configuration (name, description, instructions)
- [ ] Ready to create your first skill

---

## 🎯 Challenge 2: Create Your First Skill

**Goal:** Create a skill by importing from file

### Instructions

When you have existing documentation, prompts, or guidelines, the fastest way to create a skill is by importing it from a file.
Importing from file is a convenient method, but you have possibility to fill in all fields manually on UI.

#### Scenario: Assistant with Jira Ticket Structure

Let's create a skill that helps your assistant create perfectly structured Jira tickets following team standards.

### Step 1: Download the Example Skill File

1. **Navigate to Skills Page:**
   - Go to Skills menu → Project Skills tab
   - Click the **"Create Skill"** button
   - Before importing your own skill file, download and review the example file available on the Create New Skill page in the top right corner. 
![Skill2](https://codemie-ai.github.io/codemie-katas/katas/master-ai-skills/images/create-skill-example.png)
**💡 Pro Tip 1:** This Claude Code-compatible format ensures your skills are correctly recognized by the AI. You can also import skills from public GitHub repositories.

**💡 Pro Tip 2:** Browse the Marketplace for inspiration! You can export any skill, tweak the instructions to match your needs, and import it as your own. Or if it's perfect already, use Marketplace skill directly without changes.

### Step 2: Prepare Your Jira Ticket Structure Skill File
  
 📋 Instructions Example
 
Name: jira-ticket-structure-skil

Description:
This skill guides the user in creating high-quality Jira tickets by providing clear structures, section requirements, and formatting guidelines for different ticket types.

Instructions:
```
Ticket Structure by Type:
- For **Story**, **Task**, **Bug**, and **Sub-Bug**, include the following sections:
  - Summary
  - Description:
    - General purpose and value for the user
    - Preconditions of use of the described functionality
    - Scenarios of use of this functionality
    - Affected areas by this functionality
    - Acceptance criteria based on the provided text

- For **Bug** and **Sub-Bug**, include the following additional details:
  - Steps To Reproduce
  - Expected result

  Complete list of sections for Bug/Sub-Bug:
    - Summary
    - Description:
      - General purpose and value for the user
      - Preconditions of use of the described functionality
      - Steps To Reproduce
      - Expected result
      - Affected areas by this functionality
      - Acceptance criteria based on the provided text

- For **Epic**, specify only:
  - General purpose
```


### Step 3: Import and Create the Skill

1. **Import the File:**
   - On the Create New Skill page, click **"Import from file"** button and select your file
   Watch as the description and instructions fields auto-populate!
  ![Skills3](https://codemie-ai.github.io/codemie-katas/katas/master-ai-skills/images/import-from-file.png)

2. **Create the Skill:**

   **📝 Note:** Double-check if relevant project selected before creating the skill

   - Click **"Create Skill"** button
   - Confirm the skill appears in your Project Skills list

### Step 4: Attach Skill to Your Assistant

 **Update your Assistant:**
   - Go to Assistants page
   - Start editing an existing assistant or create a new one if needed
   - Find the **"Skills"** section and select created Skill from the dropdown menu
   ![Skills4](https://codemie-ai.github.io/codemie-katas/katas/master-ai-skills/images/attach-skill-assistant.png)
   - **Save** the assistant changes

**📝 Note:** You can assign skills to your assistant permanently via "Edit Assistant" page, or add them on-the-fly to individual conversations. Conversation-level skills are only active within that specific chat.

### Step 5: Test Your Skills with Real Queries
   
  **Start Chat with Assistant:**
   - Start Chat with the assistant you attached the created skill to
   - Provide relevant to Skill input
   - Observe how skill loaded automatically because your query matched its description
  

**✅ Success Criteria:**
- [ ] Downloaded the example skill file and reviewed its format
- [ ] Created a Jira ticket structure skill file
- [ ] Successfully imported the file using "Import from file"
- [ ] Attached the skill to an assistant
- [ ] Verified the skill appears in the assistant's Skills section
- [ ] Skill tested via conversation with the Assistant


**🏆 Bonus Challenge:**

Try the alternative quick-create method:
1. Go to your assistant's Edit page
2. In the Skills section, click the **"+ Add"** button
3. Instead of selecting an existing skill, look for **"Create New Skill"** option
4. A quick-create popup appears
5. Upload skill file for another Skill purpose
6. Test Skill by invoking it from the Chat

## 🎯 Challenge 3: Simplify Complex Assistants Setup with Skills + Tools Pattern

**Goal:** Build a lightweight, specialized assistant using the Tool + Skill pattern instead of complex sub-assistant architectures

### Instructions

Sometimes you need a focused assistant for a specific task, but you don't want the overhead of creating sub-assistants or supervisor patterns. The Tool + Skill combination offers a simpler, more elegant solution!

For example, let's build an assistant that helps with Jira ticket analysis during release preparation or another Assistant relevant to your needs that requires tools usage.

### Step 1: Create a Simple Assistant with Minimal Instructions

**ℹ️ Note:** You can use the **ChatGPT template** as a starting point - it already has minimal instructions, making it ideal for this exercise.

### Step 2: Use Skill-Level Tool Configuration

You can configure tool dependencies directly in your skill. This approach offers several advantages:

**How it works:**
- When creating your skill (Step 3), you'll see a **"Tools"** section
- Select tools this skill needs to function (e.g., Jira tool for Jira-related skills)
- These tools are automatically applied to any assistant that uses this skill

**Benefits of this approach:**
- ✅ **Reusability:** The skill carries its tool dependencies wherever it's used
- ✅ **Simplicity:** No need to manually configure tools for each assistant
- ✅ **Consistency:** The skill always has the tools it needs to work correctly

**Example:** A business analysis skill that interacts with Jira would have the Jira tool selected at the skill level. Any assistant using this skill automatically gets Jira access - even if the assistant doesn't have Jira configured directly.
Alternatively, you can enable the corresponding Tool in your Assistant

**📌 Alternative:** Enable tools directly on the assistant - good for general-purpose assistants

### Step 3: Use Jira Project Analysis Skill or another Skill with Tool relevant to your needs and Test Your Simplified Assistant

       **🔄 Remember:** There are two ways to add skills:
> 1. **Attach to assistant** - then start a conversation
> 2. **Insert directly into conversation** - add the skill on-the-fly during chat

  For this challenge, try **either approach** - both will work!

- Begin conversation with your Assistant and check how Skill helps with the request

### 🎥 Watch the Skills Feature in Action

Want to see everything you just learned in a visual walkthrough? Check out this comprehensive video tutorial:

**[Skills Feature Tutorial - Creating Modular AI Knowledge](https://youtu.be/KVUUcw9VinA)**

**🏆 Bonus Challenge:**
- Try using DIFFERENT skills with SAME assistant
- Share your Skill with your team for reuse

**✅ Success Criteria:**
- [ ] Created a simple assistant (minimal instructions or with ChatGPT template)
- [ ] Configured tools at skill level (or assistant level as an alternate)
- [ ] Understand both ways of adding skills (assistant-level vs. conversation-level)
- [ ] Tested with queries and observed automatic skill activation
- [ ] Got structured, intelligent responses combining tool + skill capabilities
- [ ] Understand the Tool + Skill pattern advantages

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered the Skills feature:

✅ **Discovered** the Skills interface (Project Skills + Marketplace)  
✅ **Created** a skill
✅ **Tested** how skills load on-demand based on queries  
✅ **Built** specialized assistants combining tools + skills  
✅ **Experienced** how Skills simplify complex workflows  

**Thank you for completing this kata!** 🚀
