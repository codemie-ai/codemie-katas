# Build an FAQ Assistant with Sub-Assistants

Welcome to the world of hierarchical AI agents with integrated knowledge sources! In this kata, you'll learn how to create an intelligent FAQ system where a main coordinator assistant automatically delegates questions to specialized sub-assistants, each connected to different datasources. This powerful pattern enables you to build sophisticated multi-agent systems that route queries to the right expert with access to relevant data.

By the end of this kata, you'll have a working FAQ assistant that intelligently routes Jira questions, Confluence documentation queries, and Google Docs questions to specialized sub-assistants—all through automatic delegation with datasource integration!

---

## 🎯 Challenge 1: Set Up Your Environment and SDK Client

**Goal:** Install dependencies and establish an authenticated connection to CodeMie services

### Instructions

Let's get your development environment ready for building hierarchical assistants with datasources.

1. **Install required dependencies**:

Create a `requirements.txt` file:
```txt
codemie-sdk-python
```

Then install the dependencies:
```bash
pip install -r requirements.txt
```

2. **Create a configuration file** called `example.properties`:
```properties
codemie_api_domain=https://codemie.lab.epam.com/code-assistant-api
username=firstname_lastname@epam.com
password=your_password
auth_client_id=your_client_id
auth_realm_name=codemie-prod
auth_server_url=https://keycloak.eks-core.aws.main.edp.projects.epam.com/auth
verify_ssl=false
project=default
```

3. **Create your main script** called `faq_assistant.py`:
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

# Get LLM model for assistants
models = client.llms.list()
default_model = models[0].base_name
print(f"Using model: {default_model}")

# Get project
user_project = props.get("project", "default")
```

4. **Run your script**:
```bash
python faq_assistant.py
```

**✅ Success Criteria:**
- [ ] Dependencies installed successfully from requirements.txt
- [ ] Configuration file created with your credentials
- [ ] Script runs and prints connection confirmation
- [ ] Authentication token and model name are displayed

**💡 Tip:** Keep your credentials secure! Never commit `example.properties` to version control. Add it to `.gitignore`.

---

## 🎯 Challenge 2: Create Integrations for External Systems

**Goal:** Set up integrations to Jira and Confluence for knowledge access

### Instructions

Before we can attach datasources to assistants, we need to create integrations to external systems. Let's connect Jira and Confluence!

1. **Import integration models**:
```python
import uuid
from time import sleep
from codemie_sdk.models.integration import (
    Integration,
    CredentialTypes,
    CredentialValues,
    IntegrationType,
)
```

2. **Create Jira integration**:
```python
# Get your Jira credentials:
# - Jira URL: https://your-company.atlassian.net
# - Email: your-jira-email@example.com
# - API Token: from https://id.atlassian.com/manage-profile/security/api-tokens

jira_integration = Integration(
    project_name=user_project,
    credential_type=CredentialTypes.JIRA,
    credential_values=[
        CredentialValues(key="url", value="https://your-jira.atlassian.net"),
        CredentialValues(key="username", value="your-email@example.com"),
        CredentialValues(key="token", value="your-jira-api-token"),
    ],
    alias=f"FAQ Jira Integration {uuid.uuid4()}",
    setting_type=IntegrationType.USER,
)

client.integrations.create(jira_integration)
print(f"✅ Jira integration created: {jira_integration.alias}")

# Wait and retrieve
sleep(5)
jira_integration_obj = client.integrations.get_by_alias(
    jira_integration.alias,
    setting_type=jira_integration.setting_type
)
print(f"   Integration ID: {jira_integration_obj.id}")
```

3. **Create Confluence integration**:
```python
# Get your Confluence credentials (similar to Jira)
confluence_integration = Integration(
    project_name=user_project,
    credential_type=CredentialTypes.CONFLUENCE,
    credential_values=[
        CredentialValues(key="url", value="https://your-confluence.atlassian.net"),
        CredentialValues(key="username", value="your-email@example.com"),
        CredentialValues(key="token", value="your-confluence-api-token"),
    ],
    alias=f"FAQ Confluence Integration {uuid.uuid4()}",
    setting_type=IntegrationType.USER,
)

client.integrations.create(confluence_integration)
print(f"✅ Confluence integration created: {confluence_integration.alias}")

