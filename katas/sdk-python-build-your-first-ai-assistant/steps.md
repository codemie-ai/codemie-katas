# Build Your First AI Assistant with Python SDK

Welcome to your journey of building AI assistants with CodeMie Python SDK! In this hands-on challenge, you'll go from zero to hero by creating, configuring, chatting with, and managing your own AI assistant—all through Python code.

Through 6 progressive challenges, you'll learn to:
- Connect and authenticate with CodeMie services
- Explore available AI models
- Create assistants with custom configurations and slugs
- Have intelligent conversations with your assistant
- Update and retrieve assistants programmatically
- Properly clean up resources

By the end of this kata, you'll have a complete understanding of assistant lifecycle management and be ready to integrate AI capabilities into any Python project.

---

## 🎯 Challenge 1: Connect to CodeMie

**Goal:** Set up your Python environment and establish your first connection to CodeMie services

### Instructions

First, let's get the SDK installed and create your first authenticated connection.

1. **Install the CodeMie Python SDK**:
```bash
pip install codemie-sdk-python
```

2. **Create a new Python file** called `my_assistant.py`:
```python
from codemie_sdk import CodeMieClient
from time import sleep

# Initialize your CodeMie client
client = CodeMieClient(
    auth_server_url="https://keycloak.eks-core.aws.main.edp.projects.epam.com/auth",
    auth_client_id="your-client-id",
    auth_client_secret="your-client-secret",
    auth_realm_name="your-realm",
    codemie_api_domain="https://codemie.lab.epam.com/code-assistant-api"
)

# Test your connection
print("✅ Connected to CodeMie!")
print(f"Token obtained: {client.token[:30]}...")
```

3. **Get your credentials**: Contact the CodeMie team (vadym_vlasenko@epam.com) or use your existing credentials

4. **Run your script**:
```bash
python my_assistant.py
```

**✅ Success Criteria:**
- [ ] SDK installed without errors
- [ ] Script runs and prints "Connected to CodeMie!"
- [ ] Authentication token is displayed

**💡 Tip:** If you're getting authentication errors, double-check your credentials and ensure your realm name is correct.

---

## 🎯 Challenge 2: Explore Available LLM Models

**Goal:** Discover what AI models are available and choose one for your assistant

### Instructions

Before creating an assistant, let's see what powerful AI models you can use!

1. **Add model listing code** to your `my_assistant.py`:
```python
# List available LLM models
llm_models = client.llms.list()

print("\n🤖 Available LLM Models:")
for model in llm_models[:5]:  # Show first 5 models
    print(f"  - {model.deployment_name}: {model.label or model.base_name}")

# List embedding models
embedding_models = client.llms.list_embeddings()

print("\n📊 Available Embedding Models:")
for model in embedding_models[:3]:  # Show first 3
    print(f"  - {model.deployment_name}")
```

2. **Run your updated script** and observe the available models

3. **Pick your favorite model** - Look for models like `gpt-4o`, `claude-3`, or similar

**✅ Success Criteria:**
- [ ] Successfully retrieved list of LLM models
- [ ] Successfully retrieved list of embedding models
- [ ] Identified at least one model you want to use for your assistant

**🏆 Bonus:**
- Compare different model capabilities
- Note which models support different features (streaming, function calling, etc.)

---

## 🎯 Challenge 3: Create Your First AI Assistant

**Goal:** Build and deploy your very own AI assistant with custom instructions

### Instructions

Now for the exciting part - creating your AI assistant!

1. **Import the necessary models**:
```python
from codemie_sdk.models.assistant import AssistantCreateRequest
```

