# Integrate Jira with Your AI Assistant Using Python SDK

Welcome to the ultimate integration challenge! In this kata, you'll build an AI assistant that seamlessly connects to your Jira instance, allowing your AI to access, understand, and work with your Jira issues. This is a real-world use case that brings together authentication, integration management, datasource configuration, and AI assistant capabilities.

By the end of this kata, you'll have a fully functional AI assistant that can query your Jira projects and provide intelligent insights about your issues and workflows.

---

## 🎯 Challenge 1: Set Up Your Environment and SDK Client

**Goal:** Install dependencies and establish an authenticated connection to CodeMie services

### Instructions

Let's get your development environment ready for building Jira-integrated AI assistants.

1. **Install the CodeMie Python SDK**:
```bash
pip install codemie-sdk-python
```

2. **Create a configuration file** called `example.properties`:
```properties
codemie_api_domain=https://codemie.lab.epam.com/code-assistant-api
username=firstname_lastname@epam.com
password=your_password
auth_client_id=your_client_id
auth_realm_name=codemie-prod
auth_server_url=https://auth.codemie.lab.epam.com
verify_ssl=false
```

3. **Create your main script** called `jira_assistant.py`:
```python
import os
from configparser import ConfigParser
from codemie_sdk import CodeMieClient

# Load configuration
config = ConfigParser()
config_path = os.path.join(os.path.dirname(__file__), "example.properties")

with open(config_path) as f:
    config.read_string("[example]\n" + f.read())

props = dict(config.items("example"))

# Initialize the CodeMie client
client = CodeMieClient(
    codemie_api_domain=props["codemie_api_domain"],
    username=props["username"],
    password=props["password"],
    auth_client_id=props["auth_client_id"],
    auth_realm_name=props["auth_realm_name"],
    auth_server_url=props["auth_server_url"],
    verify_ssl=False,
)

print("✅ Connected to CodeMie!")
print(f"Token obtained: {client.token[:30]}...")
```

4. **Run your script**:
```bash
python jira_assistant.py
```

**✅ Success Criteria:**
- [ ] SDK installed successfully
- [ ] Configuration file created with credentials
- [ ] Script runs and prints connection confirmation
- [ ] Authentication token is displayed

**💡 Tip:** Keep your credentials secure! Never commit `example.properties` to version control.

---

## 🎯 Challenge 2: Create a Jira Integration

**Goal:** Configure and register a Jira integration with your CodeMie project

### Instructions

Now let's connect your Jira instance to CodeMie. You'll need your Jira credentials ready!

1. **Get your Jira API credentials**:
   - Jira instance URL (e.g., `https://your-company.atlassian.net`)
   - Your Jira email address
   - Generate an API token from [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)

2. **Add integration creation code** to your script:
```python
import uuid
from codemie_sdk.models.integration import (
    Integration,
    CredentialTypes,
    CredentialValues,
    IntegrationType,
)

# Define your project
user_project="user_email@epam.com", # personal user project

# Create Jira integration configuration
jira_integration = Integration(
    project_name=user_project,
    credential_type=CredentialTypes.JIRA,
    credential_values=[
        CredentialValues(
            key="url",
            value="https://your-jira-instance.atlassian.net"
        ),
        CredentialValues(
            key="username",
            value="your-jira-email@example.com"
        ),
        CredentialValues(
            key="token",
            value="your-jira-api-token"
        ),
    ],
    alias=f"Demo Jira Integration {uuid.uuid4()}",
    setting_type=IntegrationType.USER,
)

# Create the integration
client.integrations.create(jira_integration)
print(f"✅ Jira integration created: {jira_integration.alias}")
```

3. **Verify the integration was created**:
```python
from time import sleep

# Wait for integration to be processed
sleep(5)

# Retrieve the integration by alias
integration = client.integrations.get_by_alias(
    jira_integration.alias,
    setting_type=jira_integration.setting_type
)
print(f"📋 Integration ID: {integration.id}")
print(f"📋 Integration Details: {integration}")
```

**✅ Success Criteria:**
- [ ] Jira integration created successfully
- [ ] Integration has a unique alias and ID
- [ ] Can retrieve integration by alias
- [ ] Integration details show your Jira URL

**🏆 Bonus:**
- Explore other credential types available: `CredentialTypes.GIT`, `CredentialTypes.CONFLUENCE`, `CredentialTypes.AZURE_DEVOPS`
- List all integrations: `client.integrations.list()`

