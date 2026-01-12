# SDK: Build a CV Review Workflow with Python

Welcome to the CV Review Workflow kata! In this hands-on exercise, you'll learn how to build a multi-stage AI workflow that automatically reviews CVs/resumes. You'll create two AI assistants working in sequence: a screener that performs initial validation and an evaluator that provides detailed analysis.

By the end of this kata, you'll understand how to orchestrate multiple AI assistants in a workflow, process uploaded documents, and build practical automation for real-world HR tasks.

---

## 🎯 Challenge 1: Set Up Your Environment and SDK Client

**Goal:** Install dependencies and establish an authenticated connection to CodeMie services

### Instructions

Let's get your development environment ready for building CV review workflows.

1. **Install required dependencies**:

Create a `requirements.txt` file:
```txt
codemie-sdk-python
PyYAML
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

3. **Create your main script** called `cv_review_workflow.py`:
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
python cv_review_workflow.py
```

**✅ Success Criteria:**
- [ ] Dependencies installed successfully from requirements.txt
- [ ] Configuration file created with your credentials
- [ ] Script runs and prints connection confirmation
- [ ] Authentication token is displayed

**💡 Tip:** Keep your credentials secure! Never commit `example.properties` to version control. Add it to `.gitignore`.

---

## 🎯 Challenge 2: Create CV Evaluator Assistant

**Goal:** Create a real assistant that will perform detailed CV evaluation

### Instructions

We'll create a **real assistant** (CV Evaluator) that persists in CodeMie, and later use a **virtual assistant** (CV Screener) defined directly in the workflow. This demonstrates both approaches!

1. **Get available LLM models and define project**:
```python
# Get available LLM models
models = client.llms.list()
default_model = models[0].base_name
print(f"Using model: {default_model}")

# Define your project (from config)
user_project = props.get("project", "user_email@epam.com") # personal user project
```

2. **Create the CV Evaluator assistant**:
```python
from codemie_sdk.models.assistant import AssistantCreateRequest

# Create CV Evaluator as a real assistant
evaluator_request = AssistantCreateRequest(
    name="CV Evaluator - Senior HR Analyst",
    description="Senior HR analyst specializing in comprehensive CV evaluation and hiring recommendations",
    system_prompt="""You are a senior HR analyst specializing in CV evaluation.

Your role is to provide detailed analysis of CVs that passed initial screening:
1. Evaluate professional experience depth and relevance
2. Assess skills and qualifications
3. Analyze career progression and achievements
4. Identify strengths and potential concerns
5. Provide hiring recommendation with justification

Generate a comprehensive evaluation report with:
- Overall rating (1-10)
- Strengths (top 3)
- Areas of concern (if any)
- Skills match analysis
- Final recommendation (Strong Hire / Hire / Maybe / Pass)""",
    toolkits=[],
    project=user_project,
    llm_model_type=default_model,
    context=[],
    conversation_starters=[],
    mcp_servers=[],
    assistant_ids=[]
)

# Create the assistant
create_response = client.assistants.create(evaluator_request)

# The create response returns basic info - we need to wait and fetch the full assistant
# Wait a moment for the assistant to be fully created
from time import sleep
sleep(3)

# Retrieve the assistant by listing (it will be the most recently created)
assistants = client.assistants.list(
    minimal_response=True,
    scope="visible_to_user",
    per_page=50
)

# Find our assistant by name
evaluator_assistant = next(
    (a for a in assistants if a.name == "CV Evaluator - Senior HR Analyst"),
    None
)

if evaluator_assistant:
    print(f"✅ Created CV Evaluator assistant!")
    print(f"   ID: {evaluator_assistant.id}")
    print(f"   Name: {evaluator_assistant.name}")

    # Save the assistant ID for later use
    evaluator_assistant_id = evaluator_assistant.id
else:
    raise Exception("Failed to create assistant")
```

