# Build an AI Code Reviewer with Webhook Automation

Build a complete automated code review system using the CodeMie Python SDK. You'll create a code datasource from a Git repository, connect it to an AI assistant, and set up webhook-based automation to trigger reviews on demand.

This is a production-ready scenario demonstrating CodeMie's programmatic API - ideal for CI/CD integration and automated code quality workflows.

---

## 🎯 Challenge 1: Set Up Your Environment and SDK Client

**Goal:** Install dependencies and establish an authenticated connection to CodeMie services

### Instructions

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
auth_server_url=https://keycloak.eks-core.aws.main.edp.projects.epam.com/auth
verify_ssl=false
```

3. **Create your main script** called `code_reviewer.py`:
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
```

4. **Run your script**:
```bash
python code_reviewer.py
```

**✅ Success Criteria:**
- [ ] SDK installed successfully
- [ ] Configuration file created with your credentials
- [ ] Script runs and prints connection confirmation

**💡 Tip:** Keep your credentials secure! Never commit `example.properties` to version control.

---

## 🎯 Challenge 2: Create a Git Integration

**Goal:** Set up a Git integration to connect your code repository

### Instructions

Configure a Git integration to allow CodeMie to access your repository securely.

1. **Add integration creation code** to your script:
```python
from codemie_sdk.models.integration import (
    Integration,
    CredentialTypes,
    CredentialValues,
    IntegrationType,
)

# Define your Git credentials
# For GitHub: Use Personal Access Token (PAT)
# For GitLab: Use Personal Access Token or OAuth token
git_credentials = [
    CredentialValues(key="url", value="https://github.com/your-org/your-repo"),
    CredentialValues(key="login", value="your-git-username"),
    CredentialValues(key="token", value="your-git-token"),
]

# Create the integration
git_integration_data = Integration(
    name="Code Repository",
    alias="code-repo-integration",
    setting_type=IntegrationType.PROJECT,
    credential_type=CredentialTypes.GIT,
    credentials=git_credentials,
)

response = client.integrations.create(git_integration_data)

# Retrieve the created integration
git_integration = client.integrations.get_by_alias(
    "code-repo-integration",
    setting_type=IntegrationType.PROJECT
)

print(f"✅ Git integration created: {git_integration.id}")
```

**✅ Success Criteria:**
- [ ] Git integration created successfully
- [ ] Integration ID retrieved and stored

**💡 Pro Tip:** Use a Personal Access Token (PAT) with `repo` read permissions for GitHub/GitLab.

---

## 🎯 Challenge 3: Create a Code Datasource

**Goal:** Index your code repository as a searchable datasource

### Instructions

Create a code datasource that indexes your repository for AI-powered code search and analysis.

1. **Add datasource creation code**:
```python
from codemie_sdk.models.datasource import (
    CodeDataSourceRequest,
    CodeDataSourceType,
)

# Get embedding model
embedding_models = client.llms.list_embeddings()
embedding_model_id = embedding_models[0].get('id')

# Create the code datasource
code_datasource_request = CodeDataSourceRequest(
    name="my_code_repository",
    description="Code repository for AI code review",
    project_name="my_first_project",
    setting_id=git_integration.id,
    link="https://github.com/your-org/your-repo",
    branch="main",
    index_type=CodeDataSourceType.CODE,
    embeddings_model=embedding_model_id,
    files_filter="",  # Empty = index all files; use "*.py,*.js" for specific types
    shared_with_project=True,
)

datasource_response = client.datasources.create(code_datasource_request)

# Get the created datasource
datasources = client.datasources.list(per_page=50)
code_datasource = next(
    (ds for ds in datasources if ds.name == "my_code_repository"),
    None
)

print(f"✅ Code datasource created: {code_datasource.id}")
print(f"Status: {code_datasource.status}")
```

**✅ Success Criteria:**
- [ ] Code datasource created successfully
- [ ] Indexing process started

**💡 Tip:** Indexing may take several minutes depending on repository size. Use `files_filter` to limit indexing to specific file types.

---

## 🎯 Challenge 4: Create Code Reviewer Assistant

**Goal:** Build an AI assistant configured for code review with linked datasource

### Instructions

You have two options to create your code reviewer assistant:

**Option 1: Use Template Assistant (Recommended)**

Use the prebuilt code reviewer template for quick setup:

```python
from codemie_sdk.models.assistant import (
    AssistantCreateRequest,
    Context,
    ContextType,
)

# Get the template code reviewer assistant
template_assistant = client.assistants.get_prebuilt_by_slug("template-code-reviewer-assistant")

# Define code review context
code_context = Context(
    type=ContextType.CODE,
    id=code_datasource.id,
    name=code_datasource.name,
)

# Create assistant from template with your datasource
assistant_request = AssistantCreateRequest(
    name=template_assistant.name,
    description=template_assistant.description,
    system_prompt=template_assistant.system_prompt,
    toolkits=template_assistant.toolkits,
    project="my_first_project",
    llm_model_type=template_assistant.llm_model_type,
    context=[code_context],  # Link your code datasource
    conversation_starters=template_assistant.conversation_starters,
    mcp_servers=[],
    assistant_ids=[],
)

assistant_response = client.assistants.create(assistant_request)

# Get the created assistant
assistants = client.assistants.list(
    minimal_response=False,
    scope="visible_to_user",
    per_page=50
)
code_reviewer = next(
    (a for a in assistants if template_assistant.name in a.name),
    None
)

print(f"✅ Assistant created from template: {code_reviewer.id}")
```

**Option 2: Create Custom Assistant**

Build a fully customized code reviewer from scratch:

```python
from codemie_sdk.models.assistant import (
    AssistantCreateRequest,
    Context,
    ContextType,
)

# Get LLM model (prefer Gemini or Claude for code review)
llm_models = client.llms.list()
llm_model = next(
    (m for m in llm_models if 'gemini' in m.get('id', '').lower() or 'claude' in m.get('id', '').lower()),
    llm_models[0]
)

# Define code review context
code_context = Context(
    type=ContextType.CODE,
    id=code_datasource.id,
    name=code_datasource.name,
)

# Create custom assistant
assistant_request = AssistantCreateRequest(
    name="AI Code Reviewer",
    description="Automated code reviewer with repository knowledge",
    system_prompt="""You are an expert code reviewer with deep knowledge of software engineering best practices.

Your responsibilities:
1. Review code for bugs, security vulnerabilities, and performance issues
2. Check code quality, readability, and maintainability
3. Suggest improvements following SOLID principles and design patterns
4. Identify potential edge cases and error handling gaps
5. Provide constructive feedback with specific examples

When reviewing code:
- Use the code repository context to understand the codebase structure
- Be thorough but concise
- Prioritize critical issues (security, bugs) over style preferences
- Suggest concrete improvements with code examples
- Consider the broader context and architecture

Format your reviews with:
- Summary of key findings
- Categorized issues (Critical, Important, Minor)
- Specific recommendations with code snippets
""",
    toolkits=[],
    project="my_first_project",
    llm_model_type=llm_model.get('id'),
    context=[code_context],
    conversation_starters=[
        "Review the authentication module for security issues",
        "Analyze error handling in the API endpoints",
        "Check for performance bottlenecks in database queries",
        "Review the test coverage and suggest improvements",
    ],
    mcp_servers=[],
    assistant_ids=[],
)

assistant_response = client.assistants.create(assistant_request)

# Get the created assistant
assistants = client.assistants.list(
    minimal_response=False,
    scope="visible_to_user",
    per_page=50
)
code_reviewer = next(
    (a for a in assistants if a.name == "AI Code Reviewer"),
    None
)

print(f"✅ Assistant created: {code_reviewer.id}")
```

**✅ Success Criteria:**
- [ ] Assistant created (from template or custom)
- [ ] Datasource successfully linked to assistant
- [ ] Assistant ID retrieved

**💡 Tips:**
- Use template assistant for quick setup with proven prompts
- Create custom assistant for specific tech stack requirements or custom coding standards

---

## 🎯 Challenge 5: Set Up Webhook Integration

**Goal:** Create a webhook that triggers the code reviewer assistant

### Instructions

Configure webhook automation to trigger your code reviewer on demand.

1. **Add webhook creation code**:
```python
# Define webhook configuration
webhook_id = "code-reviewer-webhook"
webhook_credentials = [
    CredentialValues(key="webhook_id", value=webhook_id),
    CredentialValues(key="is_enabled", value=True),
    CredentialValues(key="resource_type", value="assistant"),
    CredentialValues(key="resource_id", value=code_reviewer.id),
]

# Create the webhook integration
webhook_integration_data = Integration(
    name="Code Reviewer Webhook",
    alias=f"webhook-{webhook_id}",
    setting_type=IntegrationType.PROJECT,
    credential_type=CredentialTypes.WEBHOOK,
    credentials=webhook_credentials,
)

webhook_response = client.integrations.create(webhook_integration_data)

# Retrieve the webhook URL
webhook_integration = client.integrations.get_by_alias(
    f"webhook-{webhook_id}",
    setting_type=IntegrationType.PROJECT
)

webhook_url = next(
    (cred.value for cred in webhook_integration.credentials if cred.key == "url"),
    None
)

print(f"✅ Webhook created: {webhook_url}")
```