**💡 Pro Tip:** The `uuid.uuid4()` in the alias ensures uniqueness when testing multiple times!

---

## 🎯 Challenge 3: Create a Jira Datasource

**Goal:** Configure a Jira datasource that filters issues using JQL (Jira Query Language)

### Instructions

Datasources define what data your AI assistant can access. Let's create one for your Jira issues!

1. **Import datasource models**:
```python
from codemie_sdk.models.datasource import JiraDataSourceRequest, DataSourceType
```

2. **Create a Jira datasource**:
```python
# Define your JQL query
# This example gets issues reported by the current user
jql_query = "reporter = currentUser()"

# Create datasource configuration
datasource_request = JiraDataSourceRequest(
    name="my_jira_issues",
    project_name=user_project,
    description="My personal Jira issues datasource",
    setting_id=integration.id,  # Link to the integration from Challenge 2
    jql=jql_query,
)

# Create the datasource
client.datasources.create(datasource_request)
print(f"✅ Datasource created: {datasource_request.name}")
print(f"📊 JQL Query: {jql_query}")
```

3. **Verify datasource creation**:
```python
# List datasources for your project
datasources = client.datasources.list(
    datasource_types=DataSourceType.JIRA,
    projects=user_project
)

# Find your datasource
my_datasource = next(
    (ds for ds in datasources if ds.name == datasource_request.name),
    None
)

if my_datasource:
    print(f"✅ Datasource verified: {my_datasource.id}")
    print(f"📋 Description: {my_datasource.description}")
```

**✅ Success Criteria:**
- [ ] Datasource created and linked to Jira integration
- [ ] JQL query is configured
- [ ] Can retrieve datasource from the list
- [ ] Datasource has a valid ID

**🏆 Bonus:**
- Try different JQL queries:
  - `"project = MYPROJECT AND status = 'In Progress'"`
  - `"assignee = currentUser() AND status != Done"`
  - `"created >= -7d"` (issues from last 7 days)
- Create multiple datasources for different issue filters

**💡 Pro Tip:** Test your JQL queries in Jira's search interface before using them in your datasource!

---

## 🎯 Challenge 4: Create an AI Assistant with Jira Context

**Goal:** Build an AI assistant that has access to your Jira datasource

### Instructions

Now for the magic - creating an AI assistant that can understand and work with your Jira issues!

1. **Import assistant models**:
```python
from time import sleep
from codemie_sdk.models.assistant import (
    AssistantCreateRequest,
    Context,
    ContextType,
)
```

2. **Get a prebuilt assistant as a template**:
```python
# Get list of prebuilt assistants
prebuilt_assistants = client.assistants.get_prebuilt()

# Use the first prebuilt assistant as a base
prebuilt_assistant = prebuilt_assistants[0]
print(f"📋 Using prebuilt assistant: {prebuilt_assistant.name}")
```

3. **Create your Jira-integrated assistant**:
```python
# Configure assistant with Jira datasource
assistant_name = "My Jira Assistant"
assistant_slug = f"{assistant_name} {uuid.uuid4()}"

assistant_request = AssistantCreateRequest(
    name=assistant_name,
    slug=assistant_slug,
    description="An AI assistant with access to my Jira issues",
    system_prompt="""You are a helpful Jira assistant. You have access to
    Jira issues and can help users understand their projects, track progress,
    and provide insights about issue status and workflows. Always provide
    clear and actionable information.""",
    llm_model_type="gpt-5-2025-08-07",
    project=user_project,
    toolkits=prebuilt_assistant.toolkits,
    temperature=0.7,
    top_p=prebuilt_assistant.top_p,
    # Link the Jira datasource
    context=[
        Context(
            name=datasource_request.name,
            context_type=ContextType.CODE,
        )
    ],
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

assistant = next((a for a in assistants if a.name == assistant_name), None)

if not assistant:
    raise Exception("Could not find newly created assistant")

assistant_id = assistant.id

print(f"  Assistant ID: {assistant_id}")
print(f"  Name: {assistant.name}")

# Get full details
full_assistant = client.assistants.get(assistant_id)
print(f"  Slug: {full_assistant.slug}")
print(f"✅ Assistant verified with {len(full_assistant.context)} context source(s)")
```

**✅ Success Criteria:**
- [ ] Assistant created successfully
- [ ] Assistant is linked to Jira datasource via context
- [ ] Assistant has a custom system prompt
- [ ] Can retrieve assistant by slug