# Wait and retrieve
sleep(5)
confluence_integration_obj = client.integrations.get_by_alias(
    confluence_integration.alias,
    setting_type=confluence_integration.setting_type
)
print(f"   Integration ID: {confluence_integration_obj.id}")
```

**✅ Success Criteria:**
- [ ] Jira integration created successfully
- [ ] Confluence integration created successfully
- [ ] Both integrations have unique IDs
- [ ] Can retrieve integrations by alias

**💡 Tip:** You'll need actual Jira and Confluence credentials. If you don't have them, use test instances or skip to understanding the pattern.

**🏆 Bonus:** Explore other integration types: `CredentialTypes.GIT`, `CredentialTypes.AZURE_DEVOPS`, `CredentialTypes.GOOGLE_DRIVE`

---

## 🎯 Challenge 3: Create Datasources for Each Knowledge Area

**Goal:** Configure datasources that define what data each assistant can access

### Instructions

Now let's create datasources for Jira issues, Confluence pages, and Google Docs. Each will be connected to a different sub-assistant.

1. **Import datasource models**:
```python
from codemie_sdk.models.datasource import (
    JiraDataSourceRequest,
    ConfluenceDataSourceRequest,
    GoogleDocDataSourceRequest,
    DataSourceType,
)
from codemie_sdk.models.assistant import Context, ContextType
```

2. **Create Jira datasource**:
```python
# Define JQL query for Jira issues
jira_datasource_request = JiraDataSourceRequest(
    name="jira_issues_datasource",
    project_name=user_project,
    description="Jira issues for FAQ - all current sprint issues",
    setting_id=jira_integration_obj.id,
    jql="project = YOUR_PROJECT AND sprint in openSprints()",
)

client.datasources.create(jira_datasource_request)
print(f"✅ Jira datasource created: {jira_datasource_request.name}")

# Wait and verify
sleep(3)
jira_datasources = client.datasources.list(
    datasource_types=DataSourceType.JIRA,
    projects=user_project
)
jira_datasource = next(
    (ds for ds in jira_datasources if ds.name == jira_datasource_request.name),
    None
)
print(f"   Datasource ID: {jira_datasource.id}")
```

3. **Create Confluence datasource**:
```python
# Define Confluence space and query
confluence_datasource_request = ConfluenceDataSourceRequest(
    name="confluence_docs_datasource",
    project_name=user_project,
    description="Confluence documentation pages for FAQ",
    setting_id=confluence_integration_obj.id,
    space_key="YOUR_SPACE_KEY",  # e.g., "DOCS" or "TEAM"
    cql="type=page AND space=YOUR_SPACE_KEY",
)

client.datasources.create(confluence_datasource_request)
print(f"✅ Confluence datasource created: {confluence_datasource_request.name}")

# Wait and verify
sleep(3)
confluence_datasources = client.datasources.list(
    datasource_types=DataSourceType.CONFLUENCE,
    projects=user_project
)
confluence_datasource = next(
    (ds for ds in confluence_datasources if ds.name == confluence_datasource_request.name),
    None
)
print(f"   Datasource ID: {confluence_datasource.id}")
```

4. **Create Google Docs datasource**:
```python
# Google Docs doesn't require integration - just provide the URL
google_doc_url = "https://docs.google.com/document/d/YOUR_DOC_ID/edit"

google_doc_datasource_request = GoogleDocDataSourceRequest(
    name="google_docs_datasource",
    project_name=user_project,
    description="Google Docs for FAQ content",
    google_doc=google_doc_url,
)

client.datasources.create(google_doc_datasource_request)
print(f"✅ Google Docs datasource created: {google_doc_datasource_request.name}")

# Wait and verify
sleep(3)
google_datasources = client.datasources.list(
    datasource_types=DataSourceType.GOOGLE_DOC,
    projects=user_project
)
google_doc_datasource = next(
    (ds for ds in google_datasources if ds.name == google_doc_datasource_request.name),
    None
)
print(f"   Datasource ID: {google_doc_datasource.id}")
```

**✅ Success Criteria:**
- [ ] Jira datasource created and linked to integration
- [ ] Confluence datasource created and linked to integration
- [ ] Google Docs datasource created (no integration needed)
- [ ] All three datasources have valid IDs

**💡 Tip:** JQL (Jira Query Language) and CQL (Confluence Query Language) let you filter exactly what data your assistants can access.

**🏆 Bonus:** Experiment with different JQL/CQL queries to narrow down the data scope for each assistant.

---

## 🎯 Challenge 4: Create Specialized Sub-Assistants with Datasources

**Goal:** Build three expert sub-assistants, each connected to a specific datasource

### Instructions

Now let's create the sub-assistants and attach datasources via Context. The description field is crucial for delegation!

1. **Create Jira Issues Expert**:
```python
from codemie_sdk.models.assistant import AssistantCreateRequest

