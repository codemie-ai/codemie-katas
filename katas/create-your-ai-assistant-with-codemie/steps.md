# Create and Edit Your First Assistant

Welcome to the world of AI Assistants in CodeMie! This kata will transform you from a beginner to a confident Assistant creator. You'll explore the Assistants section, create your first AI assistant, and learn to customize it for your specific needs.

By the end of this challenge, you'll have hands-on experience with the complete Assistant lifecycle—from discovery to creation and editing—and you'll be ready to build powerful AI solutions for any task.

---

## 🎯 Challenge 1: Create Your First Assistant from Scratch

**Goal:** Build a custom AI Assistant with your own configuration

### Instructions

Let's start by getting familiar with where everything lives in CodeMie.

1. Navigate to the **Assistants menu** in the left sidebar
   
2. Go to **Project Assistants** tab and **Find the "+ Create Assistant" button** in the top right corner

3. **Choose your creation method** in the popup:

![generate with AI](https://codemie-ai.github.io/codemie-katas/katas/create-your-ai-assistant-with-codemie/images/generate_with_AI.png)

**Option A: "Generate Assistant with AI"** - Describe your main idea and requirements for the assistant, then let the AI configure it for you.
   
If you select AI generation, the platform recommends features and tools (if selected to be included) that fit their goals, then automatically builds an assistant profile—including its name, description, conversation starters, and crucial system instructions. 
   
**Option B: "Create Manually"** - Configure everything yourself

**✨ For this challenge, select **"Create Manually"** to learn all the settings.**

4. **Configure Project Settings:**

**Project:** [Select your project]

**Shared with Project:** ☐ Unchecked (keep it private for now)

**📝 Note:** You can't share assistants that use personal integrations, and assistants can only be shared within one project.

5. **Fill in Basic Information:**

**Name:** A unique identifier you give to your Assistant.

**Slug:** A web-friendly version of the Name field used in URL links. It's automatically filled out based on the name using lowercase letters, hyphens (-) instead of spaces, and no special characters. You can adjust it manually if needed.

**📖Example**: If the Assistant's name is "Test Chatbot", the Slug will be automatically generated as "test-chatbot".

**Icon URL (Optional):** A link to an image (.png or .svg formats) that represents your Assistant. You can use your own icons (stored in SharePoint, a repository, or any accessible cloud storage) or copy links from any template on the AI/Run CodeMie platform.

**Description:** A brief explanation of the Assistant's purpose and functionality.

**Categories:** Choose up to 3 categories that describe your assistant's use case.

**Add Conversation Starters** (Optional): You can add up to four example questions that users will see when they begin chatting with your Assistant. They help show users what kind of questions they can ask and how to begin the interaction effectively.

**📖Example**: "Create a to-do list from this meeting notes"

6. **Configure Behavior & Logic:**

**System Instructions:** A prompt that guides how the Assistant interprets and responds to user queries.

👉 Use the **Generate with AI** functionality. Find corresponding button in the top of **System instructions** section, click on it and provide a description of your assistant's goals and behavior, then the AI will generate system instructions for you.

👉 As an alternative, you can find the **Prompt Engineer Assistant** in the Marketplace or in the left sidebar. Use this assistant to create, refine, and optimize prompts for LLMs or LLM-driven AI Assistants. It provides predefined prompt structures and applies best practices automatically, handling both simple and complex instructions. Use this Assistant to save time and improve the quality of your system instructions.

**LLM Model:** The list of all LLMs available in the AI/Run CodeMie. Choose the one that you want to use for your Assistant.

**Temperature(Optional):** Controls the output's randomness. A lower temperature makes the output more deterministic and focused, while a higher temperature increases diversity and variety in responses. If you want a neutral result, keep the temperature in the middle, around 0.5-1.

**Top P(Optional):** An alternative to Temperature that controls response variety by limiting the cumulative probability of word (token) choices.

7. **Context & Data Sources**

- **Datasource Context (Optional):** External data sources that your Assistant can reference when processing requests. You can add different types in data sources, including files of various formats (.pdf, .txt, .csv, and others), Google documents, Confluence pages and more.

- **Sub Assistants (Optional):** Here you're able to select specialized assistants to work under an orchestrator assistant.

📚 This feature will be covered in the Kata **"Master Multi-Assistant Orchestration: Build Your AI Team"**

8. **Available Tools (Optional):** This option allows you to significantly expand your Assistant's capabilities by enabling various tools from a toolset.

**Note:** Most tools demand the configuration of integrations in the Integrations menu first. They require more computing resources and may affect your Assistant's response time.

9. **Click "Create"** button at the bottom and observe your newly created assistant appeared in **Project Assistants** page

**✅ Success Criteria:**
- [ ] Successfully created an assistant
- [ ] Assistant appears in your Project Assistants tab

**🏆 Bonus Challenge:**
- Use the **"Generate Assistant with AI"** option to create another assistant — describe what you want and see how AI configures it!

---

## 🎯 Challenge 2: Create an Assistant from a Template

**Goal:** Quickly create an assistant using a pre-configured template

### Instructions

Templates save time by providing tested configurations. Let's create an assistant the fast way!

1. **Go to the Templates tab** in the Assistants menu

  ![templates tab](https://codemie-ai.github.io/codemie-katas/katas/create-your-ai-assistant-with-codemie/images/templates_tab.png)
  
2. **Browse available templates** and find one that interests you:

3. **Click on your chosen template** to open the Template Details window

4. **Review the template configuration:**
- Read the description
- Notice the pre-configured system instructions

5. **Click "+ Create Assistant"** button in the top right

**💡 Pro Tip:** When you click "+ Create Assistant" from a template, you'll see two options: "Generate with AI" or "Create Manually". 
The **Generate with AI** option lets you describe how you want to customize the template, and AI will automatically adapt the name, description, conversation starters, and system instructions to match your needs—saving you significant configuration time!

  **In case Manually creation**

Name: [Specify Assistants' name]
Description: [Adjust to your specific needs]
System Instructions: [Review and customize if needed]

💭 For this purpose you also can use:

- **Refine with AI** feature located in the top of **System Instruction** section - add details, comments, or suggestions to enhance existing system instructions.
- **Prompt Engineer Assistant** - copy available system instructions and ask assistant to improve it

6. **Adjust any settings** you want to change (model, temperature, etc.)

7. **Click "Create"** button and find this assistant in the **Project Assistants** page

8. **Start chat** whith it and check how it works

### 📹 Video Tutorial

Watch this step-by-step video to see the entire process in action:
**[Create Assistant from Template](https://youtu.be/B2epXrdyG_E?si=Cez9lScZD406dXDF)**

**✅ Success Criteria:**
- [ ] Located and explored the Templates tab
- [ ] Selected and reviewed a template's configuration
- [ ] Created an assistant from the template
- [ ] Customized at least one field (name, description, or instructions)
- [ ] Successfully chatted with the template-based assistant

**🏆 Bonus Challenge:**
- Find a template that uses tools and investigate how it should be configured for the proper work

---

## 🎯 Challenge 3: Edit Your Assistant

**Goal:** Learn to modify and improve existing assistants

### Instructions

Your assistants will evolve as you use them. Let's learn how to edit and improve them!
There are 2 ways of editing your Assistant:

- Manually
- By using **Refine with AI** feature: 

👉 In case you want improve your Assistant together with its' configurations, you can use the **Refine with AI** functionality in the top right corner of the **Edit Assistant page** - describe what you'd like to improve or refine about this assistant, than AI will analyze your configuration and suggest improvements.

👉 To enhance only system instructions - use the **Refine with AI** located in the top of **System Instruction** section

Now let's explore the different methods to access the **Edit Assistant** page, where you can modify and improve your assistant using either approach.

### Method 1: Edit from Assistants Menu

1. **Go to Project Assistants** tab

2. **Find one of your first assistant**

3. **Click the three dots (⋮)** on the assistant card

![edit](https://codemie-ai.github.io/codemie-katas/katas/create-your-ai-assistant-with-codemie/images/edit.png)

4. **Select "Edit"** from the menu

5. **The Edit Assistant page opens** with all your current settings

6. **Make these improvements:**

➡️**Update the Name**

➡️**Enhance System Instructions:**
Use **Refine with AI** feature - add details, comments, or suggestions to enhance your existing system instructions.

![Refine with AI](https://codemie-ai.github.io/codemie-katas/katas/create-your-ai-assistant-with-codemie/images/refine_with_AI.png)

➡️**Add a new Conversation Starter:**

7. **Click "Save"** at the top right corner


### Method 2: Quick Edit from Chat

1. **Open a chat with your assistant** (click Start Chat)

2. **Click the assistant icon** in the chat header OR click **"Configuration"** button

3. **Click "Configure & Test"** in the Connected Assistants section

4. **Make quick changes** to any settings

5. **Click "Save"** to apply changes

**💡 Pro Tip:** The History tab only appears after you've saved changes to your System Instructions at least once. Each save creates a new version with a timestamp, so you can track exactly when you made each change.

### Test Your Changes

1. **Start a new chat** with your edited assistant
2. **Compare the response** to what you might have gotten before—notice how the enhanced instructions improve the quality!

**✅ Success Criteria:**
- [ ] Edited assistant via the three-dots menu
- [ ] Updated assistant name and system instructions
- [ ] Added a new conversation starter
- [ ] Found the System Instructions History tab
- [ ] Successfully edited assistant from the chat interface
- [ ] Tested changes and noticed improved responses

**🏆 Bonus Challenge:**
- Restore a previous version from System Instructions History

---

## 🎯 Challenge 4: Delete and Archive Assistants

**Goal:** Understand assistant lifecycle management and cleanup

### Instructions

Sometimes you need to remove assistants you're no longer using. Let's learn how to do this safely.

1. **Delete the one of the created assistant:**
- Go to **Project Assistants** tab
- Find assistant you would like to delete
- Click the **three dots (⋮)**
- Select **"Delete"**
- **Confirm deletion** in the popup

3. **Understand what happens after deletion:**
- Assistant is removed from your Project Assistants list
- **Chat history remains accessible** (but inactive)
- You need to manually delete chat if desired

**⚠️ Important Notes:**
- **Deletion is permanent** - there's no undo
- **Shared assistants** can only be deleted by their creator

**✅ Success Criteria:**
- [ ] Successfully deleted the assistant
- [ ] Located the chat history for the deleted assistant

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered the fundamentals of creating and managing AI Assistants in CodeMie:

✅ **Created** an assistant from scratch with custom configuration and from a template
✅ **Learned** about **Generate with AI** and **Refine with AI** functionality
✅ **Edited** assistants using multiple methods (menu and chat interface)
✅ **Managed** version history and restored previous configurations
✅ **Deleted** assistants and understood lifecycle management

### Next Steps

Ready to build more powerful assistants? Here's your learning path:

1. **Add Tools & Integrations:**
2. **Configure Datasources:**
3. **Find out more about Marketplace** - start **"Assistants Marketplace: Your Gateway to Ready-to-Use AI Solutions"** kata
4. **Advanced Features:**
- Start **"Master Multi-Assistant Orchestration: Build Your AI Team"** kata and create your first **Orchestrator Assistant**
5. **Best Practices:**
- Design conversation starters that guide users effectively
- Test different LLM models for specific use cases
- Share assistants with your team for collaboration

**Remember:** The best assistants evolve over time. Keep experimenting, testing, and refining based on real usage!

**Happy assistant building!** 🚀