**✅ Success Criteria:**
- [ ] Webhook integration created successfully
- [ ] Webhook URL generated and retrieved
- [ ] Webhook linked to code reviewer assistant

**💡 Pro Tip:** Save the webhook URL - you'll need it for CI/CD integration.

---

## 🎯 Challenge 6: Trigger the Webhook

**Goal:** Test your automated code reviewer by triggering it via webhook

### Instructions

Trigger a code review via the webhook and verify the conversation is created.

1. **Add webhook trigger code**:
```python
import time

# Prepare a code review request
review_request = {
    "message": "Review the authentication module for security vulnerabilities"
}

# Trigger the webhook
trigger_response = client.webhook.trigger(webhook_id, review_request)

if trigger_response.status_code == 200:
    print("✅ Code review triggered successfully!")

    # Wait for conversation to be created
    time.sleep(3)

    # Verify conversation creation
    conversations = client.conversations.list(per_page=10)
    latest_conversation = next(
        (c for c in conversations if c.initial_assistant_id == code_reviewer.id),
        None
    )

    if latest_conversation:
        print(f"✅ Conversation created: {latest_conversation.id}")
else:
    print(f"❌ Webhook trigger failed: {trigger_response.status_code}")
```

**✅ Success Criteria:**
- [ ] Webhook triggered successfully (200 status code)
- [ ] New conversation created with your assistant
- [ ] Code review process initiated

---

## 🎯 Challenge 7: Automate Multiple Review Scenarios

**Goal:** Trigger different code review scenarios programmatically

### Instructions

Test various code review use cases to understand webhook flexibility.

1. **Add scenario testing code**:
```python
# Define review scenarios
scenarios = [
    "Review all API endpoint handlers for proper error handling",
    "Check database query performance in the user service",
    "Analyze security practices in authentication and authorization code",
    "Review test coverage and suggest additional test cases",
]

# Trigger each scenario
for scenario in scenarios:
    response = client.webhook.trigger(webhook_id, {"message": scenario})

    if response.status_code == 200:
        print(f"✅ Triggered: {scenario[:50]}...")
    else:
        print(f"❌ Failed: {scenario[:50]}...")

    time.sleep(2)  # Rate limiting

print(f"\n✅ All {len(scenarios)} review scenarios triggered!")
```

**✅ Success Criteria:**
- [ ] Multiple webhook triggers executed successfully
- [ ] Different review requests processed
- [ ] Conversations created for each scenario

**🏆 Bonus:** Integrate this webhook into a CI/CD pipeline (GitHub Actions, GitLab CI).

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've built a complete automated AI code review system using the CodeMie Python SDK:

✅ **Connected** to CodeMie services with configuration file
✅ **Created** a Git integration for repository access
✅ **Indexed** your codebase as a searchable datasource
✅ **Built** an AI code reviewer assistant with repository context
✅ **Configured** webhook automation for on-demand reviews
✅ **Triggered** automated code reviews via API
✅ **Tested** multiple review scenarios

### Real-World Applications

**CI/CD Integration** - Trigger code reviews on every pull request:
```yaml
# GitHub Actions example
- name: AI Code Review
  run: |
    curl -X POST https://your-webhook-url \
      -H "Content-Type: application/json" \
      -d '{"message": "Review PR #${{ github.event.pull_request.number }}"}'
```

**Scheduled Reviews** - Periodic security and quality checks:
```bash
# Cron job for weekly code review
0 9 * * 1 python trigger_review.py --scope security
```

**Custom CLI Tool** - Developer productivity tool:
```python
def review_my_changes():
    diff = get_git_diff()
    client.webhook.trigger(webhook_id, {"message": f"Review: {diff}"})
```

### Next Steps

1. **Multi-Repository Reviews**: Create datasources for multiple repos
2. **Structured Outputs**: Use Pydantic models for formatted review reports
3. **Workflow Integration**: Build workflows that chain multiple review steps
4. **Datasource Updates**: Automate reindexing when code changes
5. **Review Analytics**: Track review patterns and code quality metrics

### Resources

- **[CodeMie SDK Documentation](https://pypi.org/project/codemie-sdk-python/)**: Complete API reference
- **[Webhook Integration Guide](https://codemie-ai.github.io/docs/)**: Advanced webhook patterns

### Cleanup (Optional)

To remove the resources created in this kata:

```python
# Delete webhook integration
client.integrations.delete(webhook_integration.id, IntegrationType.PROJECT)

# Delete assistant
client.assistants.delete(code_reviewer.id)

# Delete datasource
client.datasources.delete(code_datasource.id)

# Delete git integration
client.integrations.delete(git_integration.id, IntegrationType.PROJECT)

print("✅ All resources cleaned up!")
```