# Create context for Jira datasource
jira_context = Context(
    name=jira_datasource.name,
    context_type=ContextType.KNOWLEDGE_BASE
)

# Sub-Assistant 1: Jira Issues Expert
jira_expert_request = AssistantCreateRequest(
    name="Jira Issues Expert",
    description="Expert in Jira issues, sprint planning, and project tracking. Answers questions about current issues, sprint status, task assignments, and project progress from Jira.",
    system_prompt="""You are a Jira Issues Expert assistant with access to Jira data.

Your expertise:
- Answering questions about current sprint issues
- Providing status updates on tasks and assignments
- Explaining project progress and blockers
- Helping with issue tracking and management

Use the Jira datasource to provide accurate, up-to-date information about issues.""",
    toolkits=[],
    project=user_project,
    llm_model_type=default_model,
    context=[jira_context],  # Attach Jira datasource!
    conversation_starters=[],
    mcp_servers=[],
    assistant_ids=[]
)

jira_expert_response = client.assistants.create(jira_expert_request)
print(f"✅ Created Jira Issues Expert with datasource")
```

2. **Create Confluence Documentation Expert**:
```python
# Create context for Confluence datasource
confluence_context = Context(
    name=confluence_datasource.name,
    context_type=ContextType.KNOWLEDGE_BASE
)

# Sub-Assistant 2: Confluence Documentation Expert
confluence_expert_request = AssistantCreateRequest(
    name="Confluence Documentation Expert",
    description="Expert in technical documentation, guides, and knowledge base articles from Confluence. Answers questions about product documentation, how-to guides, best practices, and team knowledge.",
    system_prompt="""You are a Confluence Documentation Expert assistant with access to Confluence pages.

Your expertise:
- Providing information from technical documentation
- Answering questions about processes and best practices
- Explaining concepts from knowledge base articles
- Guiding users to relevant documentation

Use the Confluence datasource to provide accurate documentation-based answers.""",
    toolkits=[],
    project=user_project,
    llm_model_type=default_model,
    context=[confluence_context],  # Attach Confluence datasource!
    conversation_starters=[],
    mcp_servers=[],
    assistant_ids=[]
)

confluence_expert_response = client.assistants.create(confluence_expert_request)
print(f"✅ Created Confluence Documentation Expert with datasource")
```

3. **Create Google Docs Content Expert**:
```python
# Create context for Google Docs datasource
google_doc_context = Context(
    name=google_doc_datasource.name,
    context_type=ContextType.KNOWLEDGE_BASE
)

# Sub-Assistant 3: Google Docs Content Expert
google_docs_expert_request = AssistantCreateRequest(
    name="Google Docs Content Expert",
    description="Expert in policies, procedures, and reference content from Google Docs. Answers questions about company policies, guidelines, reference materials, and documented procedures.",
    system_prompt="""You are a Google Docs Content Expert assistant with access to Google Docs content.

Your expertise:
- Answering questions about policies and procedures
- Providing information from reference documents
- Explaining guidelines and standards
- Helping with documented processes

Use the Google Docs datasource to provide accurate information from official documents.""",
    toolkits=[],
    project=user_project,
    llm_model_type=default_model,
    context=[google_doc_context],  # Attach Google Docs datasource!
    conversation_starters=[],
    mcp_servers=[],
    assistant_ids=[]
)

google_docs_expert_response = client.assistants.create(google_docs_expert_request)
print(f"✅ Created Google Docs Content Expert with datasource")
```

4. **Wait and retrieve the sub-assistants**:
```python
# Wait for assistants to be fully created
sleep(5)

# Retrieve all assistants
assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

# Find our sub-assistants by name
jira_assistant = next((a for a in assistants if a.name == "Jira Issues Expert"), None)
confluence_assistant = next((a for a in assistants if a.name == "Confluence Documentation Expert"), None)
google_docs_assistant = next((a for a in assistants if a.name == "Google Docs Content Expert"), None)

