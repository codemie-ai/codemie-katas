# Explore the Assistants Marketplace

This is your gateway to discovering, sharing, and leveraging AI assistants created by the global community. Instead of building every assistant from scratch, you can find ready-to-use solutions, customize them for your needs, and share your own creations with others.

Think of the Marketplace as an app store for AI assistants — a centralized hub where the community's best work is just a click away!

In this kata, you'll learn to navigate the Marketplace like a pro, find exactly what you need using powerful filters, start using pre-built assistants, as well as publish your own assistants to the Marketplace!

Let's dive in! 🚀
---

## 🎯 Challenge 1: Navigate and Search the Marketplace

**Goal:** Access the Marketplace, understand its layout, and use search and filters to find relevant assistants

![Marketplace layout](https://codemie-ai.github.io/codemie-katas/katas/assistants-marketplace-gateway-to-ai-solutions/images/kata_marketplace.png)

### Instructions

Let's start by exploring the Marketplace, understanding its organization and learning to find exactly what you need using search and filtering tools.

1. **Open CodeMie** in your browser
2. **Navigate to Assistants** in the main menu
3. **Click on the "Marketplace" tab** to access the global collection

4. **Observe the layout:**
   - **Left sidebar**: Contains search and filtering options (Categories, Created By)
   - **Main area**: Displays assistant cards ranked by popularity
   - **Assistant cards**: Shows key information as assistant's name, description, ratings, users usage, and more
   
5. **Notice the ranking**: Popular assistants appear at the top because they've been adopted by more users — this helps you find trusted, widely-used solutions quickly!


6. Now let's find exactly what you need using search and filters. **Try the Search Bar** - Type a keyword that interests you:
   ```
   code review
   ```
   or
   ```
   documentation
   ```
   See how results adjust in real-time!

**Note:** The search or filter data you entered will remain pre-populated for your convenience. You can delete it manually or by clicking the "Clear All" button.

7. **Use the Categories Filter** (left sidebar):
   - Click on the **Categories dropdown**
   - Browse available categories (they're organized by function and purpose)
   - Select a category relevant to your work (e.g., "Engineering", "Product Management", "Quality Assurance")
   - Notice how the assistant list updates instantly

8. **Filter by Creator** (left sidebar):
   - Use the **"Created By"** dropdown to see assistants by a specific user
   - This helps find assistants from trusted contributors

9. **Find Your Own Assistants**:
   - Check the **"Created by Me"** checkbox
   - This shows only assistants you've created (useful when you have many)

10. **Combine Filters**: Try using both search AND category filter together:
    - Search for "jira"
    - Select a category like "Business Analysis"
    - Watch the results narrow to exactly what you need

**💡 Pro Tips:** 
- The Marketplace only contains assistants that provide broad value to the community. Project-specific or personal assistants stay in your project workspace.
- If you're not sure what you need, browse by category first, then refine with search!

**✅ Success Criteria:**
- [ ] Located and observed the Marketplace tab in the Assistants section 
- [ ] Understand how assistants are displayed and ranked
- [ ] Used search and available filters to narrow down results and find relevant assistants
- [ ] Found 2-3 assistants that match your role or interests

---

## 🎯 Challenge 2: Preview and Understand Assistants

**Goal:** Learn to evaluate pre-built assistants before using them

![Marketplace assistant details](https://codemie-ai.github.io/codemie-katas/katas/assistants-marketplace-gateway-to-ai-solutions/images/kata_marketplace_assist_details.png)

### Instructions

Before using an assistant, it's important to understand what it does and how it works. Let's explore an assistant's details.

1. **Click on an Assistant Card** from your search results to open its detail page

2. **Review Assistants Description and Conversation Starters (if any)**:
   - Understand what this specific assistant does and what problems it solves
   - Check if it matches your use case
   
3. **Check Integration Requirements**:
   - Look for a note above the description about **customizable integrations**
   - If present, this means you can configure which integration the assistant uses (e.g., your personal Jira workspace vs. team workspace)
   - **To select an integration**: scroll down to the **"Your Integration Settings"** section and select integration from the dropdown field
   - If not selected, the default integration will be used, following this priority:
     - Your personal (non-global) integration → Your global integration → Project integration

4. **Review System Instructions**:
   - Scroll to view the assistant's **System Instructions** 
   - Check if any **Prompt Variables** are used — if present, they'll appear below the System Instruction field
     - Review the default values and adjust them individually for your own use if needed

**📝 Note:** Marketplace ready-to-use assistants come in two flavors: assistants that need no settings adjustments and can be used immediately (like the **"AI/Run FAQ"** assistant), and the ones with customizable settings like integrations or prompt variables that can be updated for proper use and your specific needs (like the **"CodeMie BA Assistant"**).

**✅ Success Criteria:**
- [ ] Reviewed assistant's details and system instructions 
- [ ] Identified the assistant's capabilities and purpose
- [ ] Understand the configuration options and customization possibilities

---

## 🎯 Challenge 3: Use a Pre-built Assistant

**Goal:** Start using a Marketplace assistant

### Instructions

Now for the exciting part — let's put an assistant to work! 

**Option A: Use Out-of-the-Box**

1. **Select an Assistant** from the Marketplace by clicking on its card

2. For  assistants that have available customizable settings, **update configurations**:
   - If Prompt Variables are present, review their default values
      - Click on **Edit** button near any variable to **update the value** to match your specific use case
   - If the assistant requires an Integration (e.g., Jira, Confluence, GitHub), select your preferred integration from the dropdown
      - If you don't select one, the default integration will be used following the priority: Personal → Global → Project
      - **Tip**: Choose your personal integration if you want to work with your own workspace/data

**💡 Power Tip:** Take a moment to configure settings before your first chat — it ensures the assistant works exactly how you need it from the start!

3. **Start using the Assistant** by clicking the "Chat Now" button at the top right corner of the assistant's detail page

4. **Interact and explore** the assistant's capabilities:
   - Try different conversation starters if they were provided
   - Type your own task or question relevant to the assistant's purpose
   - Test how the assistant responds to your specific use cases
   - Notice how your configuration (prompt variables, integrations) affects the responses

**🏆 Bonus Challenge:**
- Try the same assistant with different prompt variable settings and compare results
- Use assistants from 2-3 different categories to explore different use cases


**Option B: Clone and Make Your Own Customization**

If you want to significantly change the assistant's settings or behavior, or if configurations adjustment is not available for this particular assistant:

1. **Go back to the Marketplace page**
2. **Find an assistant** in the list
3. **Click the three dots menu** (⋮) on the assistant card
4. **Select "Clone"**
5. **In the Clone dialog**:
   - Choose your **project** from the dropdown (only projects you're assigned to appear)
   - Give it a **unique name/slug** (must be unique within your project)
   - Click **"Clone Assistant"**
6. **Wait for confirmation** that cloning is successful
7. **Navigate to your Project Assistants** tab to find and customize your cloned copy

**💡 Power Tip:** Clone when you want to modify hardcoded values, adjust the prompt, or change integration settings for your personal usage. Use out-of-the-box for immediate, no-fuss utilization!

**✅ Success Criteria:**
- [ ] Understand when to use marketplace assistant out-of-the-box, and when to clone
- [ ] Reviewed and customized available assistants configurations
- [ ] Successfully used a pre-built assistant out-of-the-box
- [ ] Had a meaningful interaction with assistant that demonstrates the assistant's capabilities
- [ ] Understand how configuration choices affect the assistant's behavior
- [ ] For cloned assistant: successfully created a copy in your project


---

## 🎯 Challenge 4: Publishing Basics (Optional Exploration)

**Goal:** Understand how to share your own assistants with the Marketplace community

![Publish to marketplace](https://codemie-ai.github.io/codemie-katas/katas/assistants-marketplace-gateway-to-ai-solutions/images/kata_publish_marketplace.png)

### Instructions

Want to share your amazing assistant with the community? Here's a comprehensive overview of the publishing process. (You don't need to actually publish — just understand the workflow!)

**💡 Publishing Tip:** When considering publishing an assistant to the Marketplace, please share only those assistants that offer broad value and can benefit other users or organizations. Assistants created for highly specific or personal use cases are best suited for usage within a particular project or kept for private use. This thoughtful approach helps keep the Marketplace focused on relevant solutions for the wider community, while ensuring individual or project-specific assistants remain accessible in their intended context.

**Publishing Workflow Overview:**

1. **Start from Project Assistants**:
   - Go to your Project Assistants tab
   - Select an assistant you want to publish

2. **Initiate Publishing**:
   - Click the **three dots menu** (⋮) on the assistant card
   - Select **"Publish to Marketplace"**
   - **Note**: Datasources are automatically removed when publishing to protect your private data

3. **Handle Integrations**:
   - If your assistant uses integrations, a modal appears
   - Choose: Keep your integration (others will use it) OR set to default (users can configure their own)
   - **Important**: When a user or project-specific integration is chosen, such integration becomes globally accessible as part of the published solution. This means that all other users will utilize the predefined integration settings and credentials when using such marketplace the assistant.

4. **Select Categories** (Required):
   - Choose up to **3 relevant categories**
   - At least **1 category is mandatory**
   - This helps users discover your assistant

5. **Complete Publishing**:
   - Click "Publish"
      - The system checks the assistant's configuration and either publishes it immediately, or highlights the improvements to be made
   - Your assistant moves from Project Assistants to Marketplace
   - Now available globally for all users!

**For Multi-Assistants** (orchestrator + sub-assistants):
- You can publish just the orchestrator or include sub-assistants
- Specify categories for each component

**After Publishing:**
- View usage statistics and user feedback (likes/dislikes)
- Edit details or remove from Marketplace (owner/admin only)
- If removed, assistant returns to your Project Assistants


**✅ Success Criteria:**
- [ ] Understand the publishing rules for broad usage
- [ ] Understand the basics of publishing workflow from Project Assistants
- [ ] Know the difference between personal integrations and default integrations
- [ ] Understand that datasources are removed on publish
- [ ] Know that categories are required (1-3)
- [ ] Aware that published assistants can be managed and unpublished

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered the Assistants Marketplace and are ready to accelerate your work with pre-built AI solutions:

✅ **Navigated** to the Marketplace and understood its layout
✅ **Used search and filters** to find relevant assistants quickly
✅ **Previewed assistants** to understand their capabilities and requirements
✅ **Started using** assistants out-of-the-box or cloned them for customization
✅ **Learned** the basics of publishing assistants to share with the community

### Your Marketplace Superpowers

You now know how to:
- Find the perfect assistant for any task using categories and search
- Evaluate assistants using all available information
- Use out-of-the-box assistants
- Clone and customize assistants to match your specific needs
- Understand how integrations and datasources are handled
- Share your own assistants with the global community

### Next Steps

Continue your CodeMie journey by:

1. **Explore More Assistants**: Browse different categories to discover solutions for various use cases
2. **Collect Your Toolkit**: Find 3-5 assistants that match your daily workflow and use them regularly
3. **Collaborate**: Share Marketplace assistants with your team
4. **Contribute**: Create and publish an assistant that brings the value to the community

**Remember:** The Marketplace is constantly growing with new contributions. Check back regularly to discover fresh solutions and improvements from the community!

Happy exploring! 🚀