**🏆 Bonus:**
- Customize the system prompt for specific use cases (sprint planning, bug triage, etc.)
- Experiment with different temperature settings for response variability
- Try different LLM models: `gpt-4`, `claude-3-opus`, etc.

---

## 🎯 Challenge 5: Test Your Jira-Integrated Assistant

**Goal:** Chat with your assistant and verify it can access Jira data

### Instructions

Time to put your assistant to the test! Let's see if it can work with your Jira issues.

1. **Add chat functionality**:
```python
from codemie_sdk.models.assistant import AssistantChatRequest

# Prepare a chat request about Jira issues
chat_request = AssistantChatRequest(
    text="What Jira issues am I currently working on?",
    stream=False,
    propagate_headers=False
)

# Chat with your assistant
response = client.assistants.chat(
    assistant_id,
    chat_request
)

print(f"\n💬 Question: {chat_request.text}")
print(f"🤖 Assistant Response:")
print(f"{response.generated}")
```

2. **Try multiple Jira-related questions**:
```python
jira_questions = [
    "How many issues are assigned to me?",
    "What's the status of my recent issues?",
    "Can you summarize the high-priority issues?",
    "Which issues are blocked or need attention?",
]

print("\n🗣️  Testing Jira Knowledge...")
for question in jira_questions:
    chat_request = AssistantChatRequest(
        text=question,
        stream=False
    )
    response = client.assistants.chat(assistant_id, chat_request)
    print(f"\nQ: {question}")
    print(f"A: {response.generated[:300]}...")  # First 300 chars
    print("---")
```

**✅ Success Criteria:**
- [ ] Successfully chatted with the assistant
- [ ] Assistant references Jira issues in responses
- [ ] Responses are relevant and accurate
- [ ] Assistant can answer multiple Jira-related questions

**🏆 Bonus:**
- Enable streaming mode for real-time responses: `stream=True`
- Ask complex queries like "Compare my open issues vs. closed this week"
- Test edge cases like empty results or invalid queries

---

## 🎯 Challenge 6: Clean Up Resources

**Goal:** Properly delete resources when done testing

### Instructions

Good practice: always clean up test resources to avoid clutter!

1. **Delete the assistant**:
```python
# Delete assistant
print(f"\n🗑️  Deleting assistant: {assistant.name}")
client.assistants.delete(assistant_id)
print(f"   ✅ Deleted assistant (ID: {assistant_id})")

# Verify deletion
remaining_assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

deleted_assistant = not any(a.id == assistant_id for a in remaining_assistants)
print(f"{'✅' if deleted_assistant else '❌'} Assistant deletion confirmed: {deleted_assistant}")
```

2. **Delete the datasource**:
```python
# Find datasource by name and delete
datasources = client.datasources.list(
    datasource_types=DataSourceType.JIRA,
    projects=user_project
)
datasource = next(
    (ds for ds in datasources if ds.name == datasource_request.name),
    None
)

if datasource:
    print(f"\n🗑️  Deleting datasource: {datasource.name}")
    client.datasources.delete(datasource.id)
    print(f"   ✅ Deleted datasource (ID: {datasource.id})")
```

3. **Delete the integration**:
```python
# Delete integration
print(f"\n🗑️  Deleting integration: {integration.id}")
client.integrations.delete(integration.id, integration.setting_type)
print(f"   ✅ Deleted integration")
```

**✅ Success Criteria:**
- [ ] Assistant deleted successfully
- [ ] Datasource deleted successfully
- [ ] Integration deleted successfully
- [ ] No orphaned resources remain

**💡 Pro Tip:** In production, you typically keep assistants and datasources running. Only delete during testing/development!

---

## 🎯 Challenge 7: Chat with Pydantic Output Schema

**Goal:** Structure assistant responses using Pydantic models for type-safe, validated outputs

### Instructions

Output schemas allow you to enforce structured responses from your AI assistant. Pydantic schemas provide automatic validation and type checking!

1. **Import Pydantic BaseModel**:
```python
from pydantic import BaseModel
```

