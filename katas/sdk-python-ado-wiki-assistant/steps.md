# Build an Azure DevOps Wiki Assistant with CodeMie SDK

Transform your Azure DevOps wiki into an intelligent, AI-powered knowledge base! In this kata, you'll build an assistant that can search your wiki content, create new pages, and update documentation automatically using the CodeMie Python SDK.

**What You'll Build:**
- An ADO integration with secure authentication
- A wiki datasource that indexes your documentation
- An AI assistant with wiki management capabilities
- Working examples of wiki search, creation, and modification

**Prerequisites:**
- Python 3.8 or higher installed
- Azure DevOps account with a project and wiki
- Personal Access Token (PAT) with Wiki permissions ([Create one here](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate))
- CodeMie platform account and API credentials

---

## 🎯 Challenge 1: Environment Setup

**Goal:** Set up your development environment with required credentials.

### Gather Your Credentials

You'll need the following information:

**CodeMie Credentials:**
- `auth_server_url` - Your Keycloak authentication server
- `auth_client_id` - Client ID
- `auth_client_secret` - Client secret
- `auth_realm_name` - Realm name
- `codemie_api_domain` - CodeMie API URL

**Azure DevOps Credentials:**
- `organization` - Your ADO organization name
- `project` - Your ADO project name
- `personal_access_token` - PAT with Wiki read/write permissions

### Create Configuration File

Create a `.env` file in your project directory:

```bash
# CodeMie Authentication
AUTH_SERVER_URL=https://your-auth-server/auth
AUTH_CLIENT_ID=your-client-id
AUTH_CLIENT_SECRET=your-client-secret
AUTH_REALM_NAME=your-realm
CODEMIE_API_DOMAIN=https://api.codemie.com

# Azure DevOps
ADO_ORGANIZATION=your-org
ADO_PROJECT=your-project
ADO_PAT=your-personal-access-token
```

**✅ Success Criteria:**
- [ ] All required credentials collected
- [ ] `.env` file created with proper formatting
- [ ] ADO PAT has Wiki permissions enabled

---

## 🎯 Challenge 2: Install and Initialize SDK

**Goal:** Install the CodeMie Python SDK and create your first client connection.

### Install the SDK

```bash
pip install codemie-sdk-python
```

### Create Your First Script

Create `ado_wiki_assistant.py`:

```python
import os
from dotenv import load_dotenv
from codemie_sdk import CodeMieClient

# Load environment variables
load_dotenv()

# Initialize CodeMie client
client = CodeMieClient(
    auth_server_url=os.getenv("AUTH_SERVER_URL"),
    auth_client_id=os.getenv("AUTH_CLIENT_ID"),
    auth_client_secret=os.getenv("AUTH_CLIENT_SECRET"),
    auth_realm_name=os.getenv("AUTH_REALM_NAME"),
    codemie_api_domain=os.getenv("CODEMIE_API_DOMAIN"),
    verify_ssl=os.getenv("VERIFY_SSL", "false").lower() == "true",
    username=os.getenv("AUTH_USERNAME"),
    password=os.getenv("AUTH_PASSWORD")
)

print("✓ CodeMie client initialized successfully!")

# Test connection
user_info = client.users.about_me()
print(f"✓ Connected as: '{user_info.name}'")
```

### Run the Script

```bash
python ado_wiki_assistant.py
```

**✅ Success Criteria:**
- [ ] SDK installed without errors
- [ ] Client initialized successfully
- [ ] Connection test shows your username

---

## 🎯 Challenge 3: Create Azure DevOps Integration

**Goal:** Configure the ADO integration with your credentials to enable wiki access.

### Add Integration Creation Code

Add this to your `ado_wiki_assistant.py`:

```python
from codemie_sdk.models.integration import (
    Integration,
    CredentialTypes,
    CredentialValues,
    IntegrationType
)

ado_wiki_integration_alias = "ADO Wiki Integration"

def create_ado_integration():
    """Create Azure DevOps integration with credentials."""

    # Check if integration already exists
    try:
        existing = client.integrations.get_by_alias(
            ado_wiki_integration_alias,
            setting_type=IntegrationType.USER
        )
        print(f"✓ Using existing integration: {existing['id']}")
        return existing['id']
    except:
        pass

    # Create new integration
    ado_integration = Integration(
        project_name=os.getenv("PROJECT_NAME"),
        credential_type=CredentialTypes.AZURE_DEVOPS,
        credential_values=[
            CredentialValues(key="url", value=os.getenv("ADO_URL")),
            CredentialValues(key="project", value=os.getenv("ADO_PROJECT")),
            CredentialValues(key="organization", value=os.getenv("ADO_ORGANIZATION")),
            CredentialValues(key="token", value=os.getenv("ADO_PAT")),
        ],
        alias=ado_wiki_integration_alias,
        setting_type=IntegrationType.USER,
        default=False,
        is_global=False
    )

    created = client.integrations.create(ado_integration)
    print(f"✓ ADO integration: {created["message"]}")
    return client.integrations.get_by_alias(
            ado_wiki_integration_alias,
            setting_type=IntegrationType.USER
        )['id']

# Create the integration
integration_id = create_ado_integration()
```

**✅ Success Criteria:**
- [ ] Integration created successfully
- [ ] Integration ID displayed
- [ ] Script can retrieve existing integration on subsequent runs

---

## 🎯 Challenge 4: Create ADO Wiki Datasource

**Goal:** Set up a wiki datasource that indexes your ADO wiki content for semantic search.

### Add Datasource Creation Code

```python
from codemie_sdk.models.datasource import AzureDevOpsWikiDataSourceRequest

datasource_name = "ado_wiki_knowledge"

def create_wiki_datasource(integration_id):
    """Create ADO Wiki datasource for knowledge retrieval."""

    # Check if datasource exists
    existing_datasources = client.datasources.list(
        filters={"name": datasource_name}, per_page=200)

    for ds in existing_datasources:
        if ds['name'] == datasource_name:
            print(f"✓ Using existing datasource: {ds['id']}")
            return ds['id']

    # Create new datasource
    wiki_datasource = AzureDevOpsWikiDataSourceRequest(
        name=datasource_name,
        project_name=os.getenv("PROJECT_NAME"),
        description="Azure DevOps Wiki Knowledge Base",
        setting_id=integration_id,
        wiki_query="/Super Mega Page/Codemie is the best app",  # "*" - Index all wiki pages
        wiki_name=f"{os.getenv('ADO_PROJECT')}.wiki"
    )

    created = client.datasources.create(wiki_datasource)
    print(f"✓ ADO wiki datasource: {created['message']}")
    print("⏳ Datasource indexing started (this may take a few minutes)...")
    return client.datasources.list(
        filters={"name": datasource_name}, per_page=200)[0]['id']

# Create the datasource
datasource_id = create_wiki_datasource(integration_id)
```

**✅ Success Criteria:**
- [ ] Datasource created with correct wiki name
- [ ] Datasource ID displayed
- [ ] Indexing process started

**🏆 Bonus:**
- Modify `wiki_query` to index only specific wiki paths (e.g., `"/Engineering/*"`)

---

## 🎯 Challenge 5: Verify Datasource Indexing

**Goal:** Check the indexing status and ensure your wiki content is ready to use.

### Add Status Check Code

```python
import time

def check_datasource_status(datasource_id, max_wait=120):
    """Monitor datasource indexing status."""

    print("Checking datasource status...")
    start_time = time.time()

    while time.time() - start_time < max_wait:
        ds = client.datasources.get(datasource_id)
        status = ds["status"]
        indexed_count = len(ds["processed_documents"])

        print(f"  Status: {status} | Indexed pages: {indexed_count}")

        if status == "completed" and indexed_count > 0:
            print(f"✓ Datasource ready! {indexed_count} wiki pages indexed.")
            return True

        if status == "failed":
            print("✗ Datasource indexing failed!")
            return False

        time.sleep(5)

    print("⚠ Datasource still indexing. You can proceed, but results may be limited.")
    return True

# Check status
check_datasource_status(datasource_id)
```

**✅ Success Criteria:**
- [ ] Status check shows "active" or "indexing"
- [ ] At least 1 wiki page indexed
- [ ] No indexing errors reported

---

## 🎯 Challenge 6: Create Assistant with Wiki Tools

