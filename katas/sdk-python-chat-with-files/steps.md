# Chat with Files: Upload and Analyze Documents with AI

Welcome to the document-powered AI challenge! In this kata, you'll learn how to upload files to CodeMie and enable your AI assistant to read, analyze, and answer questions about those documents. This is a critical skill for building document analysis systems, code review tools, and knowledge-based assistants.

By the end of this kata, you'll have a working AI assistant that can intelligently process and answer questions about uploaded files.

---

## 🎯 Challenge 1: Set Up Your Environment

**Goal:** Install dependencies and establish an authenticated connection to CodeMie

### Instructions

Let's prepare your environment for file-based AI interactions.

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

3. **Create your main script** called `file_assistant.py`:
```python
import os
from pathlib import Path
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
python file_assistant.py
```

**✅ Success Criteria:**
- [ ] SDK installed successfully
- [ ] Configuration file created with credentials
- [ ] Script runs and prints connection confirmation
- [ ] Authentication token is displayed

**💡 Tip:** Make sure to keep your credentials secure and never commit them to version control!

---

## 🎯 Challenge 2: Create Sample Files for Upload

**Goal:** Prepare test documents that your AI assistant will analyze

### Instructions

Let's create some sample files to upload and analyze.

1. **Create a project directory structure**:
```bash
mkdir sample_files
```

2. **Create a sample Python file** (`sample_files/example_code.py`):
```python
"""
Sample Python code for demonstrating AI assistant capabilities.
"""

def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number using iteration."""
    if n <= 0:
        return 0
    elif n == 1:
        return 1

    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b

    return b

def factorial(n):
    """Calculate factorial of n."""
    if n <= 1:
        return 1
    return n * factorial(n - 1)

class DataProcessor:
    """Example class for data processing."""

    def __init__(self, data):
        self.data = data
        self.processed = False

    def process(self):
        """Process the data."""
        self.data = [x * 2 for x in self.data]
        self.processed = True
        return self.data
```

3. **Create a sample markdown document** (`sample_files/README.md`):
```markdown
# Project Documentation

## Overview
This is a sample project demonstrating various features.

## Features
- Feature 1: Fast processing
- Feature 2: Easy integration
- Feature 3: Scalable architecture

## Installation
```bash
pip install sample-project
```

## Usage
```python
from sample import DataProcessor

processor = DataProcessor([1, 2, 3])
result = processor.process()
```
```

4. **Create a sample configuration file** (`sample_files/config.json`):
```json
{
  "app_name": "Sample Application",
  "version": "1.0.0",
  "settings": {
    "debug": true,
    "max_connections": 100,
    "timeout": 30
  },
  "features": {
    "authentication": true,
    "logging": true,
    "caching": false
  }
}
```

**✅ Success Criteria:**
- [ ] Created `sample_files` directory
- [ ] Created Python code file
- [ ] Created markdown documentation
- [ ] Created JSON configuration file
- [ ] All files contain sample content

**💡 Pro Tip:** You can use any existing files you have! These are just examples to get started.

---

## 🎯 Challenge 3: Upload Files Using bulk_upload

**Goal:** Upload multiple files to CodeMie and get file URLs for assistant chat

### Instructions

Time to upload your files! The `bulk_upload` method returns file URLs that you'll use with your assistant.

1. **Add file upload code** to your `file_assistant.py`:
```python
from pathlib import Path

# Define the files to upload
files_to_upload = [
    Path("sample_files/example_code.py"),
    Path("sample_files/README.md"),
    Path("sample_files/config.json"),
]

print("\n📤 Uploading files...")

# Upload files using bulk_upload
upload_response = client.files.bulk_upload(files_to_upload)

print(f"✅ Successfully uploaded {len(upload_response.files)} file(s)")

# Extract file URLs from response
file_urls = [file.file_url for file in upload_response.files]

print("\n📁 Uploaded files:")
for i, (file_path, file_url) in enumerate(zip(files_to_upload, file_urls), 1):
    print(f"  {i}. {file_path.name} -> {file_url}")

# Check for failed uploads
if upload_response.failed_files:
    print(f"\n⚠️  Failed uploads: {len(upload_response.failed_files)}")
    for failed in upload_response.failed_files:
        print(f"  - {failed}")
```

2. **Run your script** and verify uploads:
```bash
python file_assistant.py
```

**✅ Success Criteria:**
- [ ] Files uploaded successfully
- [ ] Received file URLs for each uploaded file
- [ ] File URLs are printed and available
- [ ] No failed uploads

**🏆 Bonus:**
- Upload different file types: `.txt`, `.csv`, `.pdf`, `.docx`
- Handle upload errors gracefully with try-except
- Add file size validation before upload