2. **Define your assistant configuration**:
```python
# Create your assistant request
assistant_request = AssistantCreateRequest(
    name="My Python Helper",
    description="A helpful AI assistant that helps with Python programming",
    system_prompt="""You are a friendly Python programming assistant.
    Help users with Python code, best practices, and debugging.
    Always provide clear explanations and working code examples.""",
    toolkits=[],  # We'll add tools later
    project="user_email@epam.com", # personal user project
    llm_model_type="gpt-5-2025-08-07",  # Use model from Challenge 2
    context=[],
    conversation_starters=[
        "How do I read a CSV file in Python?",
        "Explain list comprehensions",
        "Help me debug my code"
    ],
    slug="my-python-helper",  # Human-readable identifier
    mcp_servers=[],
    assistant_ids=[]
)

# Create the assistant
create_response = client.assistants.create(assistant_request)

print(f"\n🎉 Assistant Created!")
print(f"  Response: {create_response}")

# Wait for assistant to be fully created
print("⏳ Waiting for assistant to be fully created...")
sleep(5)

# Retrieve all assistants and find ours by name
assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

new_assistant = next((a for a in assistants if a.name == "My Python Helper"), None)

if not new_assistant:
    raise Exception("Could not find newly created assistant")

# Save the assistant ID for later use
assistant_id = new_assistant.id

print(f"  Assistant ID: {assistant_id}")
print(f"  Name: {new_assistant.name}")

# Fetch the full assistant details to see the slug
full_assistant = client.assistants.get(assistant_id)
print(f"  Slug: {full_assistant.slug}")
```

3. **Run your script** and watch your assistant come to life!

**✅ Success Criteria:**
- [ ] Assistant created successfully
- [ ] Assistant ID is displayed
- [ ] Assistant has a name, slug, and description
- [ ] Conversation starters are configured

**🏆 Bonus:**
- Customize the system prompt to create an assistant for your domain (DevOps, Data Science, etc.)
- Add more conversation starters
- Experiment with different model types

**💡 Pro Tip:** Save your assistant ID in a variable - you'll need it for the next challenge!

---

## 🎯 Challenge 4: Chat with Your Assistant

**Goal:** Have your first conversation with the AI assistant you created

### Instructions

Time to test your assistant's intelligence!

1. **Add chat functionality**:
```python
from codemie_sdk.models.assistant import AssistantChatRequest

# Prepare your chat request
chat_request = AssistantChatRequest(
    text="What are the benefits of using list comprehensions in Python?",
    stream=False,
    propagate_headers=False
)

# Chat with your assistant (use the assistant_id from Challenge 3)
response = client.assistants.chat(
    assistant_id,  # From previous challenge
    chat_request
)

print(f"\n💬 Assistant Response:")
print(f"{response.generated}")
```

2. **Run your script** and see your assistant respond!

3. **Try different questions**:
```python
# Ask multiple questions
questions = [
    "How do I handle exceptions in Python?",
    "What's the difference between a list and a tuple?",
    "Show me how to use decorators"
]

print("\n🗣️  Having a conversation...")
for question in questions:
    chat_request = AssistantChatRequest(
        text=question,
        stream=False
    )
    response = client.assistants.chat(assistant_id, chat_request)
    print(f"\nQ: {question}")
    print(f"A: {response.generated[:200]}...")  # First 200 chars
```

**✅ Success Criteria:**
- [ ] Successfully sent a chat message to your assistant
- [ ] Received a response from the assistant
- [ ] Response is relevant to your question
- [ ] Can have multiple back-and-forth conversations

**🏆 Bonus:**
- Try streaming mode by setting `stream=True`
- Ask complex questions that require detailed explanations
- Test how well your assistant follows the system prompt you defined

---

## 🎯 Challenge 5: Manage Your Assistant

**Goal:** Learn to list, update, and manage your assistants programmatically

### Instructions

Let's explore assistant management capabilities!

1. **List all your assistants**:
```python
# Get all your assistants
my_assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    page=0,
    per_page=10
)

print("\n📋 Your Assistants:")
for assistant in my_assistants:
    print(f"  - {assistant.name} (ID: {assistant.id})")
```

2. **Update your assistant**:
```python
from codemie_sdk.models.assistant import AssistantUpdateRequest

# Update assistant with new capabilities
update_request = AssistantUpdateRequest(
    name="My Advanced Python Helper",
    description="An expert Python assistant with enhanced capabilities",
    system_prompt="""You are an expert Python programming mentor.
    Provide detailed explanations, best practices, and production-ready code.
    Help users understand not just the 'how' but also the 'why'.""",
    project=full_assistant.project,
    llm_model_type=full_assistant.llm_model_type,
    slug=full_assistant.slug  # Preserve the slug
)

update_response = client.assistants.update(assistant_id, update_request)
print(f"\n✨ Assistant Updated!")

# Get the message from response (may be dict or model)
message = update_response.get('message') if isinstance(update_response, dict) else update_response.message
print(f"  Message: {message}")
```