**Goal:** Build an AI assistant with both wiki tools and datasource context.

### Add Assistant Creation Code

```python
from codemie_sdk.models.assistant import (
    AssistantCreateRequest,
    Context,
    ContextType,
    ToolKitDetails
)

ado_wiki_assistant_name = "ADO Wiki Assistant"

def create_ado_wiki_assistant():
    """Create assistant with ADO Wiki tools and knowledge base."""

    ado_integration = client.integrations.get_by_alias(
            ado_wiki_integration_alias,
            setting_type=IntegrationType.USER
        )

    assistant_request = AssistantCreateRequest(
        name=ado_wiki_assistant_name,
        description="AI assistant for Azure DevOps wiki management",
        system_prompt="""You are an expert Azure DevOps wiki assistant.

You can:
1. Search and retrieve information from the wiki knowledge base
2. Create new wiki pages with proper formatting
3. Modify existing wiki pages
4. Answer questions about wiki content

When users ask questions, search the knowledge base first.
When creating pages, use clear Markdown formatting.
Always be helpful and provide detailed responses.""",
        project=os.getenv("PROJECT_NAME"),
        llm_model_type=client.llms.list()[0].base_name,
        toolkits=[
            ToolKitDetails(
                toolkit="Azure DevOps Wiki",
                tools=[ToolDetails(name="get_wiki_page_by_path"),
                       ToolDetails(name="modify_wiki_page"),
                       ToolDetails(name="create_wiki_page")],
                settings_config=True,
                settings = ado_integration
            )
        ],
        context=[
            Context(
                name=datasource_name,
                context_type=ContextType.KNOWLEDGE_BASE
            )
        ],
        conversation_starters=[
            "What documentation is in our wiki?",
            "Create a new getting started page",
            "Update the architecture documentation"
        ]
    )

    response = client.assistants.create(assistant_request)
    print(f"✓ ADO Wiki assistant: {response['message']}")


# Create the assistant
create_ado_wiki_assistant()
```

**✅ Success Criteria:**
- [ ] Assistant created with wiki toolkit
- [ ] Datasource linked as context
- [ ] Assistant ID displayed

---

## 🎯 Challenge 7: Query Wiki Knowledge Base

**Goal:** Ask your assistant questions about wiki content to test knowledge retrieval.

### Add Chat Function

```python
def chat_with_assistant(assistant_name, message):
    """Send a message to the assistant and display response."""

    print(f"\n💬 You: {message}")

    chat_request = AssistantChatRequest(
        text=message,
        stream=False
    )

    assistant_id = client.assistants.list(filters={"name": assistant_name}, per_page=1)[0]['id']

    response = client.assistants.chat(assistant_id, chat_request)

    print(f"🤖 Assistant: {response.generated}")

    # Show triggered tools
    print(f"🔧 Tool used: {response.thoughts[0]['author_name']}")

    return response.generated

    # Chat with assistant
    assistant_answer = chat_with_assistant(
        ado_wiki_assistant_name,
        "What documentation do we have in our wiki?"
    )
```

**✅ Success Criteria:**
- [ ] Assistant responds with wiki content
- [ ] Response shows relevant information from indexed pages
- [ ] Tools section shows datasource search was used

**🏆 Bonus:**
- Ask follow-up questions about specific wiki pages

---

## 🎯 Challenge 8: Create a New Wiki Page

**Goal:** Use your assistant to create a new wiki page with content.

### Create Wiki Page via Assistant

```python
# Create a new wiki page
chat_with_assistant(
    ado_wiki_assistant_name,
    """Create a new wiki page at path '/CodeMie-Kata-Demo' with the following content:

# CodeMie Kata Demo

This page was created by an AI assistant using the CodeMie Python SDK!

## Features
- Automated wiki page creation
- AI-powered content generation
- Integration with Azure DevOps

## Next Steps
- Explore more wiki automation
- Build custom assistants
- Integrate with your workflows
"""
)
```

### Verify in Azure DevOps

Visit your ADO wiki and check if the new page appears at `/CodeMie-Kata-Demo`.

**✅ Success Criteria:**
- [ ] Assistant confirms page creation
- [ ] `create_wiki_page` tool triggered
- [ ] New page visible in Azure DevOps wiki
- [ ] Content formatted correctly