**💡 Pro Tip:** The `file_url` returned from `bulk_upload` is what you'll pass to the assistant in the `file_names` parameter!

---

## 🎯 Challenge 4: Create an AI Assistant

**Goal:** Set up an AI assistant that can work with file context

### Instructions

Let's create an assistant configured to analyze documents and code.

1. **Import assistant models**:
```python
from codemie_sdk.models.assistant import AssistantCreateRequest
from time import sleep
```

2. **Create your assistant**:
```python
import uuid

# Define project and assistant details
user_project="user_email@epam.com", # personal user project
assistant_name = "Document Analyzer"
assistant_slug = f"{assistant_name} {uuid.uuid4()}"

# Create assistant request
assistant_request = AssistantCreateRequest(
    name=assistant_name,
    slug=assistant_slug,
    description="An AI assistant specialized in analyzing documents and code",
    system_prompt="""You are a helpful document and code analysis assistant.
    When provided with files, carefully read and analyze their content.
    Provide clear, detailed insights about the files, including:
    - Code structure and patterns
    - Documentation quality
    - Configuration settings
    - Potential improvements or issues
    Always reference specific parts of the files in your responses.""",
    llm_model_type="gpt-5-2025-08-07",
    project=user_project,
    toolkits=[],
    temperature=0.3,  # Lower temperature for more focused analysis
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
```

**✅ Success Criteria:**
- [ ] Assistant created successfully
- [ ] Assistant has document analysis system prompt
- [ ] Assistant ID is available for chat
- [ ] Temperature is set for focused responses

**🏆 Bonus:**
- Customize system prompt for specific use cases (code review, documentation, etc.)
- Experiment with different temperatures (0.1 for precise, 0.7 for creative)
- Add conversation starters related to file analysis

---

## 🎯 Challenge 5: Chat with Your Assistant Using Uploaded Files

**Goal:** Send chat requests with file references and get intelligent responses

### Instructions

Now for the magic - let's chat with the assistant about the uploaded files!

1. **Import chat models**:
```python
from codemie_sdk.models.assistant import AssistantChatRequest
```

2. **Chat with file context**:
```python
# Create chat request with file_names parameter
chat_request = AssistantChatRequest(
    text="Please analyze the uploaded files and provide a summary of what they contain.",
    file_names=file_urls,  # Pass the file URLs from Challenge 3
    stream=False,
)

print("\n💬 Sending chat request with files...")

# Chat with assistant
response = client.assistants.chat(
    assistant_id=assistant_id,
    request=chat_request
)

print(f"\n🤖 Assistant Response:")
print(f"{response.generated}")
print(f"\n⏱️  Time elapsed: {response.time_elapsed:.2f}s")
print(f"🎫 Tokens used: {response.tokens_used}")
```

3. **Try asking specific questions**:
```python
# Ask about specific files
questions = [
    "What does the calculate_fibonacci function do in example_code.py?",
    "What features are listed in the README.md file?",
    "What is the timeout value in config.json?",
    "Are there any potential improvements for the DataProcessor class?",
]

print("\n🗣️  Asking specific questions about files...")
for question in questions:
    chat_request = AssistantChatRequest(
        text=question,
        file_names=file_urls,
        stream=False,
    )
    response = client.assistants.chat(assistant_id, chat_request)
    print(f"\nQ: {question}")
    print(f"A: {response.generated[:250]}...")  # First 250 chars
    print("---")
```

**✅ Success Criteria:**
- [ ] Successfully sent chat request with file_names
- [ ] Assistant analyzed and summarized files
- [ ] Assistant can answer specific questions about file content
- [ ] Responses reference actual file content

**🏆 Bonus:**
- Enable streaming mode for real-time responses: `stream=True`
- Ask cross-file questions: "How does the code relate to the documentation?"
- Request code improvements or refactoring suggestions
- Use conversation_id to maintain context across multiple questions

**💡 Pro Tip:** The assistant can access all files in `file_names` simultaneously, allowing for cross-file analysis!

---

## 🎯 Challenge 6: Advanced File Chat Patterns

**Goal:** Explore advanced use cases for file-based AI interactions

### Instructions

Let's explore more sophisticated patterns for working with files.

1. **Conversation with history**:
```python
from codemie_sdk.models.assistant import ChatMessage, ChatRole

# Build conversation history
conversation_id = str(uuid.uuid4())
history = [
    ChatMessage(role=ChatRole.USER, message="What files did you analyze?"),
    ChatMessage(role=ChatRole.ASSISTANT, message="I analyzed three files: example_code.py, README.md, and config.json"),
]

# Continue conversation with context
chat_request = AssistantChatRequest(
    text="Can you suggest improvements for the Python code?",
    file_names=file_urls,
    conversation_id=conversation_id,
    history=history,
    stream=False,
)

response = client.assistants.chat(assistant_id, chat_request)
print(f"\n💡 Improvement Suggestions:")
print(response.generated)
```