2. **Define a simple Pydantic schema for Jira issue summary**:
```python
# Simple schema - list of issue keys
class IssueKeysSchema(BaseModel):
    issue_keys: list[str]

# Ask assistant to list issues in structured format
chat_request = AssistantChatRequest(
    text="List all Jira issue keys from my datasource",
    stream=False,
    output_schema=IssueKeysSchema  # Pass the Pydantic class
)

response = client.assistants.chat(assistant.id, chat_request)

# Response is now structured according to schema
print(f"📋 Issue Keys: {response.issue_keys}")
for key in response.issue_keys:
    print(f"  - {key}")
```

3. **Define a nested Pydantic schema for detailed issue information**:
```python
# Nested schema with complex structure
class JiraUser(BaseModel):
    name: str
    email: str | None = None

class JiraIssue(BaseModel):
    key: str
    summary: str
    status: str
    priority: str
    assignee: JiraUser | None = None

class JiraIssuesResponse(BaseModel):
    total_count: int
    issues: list[JiraIssue]

# Ask for detailed structured information
chat_request = AssistantChatRequest(
    text="Provide detailed information about my Jira issues including assignee details",
    stream=False,
    output_schema=JiraIssuesResponse
)

response = client.assistants.chat(assistant.id, chat_request)

print(f"\n📊 Total Issues: {response.total_count}")
for issue in response.issues:
    print(f"\n🎫 {issue.key}: {issue.summary}")
    print(f"   Status: {issue.status}")
    print(f"   Priority: {issue.priority}")
    if issue.assignee:
        print(f"   Assignee: {issue.assignee.name}")
```

**✅ Success Criteria:**
- [ ] Simple Pydantic schema returns structured list
- [ ] Nested Pydantic schema with complex objects works
- [ ] Response fields are automatically validated
- [ ] Can access response attributes directly (e.g., `response.issue_keys`)

**🏆 Bonus:**
- Add field validators using Pydantic's `@validator` decorator
- Try optional fields with default values
- Experiment with `Field()` for descriptions and constraints

**💡 Pro Tip:** Pydantic schemas provide automatic type checking and validation - invalid responses will raise errors before you access the data!

---

## 🎯 Challenge 8: Chat with JSON Schema

**Goal:** Use JSON Schema for flexible, dictionary-based structured outputs

### Instructions

JSON schemas provide a standard way to define data structures without Pydantic dependencies. Perfect for dynamic schemas!

1. **Define a simple JSON schema for issue statistics**:
```python
# Simple JSON schema
simple_schema = {
    "type": "object",
    "properties": {
        "open_count": {
            "type": "integer",
            "description": "Number of open issues"
        },
        "in_progress_count": {
            "type": "integer",
            "description": "Number of in-progress issues"
        },
        "done_count": {
            "type": "integer",
            "description": "Number of completed issues"
        }
    },
    "required": ["open_count", "in_progress_count", "done_count"]
}

# Use JSON schema in chat request
chat_request = AssistantChatRequest(
    text="Analyze my Jira issues and provide counts by status",
    stream=False,
    output_schema=simple_schema  # Pass the dictionary
)

response = client.assistants.chat(assistant.id, chat_request)

# Response is a dictionary matching the schema
print("\n📈 Issue Statistics:")
print(f"  Open: {response['open_count']}")
print(f"  In Progress: {response['in_progress_count']}")
print(f"  Done: {response['done_count']}")
total = response['open_count'] + response['in_progress_count'] + response['done_count']
print(f"  Total: {total}")
```

2. **Define a nested JSON schema with complex objects**:
```python
# Nested JSON schema with arrays and objects
nested_schema = {
    "type": "object",
    "properties": {
        "summary": {
            "type": "object",
            "properties": {
                "total_issues": {"type": "integer"},
                "report_date": {"type": "string"},
                "project_name": {"type": "string"}
            },
            "required": ["total_issues", "report_date"]
        },
        "issues_by_priority": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "priority": {"type": "string"},
                    "count": {"type": "integer"},
                    "issues": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "key": {"type": "string"},
                                "title": {"type": "string"}
                            },
                            "required": ["key", "title"]
                        }
                    }
                },
                "required": ["priority", "count", "issues"]
            }
        }
    },
    "required": ["summary", "issues_by_priority"]
}

# Request detailed report with nested structure
chat_request = AssistantChatRequest(
    text="Generate a comprehensive Jira report grouped by priority with issue details",
    stream=False,
    output_schema=nested_schema
)

response = client.assistants.chat(assistant.id, chat_request)

# Access nested dictionary structure
print(f"\n📋 Jira Report")
print(f"Date: {response['summary']['report_date']}")
print(f"Total Issues: {response['summary']['total_issues']}")

print("\n📊 Issues by Priority:")
for priority_group in response['issues_by_priority']:
    print(f"\n🔥 {priority_group['priority']}: {priority_group['count']} issues")
    for issue in priority_group['issues']:
        print(f"   - {issue['key']}: {issue['title']}")
```

