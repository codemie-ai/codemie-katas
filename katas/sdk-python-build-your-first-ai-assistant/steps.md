# Build Your First AI Assistant with Python SDK

Welcome to your journey of building AI assistants with CodeMie Python SDK! In this hands-on challenge, you'll go from zero to hero by creating, configuring, and chatting with your own AI assistant—all through Python code.

By the end of this kata, you'll have a working Python application that creates intelligent AI assistants and manages conversations, giving you the foundation to integrate AI capabilities into any Python project.

---

## 🎯 Challenge 1: Connect to CodeMie (5 min)

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
print(f"Token obtained: {client.token[:20]}...")
```

3. **Get your credentials**: Contact the CodeMie team (vadym_vlasenko@epam.com) or use your existing credentials

4. **Run your script**:
```bash
python my_assistant.py
```

**✅ Success Criteria:**
- [ ] SDK installed without errors
- [ ] Script runs and prints "Connected to CodeMie!"
- [ ] Token is displayed (first 20 characters)

**💡 Tip:** If you're getting authentication errors, double-check your credentials and ensure your realm name is correct.

---

## 🎯 Challenge 2: Explore Available LLM Models (5 min)

**Goal:** Discover what AI models are available and choose one for your assistant

### Instructions

Before creating an assistant, let's see what powerful AI models you can use!

1. **Add model listing code** to your `my_assistant.py`:
```python
# List available LLM models
llm_models = client.llm.list(token=client.token)

print("\n🤖 Available LLM Models:")
for model in llm_models[:5]:  # Show first 5 models
    print(f"  - {model.get('id', 'N/A')}: {model.get('name', 'N/A')}")

# List embedding models
embedding_models = client.llm.list_embeddings(token=client.token)

print("\n📊 Available Embedding Models:")
for model in embedding_models[:3]:  # Show first 3
    print(f"  - {model.get('id', 'N/A')}")
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

## 🎯 Challenge 3: Create Your First AI Assistant (7 min)

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
    project="my_first_project",
    llm_model_type="gpt-4o",  # Use model from Challenge 2
    context=[],
    conversation_starters=[
        "How do I read a CSV file in Python?",
        "Explain list comprehensions",
        "Help me debug my code"
    ],
    mcp_servers=[],
    assistant_ids=[]
)

# Create the assistant
new_assistant = client.assistant.create(assistant_request)

print(f"\n🎉 Assistant Created!")
print(f"  ID: {new_assistant.id}")
print(f"  Name: {new_assistant.name}")
print(f"  Slug: {new_assistant.slug}")