3. **Define the CV Screener as a virtual assistant** (we'll use this in the workflow):
```python
# CV Screener will be a virtual assistant (defined in workflow YAML only)
screener_config = {
    "id": "cv_screener",
    "model": default_model,
    "system_prompt": """You are a CV screening specialist. Your role is to perform initial validation of CVs.

Your tasks:
1. Check if the document is actually a CV/resume
2. Verify it contains essential sections (contact info, experience, education)
3. Assess completeness and formatting quality
4. Flag any red flags (gaps, formatting issues, missing critical info)

Provide a brief screening report with:
- Document type confirmation
- Completeness score (1-10)
- Key observations
- Recommendation: PASS to detailed review or REJECT""",
}

print("✅ Defined CV Screener configuration (virtual assistant)")
```

**✅ Success Criteria:**
- [ ] Real assistant (CV Evaluator) created successfully in CodeMie
- [ ] Assistant ID is displayed and saved
- [ ] Virtual assistant (CV Screener) configuration is defined
- [ ] Both assistants have clear, specific system prompts

**💡 Tip:** Real assistants persist in CodeMie and can be reused across workflows. Virtual assistants exist only within a specific workflow definition.

**🏆 Bonus:** Customize the evaluator's system prompt to match specific job requirements or your company's hiring criteria.

---

## 🎯 Challenge 3: Build Your Workflow with Mixed Assistants

**Goal:** Create a workflow that uses both virtual assistant (screener) and real assistant (evaluator)

### Instructions

Now we'll create a workflow that orchestrates both assistants. The workflow uses YAML configuration to define assistants, states (stages), and the execution flow. Notice how we mix virtual and real assistants!

```python
import yaml
from codemie_sdk.models.workflow import WorkflowCreateRequest, WorkflowMode

# Define workflow configuration
workflow_yaml = {
    "assistants": [
        # Virtual assistant defined inline
        screener_config,
        # Real assistant referenced by ID
        {
            "id": "cv_evaluator",
            "assistant_id": evaluator_assistant_id,  # Reference the real assistant
        },
    ],
    "states": [
        {
            "id": "screening",
            "assistant_id": "cv_screener",  # Uses virtual assistant
            "task": "Review the uploaded CV and provide initial screening assessment. Focus on document completeness and format quality.",
            "next": {
                "state_id": "evaluation"
            }
        },
        {
            "id": "evaluation",
            "assistant_id": "cv_evaluator",  # Uses real assistant
            "task": "Conduct detailed evaluation of the CV. Provide comprehensive analysis with hiring recommendation.",
            "next": {
                "state_id": "end"
            }
        }
    ]
}

# Convert to YAML string
yaml_config = yaml.dump(workflow_yaml, sort_keys=False, allow_unicode=True)

# Create workflow
workflow_request = WorkflowCreateRequest(
    name="CV Review Pipeline",
    description="Automated two-stage CV review: virtual screener + real evaluator",
    project=user_project,
    yaml_config=yaml_config,
    mode=WorkflowMode.SEQUENTIAL,
)

workflow_response = client.workflows.create_workflow(workflow_request)
workflow_id = workflow_response["id"]

print(f"✅ Workflow created successfully!")
print(f"   Workflow ID: {workflow_id}")
print(f"   Name: {workflow_response['name']}")
print(f"   Mix: Virtual screener + Real evaluator")
```

**✅ Success Criteria:**
- [ ] Workflow YAML includes virtual assistant (inline definition)
- [ ] Workflow YAML references real assistant by ID
- [ ] Two states defined: screening and evaluation
- [ ] States are properly chained (screening → evaluation → end)
- [ ] Workflow is created successfully
- [ ] Workflow ID is retrieved

**💡 Tip:** Virtual assistants (inline config) are great for one-off workflows. Real assistants (referenced by ID) are reusable across multiple workflows and persist in CodeMie.

**🏆 Bonus:** Try creating a workflow with two real assistants to see how they can be reused across different workflows!

---

## 🎯 Challenge 4: Upload a Sample CV

**Goal:** Prepare a test CV file for workflow execution

### Instructions

Let's create a sample CV file and upload it to CodeMie. The workflow will process this document through both review stages.

First, create a sample CV file or use an existing one. Here's how to create a simple test CV:

```python
# Create a sample CV (you can also use your own CV file)
sample_cv = """
JOHN DOE
Email: john.doe@email.com | Phone: (555) 123-4567
LinkedIn: linkedin.com/in/johndoe

PROFESSIONAL SUMMARY
Experienced software engineer with 5+ years in full-stack development.
Specialized in Python, cloud architecture, and AI/ML integration.

WORK EXPERIENCE

Senior Software Engineer | TechCorp Inc.
January 2021 - Present
- Led development of microservices architecture serving 1M+ users
- Implemented CI/CD pipelines reducing deployment time by 60%
- Mentored team of 4 junior developers

Software Engineer | StartupXYZ
June 2018 - December 2020
- Built RESTful APIs using Python/Django framework
- Designed and optimized PostgreSQL database schemas
- Collaborated with product team on feature development

EDUCATION

Bachelor of Science in Computer Science
State University, 2018
GPA: 3.7/4.0

SKILLS
Languages: Python, JavaScript, SQL, Go
Frameworks: Django, React, FastAPI
Cloud: AWS, Docker, Kubernetes
Tools: Git, Jenkins, Terraform
"""

# Save to file
with open("sample_cv.txt", "w") as f:
    f.write(sample_cv)

print("✅ Sample CV created: sample_cv.txt")

# Upload the file
from pathlib import Path

file_path = Path("sample_cv.txt")
upload_response = client.files.bulk_upload([file_path])

file_url = upload_response.files[0].file_url
print(f"✅ CV uploaded successfully!")
print(f"   File URL: {file_url}")
```

**✅ Success Criteria:**
- [ ] Sample CV file is created (or existing CV is ready)
- [ ] File is uploaded using `bulk_upload` method
- [ ] File URL is retrieved from upload response
- [ ] Success message confirms upload

**💡 Tip:** You can upload PDF, DOCX, or TXT files. The AI assistants can process various document formats.

**🏆 Bonus:** Create multiple CV samples with different quality levels to test how the workflow handles various scenarios.

---

## 🎯 Challenge 5: Execute the CV Review Workflow

**Goal:** Run the workflow and retrieve the complete review results

### Instructions

Now for the exciting part - let's execute the workflow with the uploaded CV and see both assistants in action!

```python
import time

# Execute the workflow with the uploaded CV
execution_response = client.workflows.run(
    workflow_id=workflow_id,
    user_input="Please review this CV for a Senior Software Engineer position.",
    file_name=file_url,
)

print("🚀 Workflow execution started...")
print(f"   User input: {execution_response.get('prompt', 'N/A')}")

# Wait a moment for the workflow to start
time.sleep(3)

# Get execution service
executions_service = client.workflows.executions(workflow_id)

# List executions to find ours
executions = executions_service.list()
if executions:
    latest_execution = executions[0]
    execution_id = latest_execution.execution_id

    print(f"✅ Execution found: {execution_id}")
    print(f"   Status: {latest_execution.status}")

    # Wait for execution to complete
    print("\n⏳ Waiting for workflow to complete...")

    max_attempts = 60  # 60 attempts * 2 seconds = 2 minutes max wait
    for attempt in range(max_attempts):
        execution_details = executions_service.get(execution_id)
        status = execution_details.status

        print(f"   Attempt {attempt + 1}: Status = {status}")

        if status in ["Succeeded", "Failed", "Aborted"]:
            break

        time.sleep(2)

    # Get execution states (workflow stages)
    states_service = executions_service.states(execution_id)
    states = states_service.list()

    print(f"\n📊 Workflow completed with {len(states)} stages:")

    # Display results from each stage
    for state in states:
        print(f"\n{'=' * 60}")
        print(f"Stage: {state.id.upper()}")
        print(f"Status: {state.status}")
        print(f"{'=' * 60}")

        # Get the output from this stage
        state_output = states_service.get_output(state_id=state.id)
        print(state_output.output)

    print("\n✅ CV Review Workflow Completed Successfully!")

else:
    print("❌ No executions found. The workflow may still be initializing.")
```

**✅ Success Criteria:**
- [ ] Workflow execution starts successfully
- [ ] Execution status can be retrieved
- [ ] Workflow completes (status becomes "Succeeded")
- [ ] Both stages (screening and evaluation) produce outputs
- [ ] Screening report is displayed
- [ ] Detailed evaluation report is displayed

**💡 Tip:** The workflow executes asynchronously. The polling loop checks status every 2 seconds until completion.

**🏆 Bonus:** Parse the output to extract structured data like scores and recommendations, then store them in a database or export to a spreadsheet.

---

## 🎯 Challenge 6: Clean Up Resources

**Goal:** Learn resource lifecycle management by cleaning up workflow and assistant

### Instructions

It's good practice to clean up test resources when you're done experimenting. Let's delete both the workflow and the real assistant we created.

1. **Delete the workflow**:
```python
# List workflows to verify it exists
workflows = client.workflows.list(per_page=50)
print(f"\n📋 Found {len(workflows)} workflows in your project")

# Find our workflow
our_workflow = next((w for w in workflows if w.id == workflow_id), None)

if our_workflow:
    print(f"\nWorkflow to delete:")
    print(f"  Name: {our_workflow.name}")
    print(f"  ID: {our_workflow.id}")
    print(f"  Created: {our_workflow.created_date}")

    # Delete the workflow
    client.workflows.delete(workflow_id)
    print(f"\n✅ Workflow deleted successfully!")
else:
    print(f"\n❌ Workflow {workflow_id} not found")
```

2. **Delete the real assistant**:
```python
# Delete the CV Evaluator assistant
print(f"\nDeleting assistant: {evaluator_assistant.name}")
print(f"  ID: {evaluator_assistant_id}")

client.assistants.delete(evaluator_assistant_id)
print(f"✅ Assistant deleted successfully!")
```

3. **Verify cleanup**:
```python
# List assistants to confirm deletion
my_assistants = client.assistants.list(
    minimal_response=True,
    scope="created_by_user",
    per_page=50
)

print(f"\n📋 Remaining assistants: {len(my_assistants)}")
for assistant in my_assistants:
    print(f"  - {assistant.name}")

print(f"\n💡 Tip: Virtual assistants (CV Screener) don't need cleanup - they only exist within the workflow definition")
```

**✅ Success Criteria:**
- [ ] Workflow is successfully deleted
- [ ] Real assistant is successfully deleted
- [ ] Verification shows resources are removed
- [ ] Confirmation messages are displayed

**💡 Tip:** Only real assistants need to be deleted. Virtual assistants defined inline in workflow YAML are automatically removed when the workflow is deleted.

**🏆 Bonus:** Build a cleanup script that finds and removes all test resources created during development by filtering on name patterns.

---

## 🎓 Kata Complete!

Congratulations! You've successfully built an automated CV review workflow using the CodeMie Python SDK.

### What You've Accomplished

✅ Set up the CodeMie Python SDK and authenticated
✅ Created a **real assistant** that persists in CodeMie
✅ Defined a **virtual assistant** within workflow configuration
✅ Built a multi-stage workflow mixing real and virtual assistants
✅ Uploaded and processed documents through the workflow
✅ Retrieved and analyzed results from multiple workflow stages
✅ Learned complete resource lifecycle management (workflows + assistants)

### Key Concepts Mastered

🎯 **Real vs Virtual Assistants:**
- **Real Assistants:** Created via API, persist in CodeMie, reusable across workflows
- **Virtual Assistants:** Defined inline in workflow YAML, exist only within that workflow

🎯 **When to Use Each:**
- Use **real assistants** for shared logic, reusable components, or assistants you'll chat with directly
- Use **virtual assistants** for workflow-specific roles, one-off tasks, or rapid prototyping

### Real-World Applications

This workflow pattern can be adapted for many use cases:

- **Document Processing**: Invoice validation, contract review, compliance checks
- **Content Moderation**: Initial filtering followed by detailed policy review
- **Customer Support**: Triage → Detailed Analysis → Response Generation
- **Quality Assurance**: Automated testing with multi-level validation
- **Research**: Literature screening → Detailed analysis → Summary generation

### Next Steps

Ready to build more advanced workflows? Try these powerful patterns:

1. **Conditional Routing with Switch States**: Route CVs based on screening scores
   ```python
   {
       "id": "screening",
       "assistant_id": "cv_screener",
       "task": "Review CV and provide score (1-10)",
       "output_schema": '{"score": 0, "recommendation": "string"}',
       "next": {
           "switch": {
               "cases": [
                   {
                       "condition": "context.screening.output.score >= 7",
                       "state_id": "detailed_evaluation"
                   },
                   {
                       "condition": "context.screening.output.score >= 4",
                       "state_id": "basic_review"
                   }
               ],
               "default": "rejection_notice"
           }
       }
   }
   ```

2. **Structured Output with Pydantic Models**: Extract JSON data from workflow results
   ```python
   from pydantic import BaseModel

   class CVEvaluation(BaseModel):
       overall_rating: int
       strengths: list[str]
       concerns: list[str]
       recommendation: str

   # In your workflow state
   state = {
       "id": "evaluation",
       "assistant_id": "cv_evaluator",
       "task": "Evaluate CV and return structured data",
       "output_schema": CVEvaluation.model_json_schema()
   }
   ```

3. **Parallel CV Processing**: Process multiple candidates simultaneously
   ```python
   # Upload multiple CVs
   cv_files = ["cv1.pdf", "cv2.pdf", "cv3.pdf"]
   file_urls = [client.files.bulk_upload([Path(f)]).files[0].file_url
                for f in cv_files]

   # Run workflows in parallel for each CV
   from concurrent.futures import ThreadPoolExecutor

   def process_cv(file_url):
       return client.workflows.run(workflow_id, file_name=file_url)

   with ThreadPoolExecutor(max_workers=3) as executor:
       results = list(executor.map(process_cv, file_urls))
   ```

### Resources

- [CodeMie Python SDK on PyPI](https://pypi.org/project/codemie-sdk-python/)
- [Workflow YAML Configuration Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [CodeMie Documentation](https://codemie-ai.github.io/docs/)

Happy coding! 🚀
