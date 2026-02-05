# Multi-Assistant Speed Run: Build Your AI Dream Team

Imagine having a team of AI specialists where each member excels at different tasks—and a smart manager who knows exactly who to call for each job. That's the power of **Multi-Assistants** in CodeMie!

In this lightning-fast kata, you'll master the art of building hierarchical AI teams. You'll create an **Orchestrator Assistant** (the manager) that delegates work to specialized **Sub Assistants** (the experts). By the end, you'll understand how to design AI systems where assistants work together seamlessly.

**What makes Multi-Assistants special?**
- 🎯 **Smart delegation**: Orchestrator chooses the right specialist for each task
- 🔧 **Specialization**: Each Sub Assistant has focused expertise and tools
- 🚀 **Simplicity**: One chat interface, multiple AI experts working behind the scenes
- 📊 **Scalability**: Easily add or remove specialists without changing your workflow

Let's build your AI dream team!

---

## 🎯 Challenge 1: Understand Multi-Assistant Architecture

**Goal:** Learn how orchestrator and sub-assistants work together to solve complex tasks

### What is Multi-Assistant Functionality?

Let's start by understanding the power of multi-assistant systems.

The Multi-Assistant functionality is a sophisticated feature in AI/Run CodeMie platform designed to enhance agent-to-agent communications and facilitate the customization and management of AI-powered assistants tailored to work together on specific use cases. This feature allows users to craft personalized assistants with diverse properties, integrate powerful tools, and manage interactions within Assistants to resolve a chain of tasks or cover multipurpose requests —all within an intuitive interface. The Multi-Assistant introduces an innovative framework where one **Orchestrator Assistant** manages and delegates work to multiple **Sub Assistants**. Think of it as a project manager coordinating a team of specialists.

**How it Works:**
All interaction is done within the chat with the Orchestrator (so called multi-assistants chat):
1. **User** → Sends request to **Orchestrator**
2. **Orchestrator** → Analyzes request and Sub Assistant descriptions
3. **Orchestrator** → Coordinates the workflow and calls relevant **Sub Assistant(s)**
4. **Sub Assistant(s)** → Process request using their tools and knowledge
5. **Orchestrator** → Summarizes all retrieved results and responds to **User**

**Key Benefits:**

✅ **Specialization**: Each sub-assistant excels in a specific domain
✅ **Modularity**: Easily add/remove specialists without changing others
✅ **Scalability**: Handle complex multi-domain tasks effortlessly
✅ **Maintainability**: Update individual specialists independently

### When to Use Multi-Assistant

✅ **Good Use Cases:**
- Tasks requiring multiple areas of expertise
- Workflows with specialized domains (coding + documentation + testing)
- Requests that combine different tools or data sources
- Scenarios where you want focused, expert responses

❌ **Not Ideal For:**
- Very simple, single-task requests
- Complex conditional logic with many branches
- Iterative workflows requiring state management across many steps

💼 **Real-World Example:**

Imagine asking: *"Create a Jira ticket for the new login feature and implement it in our GitHub repository"*

- **Business Analyst Assistant** (with Jira tool) creates a detailed Jira ticket with requirements
- **Developer Assistant** (with GitHub tool) implements the feature and creates a pull request
- **Orchestrator** coordinates both specialists and provides a unified response with ticket ID and PR link

**✅ Success Criteria:**
- [ ] Understand the Orchestrator and Sub Assistant roles
- [ ] Know how the multi-assistant's chat works
- [ ] Can identify good use cases for Multi-Assistant
- [ ] Understand limitations

---

## 🎯 Challenge 2: Learn the Golden Rules

**Goal:** Master the critical rules for configuring Multi-Assistant systems correctly

### The Golden Setup Rules

**Rule #1: Orchestrator Acts as Delegation Manager Only**
- ✅ Orchestrator should ONLY have Sub Assistants (no other tools/datasources)
- ❌ Don't add Jira, Slack, or any tools directly to Orchestrator
- 💡 Why? Sub Assistants already have tools; Orchestrator just delegates

**Rule #2: Orchestrators Cannot Be added as a Sub Assistants**
- ✅ Only simple assistants can be Sub Assistants
- ❌ Never add an Orchestrator Assistant as a Sub Assistant
- 💡 **Why?** Ensures clear hierarchy with Orchestrator as the primary managing entity

**Rule #3: Descriptive Names Matter**
- ✅ Sub Assistant descriptions must clearly state their role/tools/knowledge
- ❌ Avoid using vague or incomplete descriptions
- 💡 Why? Orchestrator selects Sub Assistants based on descriptions