# Save the assistant ID for later use
assistant_id = new_assistant.id
```

3. **Run your script** and watch your assistant come to life!

**✅ Success Criteria:**
- [ ] Assistant created successfully
- [ ] Assistant ID is displayed
- [ ] Assistant has a name and description
- [ ] Conversation starters are configured

**🏆 Bonus:**
- Customize the system prompt to create an assistant for your domain (DevOps, Data Science, etc.)
- Add more conversation starters
- Experiment with different model types

**💡 Pro Tip:** Save your assistant ID in a variable - you'll need it for the next challenge!

---

## 🎯 Challenge 4: Chat with Your Assistant (5 min)

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
response = client.assistant.chat(
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
    response = client.assistant.chat(assistant_id, chat_request)
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

## 🎯 Challenge 5: Manage Your Assistant (3 min)

**Goal:** Learn to list, update, and manage your assistants programmatically

### Instructions

Let's explore assistant management capabilities!

1. **List all your assistants**:
```python
# Get all your assistants
my_assistants = client.assistant.list(
    minimal_response=True,
    scope="created_by_user",
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
    Help users understand not just the 'how' but also the 'why'."""
)

updated_assistant = client.assistant.update(assistant_id, update_request)
print(f"\n✨ Assistant Updated!")
print(f"  New Name: {updated_assistant.name}")
```

3. **Get assistant by slug**:
```python
# Retrieve by slug (more human-readable than ID)
assistant_by_slug = client.assistant.get_by_slug(new_assistant.slug)
print(f"\n🔍 Retrieved by slug: {assistant_by_slug.name}")
```

**✅ Success Criteria:**
- [ ] Successfully listed all your assistants
- [ ] Updated assistant name and description
- [ ] Retrieved assistant by slug
- [ ] Confirmed changes were applied

**🏆 Bonus:**
- Explore prebuilt assistants: `client.assistant.get_prebuilt()`
- Check available tools: `client.assistant.get_tools()`
- Create a second assistant with different capabilities

---

## 🎯 Challenge 6: Use Structured Outputs with Output Schemas (10 min)

**Goal:** Get predictable, structured responses from your assistant using Pydantic or JSON schemas

### Instructions

So far, your assistant returns free-form text responses. But what if you need structured data you can parse and use programmatically? That's where output schemas come in! CodeMie supports **two types of schemas**: **Pydantic models** and **JSON Schema**, giving you flexibility based on your needs.

### Option A: Using Pydantic Models

Pydantic provides a Pythonic, type-safe way to define schemas with validation.

1. **Install Pydantic** (if not already installed):
```bash
pip install pydantic
```

2. **Define your output schema** using Pydantic models:
```python
from pydantic import BaseModel, Field
from typing import List

# Define the structure you want the assistant to return
class CodeReview(BaseModel):
    """Structured code review response"""
    summary: str = Field(description="Brief summary of the code quality")
    issues: List[str] = Field(description="List of identified issues")
    suggestions: List[str] = Field(description="List of improvement suggestions")
    rating: int = Field(description="Code quality rating from 1-10", ge=1, le=10)
```

3. **Use the schema in your chat request**:
```python
from codemie_sdk.models.assistant import AssistantChatRequest

# Sample Python code to review
code_to_review = """
def calculate_sum(numbers):
    total = 0
    for i in range(len(numbers)):
        total = total + numbers[i]
    return total
"""

# Create chat request with output schema
chat_request = AssistantChatRequest(
    text=f"Review this Python code and provide feedback:\n\n{code_to_review}",
    stream=False,
    output_schema=CodeReview  # Pass the Pydantic model here
)

# Chat with your assistant
response = client.assistant.chat(assistant_id, chat_request)

# The response is now structured according to your schema!
review = response.generated_parsed  # Returns a CodeReview instance

print(f"\n📊 Structured Code Review:")
print(f"Summary: {review.summary}")
print(f"Rating: {review.rating}/10")
print(f"\n⚠️  Issues Found ({len(review.issues)}):")
for issue in review.issues:
    print(f"  - {issue}")
print(f"\n💡 Suggestions ({len(review.suggestions)}):")
for suggestion in review.suggestions:
    print(f"  - {suggestion}")
```

4. **Try different Pydantic schema structures**:
```python
# Example: Structured data extraction
class ContactInfo(BaseModel):
    name: str
    email: str
    phone: str | None = None
    role: str

# Example: Meeting summary
class MeetingSummary(BaseModel):
    topic: str
    key_points: List[str]
    action_items: List[str]
    next_meeting: str | None = None

# Example: Bug report
class BugReport(BaseModel):
    severity: str  # "low", "medium", "high", "critical"
    category: str
    description: str
    reproduction_steps: List[str]
    suggested_fix: str | None = None

# Use any of these schemas with your assistant
chat_request = AssistantChatRequest(
    text="Summarize the following meeting transcript: ...",
    stream=False,
    output_schema=MeetingSummary
)
```

---

### Option B: Using JSON Schema

JSON Schema provides a standard, language-agnostic way to define data structures. Great for when you don't want to add Pydantic as a dependency or need dynamic schemas.

1. **Define your schema as a dictionary**:
```python
# Code review schema as JSON Schema
code_review_schema = {
    "type": "object",
    "properties": {
        "summary": {
            "type": "string",
            "description": "Brief summary of the code quality"
        },
        "issues": {
            "type": "array",
            "items": {"type": "string"},
            "description": "List of identified issues"
        },
        "suggestions": {
            "type": "array",
            "items": {"type": "string"},
            "description": "List of improvement suggestions"
        },
        "rating": {
            "type": "integer",
            "description": "Code quality rating from 1-10",
            "minimum": 1,
            "maximum": 10
        }
    },
    "required": ["summary", "issues", "suggestions", "rating"],
    "additionalProperties": False
}
```

2. **Use the JSON schema in your chat request**:
```python
from codemie_sdk.models.assistant import AssistantChatRequest

# Sample Python code to review
code_to_review = """
def calculate_sum(numbers):
    total = 0
    for i in range(len(numbers)):
        total = total + numbers[i]
    return total
"""

# Create chat request with JSON schema
chat_request = AssistantChatRequest(
    text=f"Review this Python code and provide feedback:\n\n{code_to_review}",
    stream=False,
    output_schema=code_review_schema  # Pass the JSON schema dict
)

# Chat with your assistant
response = client.assistant.chat(assistant_id, chat_request)

# The response is structured JSON
review = response.generated_parsed  # Returns a dict

print(f"\n📊 Structured Code Review:")
print(f"Summary: {review['summary']}")
print(f"Rating: {review['rating']}/10")
print(f"\n⚠️  Issues Found ({len(review['issues'])}):")
for issue in review['issues']:
    print(f"  - {issue}")
print(f"\n💡 Suggestions ({len(review['suggestions'])}):")
for suggestion in review['suggestions']:
    print(f"  - {suggestion}")
```

3. **More JSON Schema examples**:
```python
# Example: Contact information extraction
contact_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "email": {"type": "string", "format": "email"},
        "phone": {"type": "string"},
        "role": {"type": "string"}
    },
    "required": ["name", "email", "role"]
}

# Example: Meeting summary with nested objects
meeting_schema = {
    "type": "object",
    "properties": {
        "topic": {"type": "string"},
        "date": {"type": "string", "format": "date"},
        "participants": {
            "type": "array",
            "items": {"type": "string"}
        },
        "key_points": {
            "type": "array",
            "items": {"type": "string"}
        },
        "action_items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "task": {"type": "string"},
                    "assignee": {"type": "string"},
                    "due_date": {"type": "string"}
                }
            }
        }
    },
    "required": ["topic", "key_points", "action_items"]
}

# Example: Sentiment analysis with enum
sentiment_schema = {
    "type": "object",
    "properties": {
        "sentiment": {
            "type": "string",
            "enum": ["positive", "negative", "neutral", "mixed"]
        },
        "confidence": {
            "type": "number",
            "minimum": 0.0,
            "maximum": 1.0
        },
        "key_phrases": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["sentiment", "confidence"]
}
```

---

### Which Schema Type Should You Use?

**Choose Pydantic when:**
- ✅ You want type safety and IDE autocomplete
- ✅ You need data validation and parsing
- ✅ You prefer Pythonic class-based definitions
- ✅ You're already using Pydantic in your project

**Choose JSON Schema when:**
- ✅ You want to avoid extra dependencies
- ✅ You need dynamic, runtime-generated schemas
- ✅ You're integrating with non-Python systems
- ✅ You prefer standard JSON Schema specification

**✅ Success Criteria:**
- [ ] Successfully defined an output schema (Pydantic OR JSON Schema)
- [ ] Used `output_schema` parameter in chat request
- [ ] Received structured response in `response.generated_parsed`
- [ ] Accessed structured fields programmatically (e.g., `review.issues` or `review['issues']`)
- [ ] Response conforms to your defined schema
- [ ] Understand the differences between Pydantic and JSON Schema approaches

**🏆 Bonus:**
- Try BOTH Pydantic and JSON Schema approaches with the same data structure
- Create a complex nested schema with objects and arrays
- Use constraints (minimum, maximum, enum) to guide valid AI responses
- Build a data processing pipeline that uses structured outputs
- Combine multiple schemas for different types of queries (code review, data extraction, analysis)

**💡 Pro Tips:**
- **For both schema types:** Use descriptive field names and descriptions - they help guide the AI
- **For Pydantic:** Use Field descriptions and validators (ge, le, min_length) for data validation
- **For JSON Schema:** Use standard JSON Schema keywords (type, format, minimum, maximum, enum)
- **Access patterns:** Pydantic returns objects (`review.issues`), JSON Schema returns dicts (`review['issues']`)
- The AI will automatically validate and structure its output against your schema
- Structured outputs are perfect for: data extraction, classification, analysis, report generation, and API integration

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered the fundamentals of the CodeMie Python SDK:

✅ **Connected** to CodeMie services with proper authentication
✅ **Explored** available LLM models and capabilities
✅ **Created** your first AI assistant from scratch
✅ **Chatted** with your assistant and got intelligent responses
✅ **Managed** assistants programmatically (list, update, retrieve)
✅ **Implemented** structured outputs using Pydantic schemas for predictable responses

You now have the foundation to:
- Integrate AI assistants into any Python application
- Automate assistant creation and management
- Build conversational AI experiences with structured data
- Extract and process information programmatically from AI responses
- Extend assistants with custom tools and capabilities

### Next Steps

Ready to level up? Try these advanced challenges:

1. **Integrate Datasources**: Connect code repositories or documentation
   ```python
   from codemie_sdk.models.datasource import CodeDataSourceRequest
   # Create code knowledge base for your assistant
   ```

2. **Build Workflows**: Automate complex multi-step AI processes
   ```python
   workflow = client.workflow.create_workflow(...)
   ```

3. **Add Prompt Variables**: Make your assistant dynamic
   ```python
   from codemie_sdk.models.assistant import PromptVariable
   # Add configurable variables to system prompts
   ```

4. **Explore Versioning**: Manage assistant versions and rollbacks
   ```python
   versions = client.assistant.list_versions(assistant_id)
   ```

5. **Build Complex Nested Schemas**: Create sophisticated data structures
   ```python
   # Pydantic nested models
   class AnalysisResult(BaseModel):
       findings: List[Finding]  # Nested model
       confidence: float
       metadata: Dict[str, Any]

   # Or JSON Schema with nested objects
   nested_schema = {
       "type": "object",
       "properties": {
           "findings": {
               "type": "array",
               "items": {
                   "type": "object",
                   "properties": {
                       "severity": {"type": "string"},
                       "description": {"type": "string"}
                   }
               }
           },
           "confidence": {"type": "number"}
       }
   }
   ```

### Resources

- **[CodeMie SDK](https://www.npmjs.com/package/codemie-sdk)**: Official SDK package
- **[CodeMie Documentation](https://codemie-ai.github.io/docs/)**: Complete API reference and guides

**Happy coding!** 🚀