2. **Selective file analysis**:
```python
# Analyze only specific files
python_file_url = [url for url in file_urls if "example_code.py" in url][0]

chat_request = AssistantChatRequest(
    text="Perform a detailed code review of this Python file. Check for best practices, potential bugs, and suggest improvements.",
    file_names=[python_file_url],  # Only one file
    stream=False,
)

response = client.assistants.chat(assistant_id, chat_request)
print(f"\n🔍 Code Review:")
print(response.generated)
```

3. **Structured output for file analysis**:
```python
from pydantic import BaseModel
from typing import List

# Define structured output schema
class FileAnalysis(BaseModel):
    file_name: str
    file_type: str
    summary: str
    key_points: List[str]
    suggestions: List[str]

class MultiFileAnalysis(BaseModel):
    total_files: int
    analyses: List[FileAnalysis]

# Request structured output
chat_request = AssistantChatRequest(
    text="Analyze all uploaded files and provide structured analysis.",
    file_names=file_urls,
    output_schema=MultiFileAnalysis,
    stream=False,
)

response = client.assistants.chat(assistant_id, chat_request)

# Response will be structured according to schema
analysis = response.generated
print(f"\n📊 Structured Analysis:")
print(f"Total files analyzed: {analysis.total_files}")
for file_analysis in analysis.analyses:
    print(f"\n📄 {file_analysis.file_name} ({file_analysis.file_type})")
    print(f"  Summary: {file_analysis.summary}")
    print(f"  Key Points: {', '.join(file_analysis.key_points)}")
```

**✅ Success Criteria:**
- [ ] Maintained conversation context with history
- [ ] Analyzed specific files selectively
- [ ] Used structured output schema
- [ ] Received structured, parseable responses

**🏆 Bonus:**
- Implement a chat loop for interactive file Q&A
- Create different assistants for different file types (code reviewer, doc writer, etc.)
- Build a file comparison assistant that analyzes differences
- Implement error handling for missing or corrupted files

---

## 🎓 Kata Complete!

### What You've Accomplished

Congratulations! You've mastered file-based AI interactions with CodeMie:

✅ **Connected** to CodeMie with proper authentication
✅ **Uploaded** multiple files using `bulk_upload`
✅ **Created** a document-aware AI assistant
✅ **Chatted** with your assistant using file context
✅ **Asked** specific questions about file content
✅ **Explored** advanced patterns like conversation history and structured output

You now have the skills to:
- Build document analysis systems
- Create code review assistants
- Develop knowledge-based AI tools
- Process and analyze multiple files simultaneously
- Maintain conversational context with files

### Real-World Applications

This file-based pattern enables powerful use cases:

**Code Review & Analysis:**
- Automated code review assistants
- Security vulnerability scanning
- Style guide enforcement
- Refactoring suggestions

**Document Processing:**
- Contract analysis and summarization
- Report generation from multiple sources
- Documentation quality checks
- Cross-document information extraction

**Knowledge Management:**
- Technical documentation Q&A
- Policy and compliance checking
- Research paper analysis
- Meeting notes summarization

**Data Analysis:**
- Configuration file validation
- Log file analysis and troubleshooting
- Data quality assessment
- Schema comparison and migration

### Next Steps

Ready to build more advanced file-based AI systems?

1. **Multiple File Types**: Handle PDFs, images, spreadsheets
   ```python
   files = [Path("doc.pdf"), Path("data.xlsx"), Path("image.png")]
   upload_response = client.files.bulk_upload(files)
   ```

2. **Batch Processing**: Upload and analyze large document sets
   ```python
   # Upload files in batches
   for batch in file_batches:
       response = client.files.bulk_upload(batch)
       # Process each batch
   ```

3. **File Datasources**: Create persistent file-based knowledge bases
   ```python
   from codemie_sdk.models.datasource import FileDataSourceRequest
   datasource = FileDataSourceRequest(
       name="code_library",
       files=file_paths,
       embeddings_model="text-embedding-ada-002"
   )
   ```

4. **Streaming Responses**: Real-time analysis for large files
   ```python
   chat_request = AssistantChatRequest(
       text="Analyze this large document",
       file_names=file_urls,
       stream=True  # Get progressive responses
   )
   ```

### Resources

- **[CodeMie SDK](https://www.npmjs.com/package/codemie-sdk)**: Official SDK package
- **[CodeMie Documentation](https://codemie-ai.github.io/docs/)**: Complete API reference and guides

**Happy building!** 🚀