### Key Tips for Sub Assistant Descriptions

Your descriptions should answer:
- **What does this assistant do?** (role/responsibility)
- **What tools does it use?** (integrations/capabilities)
- **What knowledge does it have?** (datasources/expertise areas)

**Good Example:**
```
"Python code reviewer with GitHub integration. Analyzes code for
PEP 8 compliance, security vulnerabilities, and performance issues.
Has access to internal coding standards documentation."
```

**Bad Example:**
```
"Helpful assistant that does coding stuff"
```

**Rule #4: Sub Assistant Selection Depends on Your Role**
- 💡 **Why?** Access control ensures proper assistant sharing and project boundaries

**For Regular Users (Non-Admins):**
- ✅ Can select Sub Assistants from **same project** as the Orchestrator
- ✅ Can select Sub Assistants from **Marketplace** (public assistants)
- ❌ Cannot select assistants from other projects

**For Administrators:**
- ✅ Can select Sub Assistants from **any project** on the platform
- ✅ Can select Sub Assistants from **Marketplace**
- ✅ Full access to all assistants across the organization

**📋 Configuration Checklist:**

Before creating your multi-assistant system, verify:
- [ ] Orchestrator has **no tools** (only sub assistants)
- [ ] Each sub assistant has a **clear, specific description mentioning role, tools, and knowledge**
- [ ] Sub assistants have **their own tools/datasources**
- [ ] No circular references (orchestrator not in sub assistants)

**✅ Success Criteria:**
- [ ] Understand which configurations should be present in Orchestrator
- [ ] Understand the importance of sub assistant descriptions
- [ ] Know where tools and datasources should be configured
- [ ] Understand sub assistant visibility rules

**🏆 Bonus:**
- Explain how the Orchestrator decides which Sub Assistant to call
- Think of a real scenario where Multi-Assistants would help your team

---

## 🎯 Challenge 3: Create Your Specialist Team

**Goal:** Set up or identify 2 specialized Sub Assistants for your team

### Instructions

Now, let's check it on practice!
First, think about the multi-assistant use case that would be relevant to your project needs or could help you with routine tasks.
Have you come up with some ideas? Now we need to prepare specialists to whom your Orchestrator will delegate work. You have two options for this:

**Option A: Use Existing Assistants from Marketplace**

1. **Open Marketplace** in CodeMie sidebar
2. **Find two specialized assistants** relevant to your work
- Verify that their description is filled in sufficiently
- Assure that the selected assistant does not contain any sub assistant
3. **Note their names** - you'll need them for the next challenge

**💡 Tip:** Check out Kata "Assistants Marketplace: Your Gateway to Ready-to-Use AI Solutions" for more details on exploring the Marketplace.

**Option B: Create Your Own Sub Assistants**

If you prefer creating custom specialists:

1. **Navigate to Assistants** → "+ Create Assistant"
2. **Create Specialist #1** relevant for your multi-assistant use case following the configuration rules you've learned before.

**💡 Tip:** To master the assistant creation skills, please refer to Kata "Create Your AI Assistant with CodeMie"

**✅ Success Criteria:**
- [ ] Identified or created two specialized Sub Assistants
- [ ] Each Sub Assistant has a clear, descriptive purpose
- [ ] Sub Assistants have relevant tools/datasources configured, if needed
- [ ] Selected/created assistants do not have sub assistants in their own configurations
- [ ] Can explain what each Sub Assistant specializes in
- [ ] Ready to connect them to an Orchestrator

**🏆 Bonus:**
- Create a third Sub Assistant for even more specialization
- If previous two Sub Assistant are from Marketplace, create the third one on your own
- Test each Sub Assistant individually before connecting to Orchestrator

---

## 🎯 Challenge 4: Build Your Orchestrator

**Goal:** Create an Orchestrator Assistant that manages your specialist team

### Instructions

Now let's create the "manager" that will coordinate your AI team!

1. **Navigate to Assistants** → "+ Create Assistant"
2. **Configure Your Orchestrator** following the recently learnt configuration rules.
3. **In the system instruction**, include at least general rules for tasks delegation, or specify certain rules for Sub Assistants transitioning if required for your use case. You can also define the output format for all collected results or add any additional details.

   **Example** of general Orchestrator's System Instructions:

   ```
   You are an orchestrator managing a team of specialized AI assistants.

   Your job:
   - Analyze user requests carefully
   - Check the description of all available Sub Assistants
   - Select the most appropriate Sub Assistant(s) to handle each task
   - Call multiple specialists when needed for complex requests
   - Synthesize responses from Sub Assistants into clear answers

   ```