print(f"\n📋 Sub-Assistants with Datasources Created:")
print(f"   1. {jira_assistant.name}")
print(f"      ID: {jira_assistant.id}")
print(f"      Datasource: Jira Issues")
print(f"   2. {confluence_assistant.name}")
print(f"      ID: {confluence_assistant.id}")
print(f"      Datasource: Confluence Pages")
print(f"   3. {google_docs_assistant.name}")
print(f"      ID: {google_docs_assistant.id}")
print(f"      Datasource: Google Docs")

# Save IDs for later use
sub_assistant_ids = [jira_assistant.id, confluence_assistant.id, google_docs_assistant.id]
```

**✅ Success Criteria:**
- [ ] Three sub-assistants created successfully
- [ ] Each assistant has a datasource attached via Context
- [ ] Each assistant has a clear, specific description for its domain
- [ ] All assistant IDs are retrieved and displayed

**💡 Tip:** The Context object links the datasource to the assistant. Use `ContextType.KNOWLEDGE_BASE` to attach datasources to your assistants.

**🏆 Bonus:** Verify each assistant's context by calling `client.assistants.get(assistant_id)` and inspecting the `context` field.

---

## 🎯 Challenge 5: Create the Main FAQ Coordinator Assistant

**Goal:** Build a coordinator assistant that orchestrates the datasource-connected sub-assistants

### Instructions

Now let's create the main FAQ assistant that will intelligently delegate questions to the appropriate expert who has access to relevant data.

```python
# Create the main FAQ Coordinator Assistant
coordinator_request = AssistantCreateRequest(
    name="FAQ Coordinator with Knowledge Sources",
    description="Main FAQ assistant that routes questions to specialized experts with datasource access",
    system_prompt=f"""You are an intelligent FAQ Coordinator assistant.

Your role is to route customer questions to the appropriate specialized sub-assistant based on the type of information needed:

1. **{jira_assistant.name}** ({jira_expert_request.description})
   - Use for: Questions about current issues, sprints, tasks, project status
   - Has access to: Live Jira issue data

2. **{confluence_assistant.name}** ({confluence_expert_request.description})
   - Use for: Questions about documentation, how-to guides, best practices
   - Has access to: Confluence knowledge base pages

3. **{google_docs_assistant.name}** ({google_docs_expert_request.description})
   - Use for: Questions about policies, procedures, reference materials
   - Has access to: Google Docs content

Instructions:
- Analyze the user's question to determine what type of information they need
- Delegate to the expert who has access to the relevant datasource
- Questions about "current status" or "what's happening" → Jira Expert
- Questions about "how to" or "documentation" → Confluence Expert
- Questions about "policy" or "procedure" → Google Docs Expert
- Provide comprehensive answers based on the expert's response with datasource information

Always ensure customers get answers from the expert with the right data access.""",
    toolkits=[],
    project=user_project,
    llm_model_type=default_model,
    context=[],  # Coordinator doesn't need datasources - sub-assistants have them
    conversation_starters=[
        "What issues are in the current sprint?",
        "How do I set up the development environment?",
        "What's the vacation policy?",
    ],
    mcp_servers=[],
    assistant_ids=sub_assistant_ids  # Link the sub-assistants!
)

coordinator_response = client.assistants.create(coordinator_request)

# Wait and retrieve the coordinator
sleep(5)

assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

coordinator_assistant = next(
    (a for a in assistants if a.name == "FAQ Coordinator with Knowledge Sources"),
    None
)

print(f"\n✅ FAQ Coordinator Created!")
print(f"   Name: {coordinator_assistant.name}")
print(f"   ID: {coordinator_assistant.id}")
print(f"   Sub-Assistants: {len(coordinator_assistant.assistant_ids)}")
print(f"   Datasources: Delegated to sub-assistants")

# Verify all sub-assistants are linked
print(f"\n🔗 Linked Sub-Assistants with Datasources:")
for sub_id in coordinator_assistant.assistant_ids:
    sub = next((a for a in assistants if a.id == sub_id), None)
    if sub:
        # Get full details to see context
        sub_details = client.assistants.get(sub_id)
        datasource_info = f"({len(sub_details.context)} datasource(s))" if sub_details.context else "(no datasources)"
        print(f"   - {sub.name} {datasource_info}")