**✅ Success Criteria:**
- [ ] Simple JSON schema returns valid dictionary
- [ ] Nested JSON schema with arrays and objects works
- [ ] Response matches defined schema structure
- [ ] Can access nested values using dictionary keys

**🏆 Bonus:**
- Add JSON schema constraints (minimum, maximum, pattern)
- Use `additionalProperties: false` to strictly enforce schema
- Try `enum` for fixed value lists
- Combine multiple schemas with `$ref` or `allOf`

**💡 Pro Tip:** JSON schemas are more flexible than Pydantic but require manual validation. Use them when you need dynamic schemas or interoperability with other systems!

**🔍 Key Differences:**
- **Pydantic**: Type-safe, validated objects with attribute access (`response.field`)
- **JSON Schema**: Flexible dictionaries with key access (`response['field']`)
- **Pydantic**: Better for Python-centric workflows
- **JSON Schema**: Better for language-agnostic APIs

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered Jira integration with CodeMie AI assistants:

✅ **Set up** CodeMie SDK with proper authentication
✅ **Created** a Jira integration with API credentials
✅ **Configured** a Jira datasource with custom JQL queries
✅ **Built** an AI assistant with Jira context
✅ **Tested** the assistant's ability to access and understand Jira data
✅ **Structured responses** with Pydantic schemas for type-safe outputs
✅ **Implemented** JSON schemas for flexible data structures
✅ **Cleaned up** resources following best practices

You now know how to:
- Integrate external services (Jira, Confluence, GitHub, etc.)
- Configure datasources for AI assistants
- Link context to enable AI access to external data
- Build domain-specific AI assistants
- Structure AI responses with Pydantic models and JSON schemas
- Choose between type-safe (Pydantic) and flexible (JSON) schema approaches
- Manage integration lifecycle

### Real-World Applications

This pattern enables powerful use cases:

**Project Management:**
- Sprint planning assistants that analyze velocity and capacity
- Issue triage bots that prioritize and categorize tickets
- Standup assistants that summarize team progress

**Engineering Workflow:**
- Code review assistants that link PRs to Jira issues
- Bug triage bots that find similar issues and suggest fixes
- Release assistants that track features and blockers

**Business Intelligence:**
- Analytics assistants that generate reports from Jira data
- Forecasting bots that predict delivery timelines
- Dashboard assistants that answer adhoc queries

### Next Steps

Ready for more advanced integrations? Try these:

1. **Multi-Datasource Assistants**: Combine Jira, GitHub, and Confluence
   ```python
   context=[
       Context(name="jira_issues", context_type=ContextType.CODE),
       Context(name="github_prs", context_type=ContextType.CODE),
       Context(name="confluence_docs", context_type=ContextType.CODE),
   ]
   ```

2. **Custom JQL Workflows**: Build assistants for specific projects or teams
   ```python
   jql="project = MYTEAM AND sprint in openSprints()"
   ```

3. **Integration Webhooks**: React to Jira events in real-time
   - Configure Jira webhooks to trigger assistant actions
   - Build automated workflows based on issue state changes

4. **Advanced Context Management**: Dynamic datasource switching
   ```python
   # Switch datasources based on user requests
   datasources = ["current_sprint", "backlog", "blocked_issues"]
   ```

5. **Build Custom Tools**: Add Jira actions to your assistant
   - Create issues
   - Update status
   - Add comments
   - Assign users

6. **Advanced Output Schemas**: Build sophisticated data pipelines
   ```python
   # Combine output schemas with streaming for real-time structured data
   chat_request = AssistantChatRequest(
       text="Analyze sprint velocity and predict completion",
       stream=True,
       output_schema=SprintAnalysisSchema
   )
   ```
   - Create reusable schema libraries for your organization
   - Use schemas to validate and transform AI outputs
   - Build data pipelines with guaranteed structure

### Resources

- **[CodeMie SDK](https://www.npmjs.com/package/codemie-sdk)**: Official SDK package
- **[CodeMie Documentation](https://codemie-ai.github.io/docs/)**: Complete API reference and guides

**Happy integrating!** 🚀