3. **Get assistant by slug**:
```python
# Retrieve by slug (more human-readable than ID)
assistant_by_slug = client.assistants.get_by_slug("my-python-helper")
print(f"\n🔍 Retrieved by slug: {assistant_by_slug.name}")
print(f"  Description: {assistant_by_slug.description}")
```

**✅ Success Criteria:**
- [ ] Successfully listed all your assistants
- [ ] Updated assistant name and description
- [ ] Retrieved assistant by slug
- [ ] Confirmed changes were applied

**🏆 Bonus:**
- Explore prebuilt assistants: `client.assistants.get_prebuilt()`
- Check available tools: `client.assistants.get_tools()`
- Create a second assistant with different capabilities

---

## 🎯 Challenge 6: Clean Up Resources

**Goal:** Learn to properly delete assistants and clean up resources

### Instructions

It's good practice to clean up resources when you're done experimenting!

1. **Delete your test assistant**:
```python
print("\n" + "="*60)
print("🧹 Cleaning Up Resources")
print("="*60)

# Delete the assistant we created
print(f"\n🗑️  Deleting assistant: {full_assistant.name}")
client.assistants.delete(assistant_id)
print(f"   ✅ Deleted assistant (ID: {assistant_id})")

# Verify it's gone by listing assistants
remaining_assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

deleted = not any(a.id == assistant_id for a in remaining_assistants)
print(f"\n{'✅' if deleted else '❌'} Assistant deletion confirmed: {deleted}")
```

2. **Run the cleanup** and verify your assistant is removed

**✅ Success Criteria:**
- [ ] Assistant successfully deleted
- [ ] Verified assistant no longer appears in list
- [ ] Understood resource cleanup best practices

**💡 Pro Tip:** In production, consider using try/except blocks to handle deletion errors gracefully:

```python
try:
    client.assistants.delete(assistant_id)
    print("✅ Assistant deleted")
except Exception as e:
    print(f"⚠️  Deletion failed: {e}")
```

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered the fundamentals of the CodeMie Python SDK:

✅ **Connected** to CodeMie services with proper authentication
✅ **Explored** available LLM models and capabilities
✅ **Created** your first AI assistant from scratch with a custom slug
✅ **Chatted** with your assistant and got intelligent responses
✅ **Managed** assistants programmatically (list, update, retrieve by slug)
✅ **Cleaned up** resources properly after use

You now have the foundation to:
- Integrate AI assistants into any Python application
- Automate assistant creation and management
- Build conversational AI experiences
- Extend assistants with custom tools and capabilities

### Next Steps

Ready to level up? Try these advanced challenges:

1. **Add Structured Outputs**: Use Pydantic models to get structured responses
   ```python
   from pydantic import BaseModel

   class CodeReview(BaseModel):
       issues: list[str]
       suggestions: list[str]

   # Use in chat request with output_schema=CodeReview
   ```

2. **Integrate Datasources**: Connect code repositories or documentation
   ```python
   from codemie_sdk.models.datasource import CodeDataSourceRequest
   # Create code knowledge base for your assistant
   ```

3. **Build Workflows**: Automate complex multi-step AI processes
   ```python
   workflow = client.workflow.create_workflow(...)
   ```

4. **Add Prompt Variables**: Make your assistant dynamic
   ```python
   from codemie_sdk.models.assistant import PromptVariable
   # Add configurable variables to system prompts
   ```

5. **Explore Versioning**: Manage assistant versions and rollbacks
   ```python
   versions = client.assistant.list_versions(assistant_id)
   ```

### Resources

- **[CodeMie SDK](https://www.npmjs.com/package/codemie-sdk)**: Official SDK package
- **[CodeMie Documentation](https://codemie-ai.github.io/docs/)**: Complete API reference and guides

**Happy coding!** 🚀