```

**✅ Success Criteria:**
- [ ] Main coordinator assistant created successfully
- [ ] Coordinator is linked to all three sub-assistants
- [ ] Coordinator's system prompt explains routing based on data needs
- [ ] Verification shows sub-assistants have datasources attached

**💡 Tip:** The coordinator doesn't need datasources itself—it delegates to sub-assistants who have the right data access!

**🏆 Bonus:** Add more detailed routing logic in the system prompt for edge cases and ambiguous questions.

---

## 🎯 Challenge 6: Test Data-Powered Delegation

**Goal:** Ask questions and verify they route to the correct expert with datasource access

### Instructions

Time to test if our FAQ coordinator correctly delegates to experts who can access the right data!

```python
from codemie_sdk.models.assistant import AssistantChatRequest

print("\n" + "="*60)
print("Testing Data-Powered Delegation System")
print("="*60)

# Question 1: Jira Issues Question (should go to Jira Expert with Jira data)
jira_question = "What issues are currently in progress in our sprint?"

print(f"\n💬 Question: {jira_question}")
print(f"🤔 Expected Expert: {jira_assistant.name} (with Jira datasource)")

chat_request = AssistantChatRequest(
    text=jira_question,
    stream=False,
    propagate_headers=False
)

response = client.assistants.chat(coordinator_assistant.id, chat_request)
print(f"\n🤖 Answer:\n{response.generated[:400]}...")

# Question 2: Confluence Documentation Question
confluence_question = "How do I configure the CI/CD pipeline according to our documentation?"

print(f"\n💬 Question: {confluence_question}")
print(f"🤔 Expected Expert: {confluence_assistant.name} (with Confluence datasource)")

chat_request = AssistantChatRequest(text=confluence_question, stream=False)
response = client.assistants.chat(coordinator_assistant.id, chat_request)
print(f"\n🤖 Answer:\n{response.generated[:400]}...")

# Question 3: Google Docs Policy Question
google_docs_question = "What is our remote work policy?"

print(f"\n💬 Question: {google_docs_question}")
print(f"🤔 Expected Expert: {google_docs_assistant.name} (with Google Docs datasource)")

chat_request = AssistantChatRequest(text=google_docs_question, stream=False)
response = client.assistants.chat(coordinator_assistant.id, chat_request)
print(f"\n🤖 Answer:\n{response.generated[:400]}...")

# Additional test cases
test_cases = [
    ("Who is assigned to the authentication bug?", "Jira Expert"),
    ("Where can I find the API documentation?", "Confluence Expert"),
    ("What are the security guidelines?", "Google Docs Expert"),
]

print(f"\n" + "="*60)
print("Additional Test Cases")
print("="*60)

for question, expected_expert in test_cases:
    print(f"\n💬 {question}")
    print(f"   Expected: {expected_expert}")

    chat_request = AssistantChatRequest(text=question, stream=False)
    response = client.assistants.chat(coordinator_assistant.id, chat_request)
    print(f"   ✅ Got response ({len(response.generated)} chars)")
```

**✅ Success Criteria:**
- [ ] Jira questions route to expert with Jira datasource access
- [ ] Confluence questions route to expert with Confluence datasource access
- [ ] Google Docs questions route to expert with Google Docs datasource access
- [ ] Responses include information from the respective datasources
- [ ] Coordinator successfully delegates based on data needs

**💡 Tip:** Responses should contain specific information from the datasources, not just general knowledge!

**🏆 Bonus:** Test with real data in your Jira/Confluence/Google Docs and verify the responses are accurate and current.

---

## 🎯 Challenge 7: Clean Up Resources

**Goal:** Learn complete resource lifecycle management for multi-agent systems with datasources

### Instructions

Let's clean up all resources: assistants, datasources, and integrations.

```python
print("\n" + "="*60)
print("Cleaning Up Resources")
print("="*60)

# 1. Delete the main coordinator
print(f"\n🗑️  Deleting main coordinator...")
client.assistants.delete(coordinator_assistant.id)
print(f"   ✅ Deleted {coordinator_assistant.name}")