---

## 🎯 Challenge 9: Modify an Existing Wiki Page

**Goal:** Update the wiki page you just created with additional content.

### Modify the Page

```python
# Modify the existing page
chat_with_assistant(
    ado_wiki_assistant_name,
    """Modify the wiki page at path '/CodeMie-Kata-Demo'.

Add a new section at the end:

## Achievements
- ✅ Created ADO integration
- ✅ Built wiki datasource
- ✅ Deployed AI assistant
- ✅ Automated wiki management

Last updated: [Current Date]
"""
)
```

### Verify Changes

Refresh the wiki page in Azure DevOps to see the updates.

**✅ Success Criteria:**
- [ ] Assistant confirms page modification
- [ ] `modify_wiki_page` tool triggered
- [ ] Changes visible in Azure DevOps
- [ ] Original content preserved with additions

**🏆 Bonus:**
- Try renaming the page using the assistant

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've successfully built an Azure DevOps Wiki assistant with the CodeMie SDK. Here's what you achieved:

✅ **Integration Setup** - Connected CodeMie with Azure DevOps securely
✅ **Knowledge Base** - Created a wiki datasource for semantic search
✅ **AI Assistant** - Built an assistant with wiki management capabilities
✅ **Wiki Search** - Retrieved information from indexed wiki content
✅ **Page Creation** - Automated new page creation with AI-generated content
✅ **Page Modification** - Updated existing documentation programmatically

### Key Concepts Learned

- **Integration Management**: Secure credential storage for external services
- **Datasource Configuration**: Indexing external content for RAG
- **Assistant Creation**: Combining tools and knowledge bases
- **Tool Execution**: Using AI to trigger specific operations
- **Context Usage**: Leveraging indexed content in assistant responses

### Next Steps

Ready to take your skills further?

1. **Add More Toolkits**: Explore ADO Work Item and Test Plan toolkits
2. **Advanced Queries**: Use `wiki_query` parameter to filter specific paths
3. **Workflow Integration**: Build workflows that combine multiple assistants
4. **Production Deployment**: Deploy your assistant for team use
5. **Custom Tools**: Create MCP servers for custom ADO operations

### Additional Resources

- [CodeMie SDK Documentation](https://github.com/codemie-ai/codemie-sdk)
- [Azure DevOps REST API Reference](https://learn.microsoft.com/en-us/rest/api/azure/devops/)
- [Building RAG Systems with Knowledge Bases](https://www.codemie.ai/docs/rag)

### Complete Code

Your final `ado_wiki_assistant.py` should contain all functions. Here's the full execution flow:

```python
# Complete execution
if __name__ == "__main__":
    # 1. Create integration
    integration_id = create_ado_integration()

    # 2. Create the datasource
    datasource_id = create_wiki_datasource(integration_id)

    # 3. Check status
    check_datasource_status(datasource_id)

    # 4. Create assistant
    create_ado_wiki_assistant()

    # 5. Chat with assistant
    assistant_answer = chat_with_assistant(
        ado_wiki_assistant_name,
        "What documentation do we have in our wiki?"
    )

    # 6. Create a new wiki page
    chat_with_assistant(
        ado_wiki_assistant_name,
        """Create a new wiki page at path '/CodeMie-Kata-Demo' with the following content:

    # CodeMie Kata Demo

    This page was created by an AI assistant using the CodeMie Python SDK!

    ## Features
    - Automated wiki page creation
    - AI-powered content generation
    - Integration with Azure DevOps

    ## Next Steps
    - Explore more wiki automation
    - Build custom assistants
    - Integrate with your workflows
    """
    )

    # 7. Modify an existing wiki page
    chat_with_assistant(
        ado_wiki_assistant_name,
        """Modify the wiki page at path '/CodeMie-Kata-Demo'.

    Add a new section at the end:

    ## Achievements
    - ✅ Created ADO integration
    - ✅ Built wiki datasource
    - ✅ Deployed AI assistant
    - ✅ Automated wiki management

    Last updated: [Current Date]
    """)
```

Great work! You're now ready to build production-ready ADO assistants with CodeMie! 🚀