4. From the drop-down list **in the "Sub Assistant" field** select all recently prepared assistants.

![Sub Assistants selection](https://codemie-ai.github.io/codemie-katas/katas/multi-assistant-functionality/images/sub-assistant-selection.png)

**💡 Tip:** Once Orchestrator setup is done and saved, information about whether the Sub Assistant has been published to the Marketplace will be displayed on the Orchestrator Assistant details page.

![Sub Assistants view](https://codemie-ai.github.io/codemie-katas/katas/multi-assistant-functionality/images/sub-assistants-view.png)

**✅ Success Criteria:**
- [ ] Orchestrator created with clear delegation instructions
- [ ] ONLY Sub Assistants selected (no other tools, datasources or Orchestrator)

**🏆 Bonus:**
- Add conversation starters to your Orchestrator as examples of it's usage
- Add instructions for handling edge cases (what if no specialist fits?)

---

## 🎯 Challenge 5: Test Your Multi-Assistant System

**Goal:** Verify your AI team works together correctly through real queries

### Instructions

Time to see your AI team in action! Let's test how the Orchestrator delegates tasks.

1. **Open Chat with Your Orchestrator**
   - Click on your Orchestrator in your Assistants list
   - Start a new chat

2. **Test Single Specialist Routing**
   - Ask a query that should route to ONE specific Sub Assistant
   - Observe how the Orchestrator identifies and delegates to the correct specialist
   - Verify you receive an expert response from the correct Sub Assistant

3. **Test Multi-Specialist Coordination**
   - Ask a complex query that requires MULTIPLE Sub Assistants
   - Watch the Orchestrator coordinate between specialists
   - Verify the final response synthesizes inputs from multiple assistants

**✅ Success Criteria:**
- [ ] Successfully chatted with your Orchestrator
- [ ] Orchestrator correctly routed single-specialist queries
- [ ] Orchestrator correctly coordinated multi-specialist queries
- [ ] Observed delegation in action
- [ ] Received expert responses from Sub Assistants
- [ ] Understand how routing works based on descriptions

**🏆 Bonus Challenges:**
- Test with intentionally ambiguous queries to see routing logic
- Try requesting all specialists at once
- Ask the Orchestrator to explain its routing decision
- Test error handling by asking for non-existent specialist capabilities

**💡 Troubleshooting:**

**Problem:** Orchestrator not calling Sub Assistants
- **Fix:** Check Sub Assistants are selected in Orchestrator's configuration in Sub Assistants field
- **Fix:** Make Sub Assistant descriptions more specific

**Problem:** Wrong specialist being called
- **Fix:** Improve Sub Assistant descriptions
- **Fix:** Update Orchestrator's system instructions with clearer rules

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered Multi-Assistant functionality in record time:

✅ **Understood** the orchestrator-sub-assistant architecture and workflow
✅ **Learned the Setup Golden Rules** for Multi-Assistant success
✅ **Practiced in planning the Multi-Assistant flow and participants** based on your use case
✅ **Identified/Created specialized Sub Assistants** with clear purposes
✅ **Built an Orchestrator** that intelligently delegates tasks
✅ **Tested smart routing** with single and multi-specialist queries

### Your Multi-Assistant Superpowers

You now know how to:
- **Design hierarchical AI assistant team** with Orchestrators and Sub Assistants
- **Write effective descriptions** that enable smart routing
- **Avoid common pitfalls** in Multi-assistant's setup
- **Test and verify** Multi-Assistant systems
- **Scale your AI capabilities** through specialization

### Next Steps

Ready to take your Multi-Assistant skills further?

1. **Add More Specialists**: Expand your team with additional Sub Assistants
2. **Integrate More Datasources and Tools**: Supercharge your Sub Assistants with additional tools and/or knowledge bases
3. **Create Domain Teams**: Build specialized Orchestrators (DevOps Team, Marketing Team)
4. **Advanced Routing**: Experiment with complex delegation rules in system prompts

### 💡 Pro Tips for Production

- **Keep Sub Assistant descriptions updated** as you add tools/datasources
- **Test routing regularly** when modifying Sub Assistants
- **Use conversation starters** to start interaction in multi-assistant chat easier

Happy orchestrating! 🎭🤖