# 2. Delete all sub-assistants
print(f"\n🗑️  Deleting sub-assistants...")
for assistant, name in [(jira_assistant, "Jira Expert"),
                        (confluence_assistant, "Confluence Expert"),
                        (google_docs_assistant, "Google Docs Expert")]:
    client.assistants.delete(assistant.id)
    print(f"   ✅ Deleted {name}")

# 3. Delete datasources
print(f"\n🗑️  Deleting datasources...")
client.datasources.delete(jira_datasource.id)
print(f"   ✅ Deleted Jira datasource")

client.datasources.delete(confluence_datasource.id)
print(f"   ✅ Deleted Confluence datasource")

client.datasources.delete(google_doc_datasource.id)
print(f"   ✅ Deleted Google Docs datasource")

# 4. Delete integrations
print(f"\n🗑️  Deleting integrations...")
client.integrations.delete(jira_integration_obj.id)
print(f"   ✅ Deleted Jira integration")

client.integrations.delete(confluence_integration_obj.id)
print(f"   ✅ Deleted Confluence integration")

print(f"\n✅ All resources cleaned up successfully!")
```

**✅ Success Criteria:**
- [ ] Main coordinator deleted
- [ ] All sub-assistants deleted
- [ ] All datasources deleted
- [ ] All integrations deleted
- [ ] Cleanup completes without errors

**💡 Tip:** Always clean up in order: Assistants → Datasources → Integrations. This prevents dependency errors.

**🏆 Bonus:** Create a cleanup utility that finds and deletes all test resources by pattern matching on names.

---

## 🎓 Kata Complete!

Congratulations! You've mastered the art of building hierarchical AI agents with integrated datasources using the CodeMie Python SDK.

### What You've Accomplished

✅ Set up integrations to external systems (Jira, Confluence)
✅ Created datasources that define knowledge access for each domain
✅ Built specialized sub-assistants with datasource attachments
✅ Created a coordinator that delegates based on data needs
✅ Tested intelligent routing with real datasource queries
✅ Managed complete resource lifecycle (assistants, datasources, integrations)

### Key Concepts Mastered

🎯 **Datasource Integration:**
- **Integrations:** Authenticate with external systems (Jira, Confluence)
- **Datasources:** Define what data assistants can access (JQL queries, CQL queries, doc URLs)
- **Context:** Links datasources to assistants using `ContextType.KNOWLEDGE_BASE`

🎯 **Hierarchical Assistants with Data:**
- **Sub-Assistants with Datasources:** Each expert has access to specific data
- **Coordinator Pattern:** Routes questions based on what data is needed
- **Description-Based Routing:** Clear descriptions help coordinator choose the right expert

🎯 **Best Practices:**
- **Separation of Data Access:** Each sub-assistant has focused datasource access
- **Clear Routing Rules:** Coordinator knows which expert has which data
- **Explicit Descriptions:** Tell the coordinator what each expert can answer
- **Proper Cleanup Order:** Assistants → Datasources → Integrations

### Real-World Applications

This pattern enables powerful enterprise use cases:

**Unified Knowledge Assistant:**
- Single entry point for employees
- Routes to experts with right data access (HR systems, documentation, project management)
- Reduces context switching across tools

**Customer Support with Data:**
- Support assistant routing to experts with live system data
- Billing expert with CRM access
- Technical expert with ticket system access
- Product expert with documentation access

**DevOps Assistant:**
- Coordinator routing to specialists with tool access
- Jira expert for sprint planning
- Git expert for code review
- Confluence expert for runbooks
- Monitoring expert for metrics

### Next Steps

Ready to build more advanced data-powered assistants? Try these patterns:

1. **Multiple Datasources Per Assistant**: Combine Jira + Confluence for one expert
   ```python
   context=[
       Context(name="jira_datasource", context_type=ContextType.KNOWLEDGE_BASE),
       Context(name="confluence_datasource", context_type=ContextType.KNOWLEDGE_BASE)
   ]
   ```

2. **Tool Integration**: Add tools alongside datasources
   - Sub-assistant with Jira datasource + Jira tools for updates
   - Sub-assistant with Confluence datasource + Confluence tools for page creation

### Resources

- [CodeMie Python SDK on PyPI](https://pypi.org/project/codemie-sdk-python/)
- [Assistant Configuration Guide](https://codemie-ai.github.io/docs/user-guide/assistants/)
- [CodeMie Documentation](https://codemie-ai.github.io/docs/)

Happy coding! 🚀
