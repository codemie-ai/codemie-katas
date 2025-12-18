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

## 🎯 Challenge 2: Create Two Assistants for CV Review

**Goal:** Set up two AI assistants with distinct roles in the review process

### Instructions

We'll create two virtual assistants with specific responsibilities:
1. **CV Screener:** Performs initial validation
2. **CV Evaluator:** Conducts detailed analysis

```python
# Get available LLM models
models = client.llms.list()
default_model = models[0].base_name
print(f"Using model: {default_model}")

# Assistant 1: CV Screener
screener_assistant = {
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

# Assistant 2: CV Evaluator
evaluator_assistant = {
    "id": "cv_evaluator",
    "model": default_model,
    "system_prompt": """You are a senior HR analyst specializing in CV evaluation.

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
}

print("✅ Created CV Screener assistant")
print("✅ Created CV Evaluator assistant")
```

**✅ Success Criteria:**
- [ ] Both assistant configurations are created
- [ ] Screener focuses on initial validation
- [ ] Evaluator focuses on detailed analysis
- [ ] System prompts are clear and specific
- [ ] Success messages confirm creation

**🏆 Bonus:** Customize the system prompts to match specific job requirements or company culture.

---

## 🎯 Challenge 3: Build Your First Workflow

**Goal:** Assemble a two-stage workflow that chains both assistants sequentially

### Instructions

Now we'll create a workflow that orchestrates both assistants. The workflow uses YAML configuration to define assistants, states (stages), and the execution flow.

```python
import yaml
from codemie_sdk.models.workflow import WorkflowCreateRequest, WorkflowMode

# Define workflow configuration
workflow_yaml = {
    "assistants": [
        screener_assistant,
        evaluator_assistant,
    ],
    "states": [
        {
            "id": "screening",
            "assistant_id": "cv_screener",
            "task": "Review the uploaded CV and provide initial screening assessment. Focus on document completeness and format quality.",
            "next": {
                "state_id": "evaluation"
            }
        },
        {
            "id": "evaluation",
            "assistant_id": "cv_evaluator",
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
    description="Automated two-stage CV review process with screening and detailed evaluation",
    project=props["project"],
    yaml_config=yaml_config,
    mode=WorkflowMode.SEQUENTIAL,
)

workflow_response = client.workflows.create_workflow(workflow_request)
workflow_id = workflow_response["id"]

print(f"✅ Workflow created successfully!")
print(f"   Workflow ID: {workflow_id}")
print(f"   Name: {workflow_response['name']}")
```

**✅ Success Criteria:**
- [ ] Workflow YAML structure includes both assistants
- [ ] Two states defined: screening and evaluation
- [ ] States are properly chained (screening → evaluation → end)
- [ ] Workflow is created successfully
- [ ] Workflow ID is retrieved

**💡 Tip:** The `next` field in each state determines the execution order. The "end" state_id terminates the workflow.

**🏆 Bonus:** Explore conditional routing by adding a third state that only executes if the screening score is above a threshold.

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

**Goal:** Learn workflow lifecycle management by cleaning up test resources

### Instructions

It's good practice to clean up test resources when you're done experimenting. Here's how to delete the workflow:

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

# Optionally, delete the uploaded file
print(f"\n💡 Tip: Uploaded files can be managed through the CodeMie dashboard")
```

**✅ Success Criteria:**
- [ ] Workflow is successfully retrieved before deletion
- [ ] Workflow deletion completes without errors
- [ ] Confirmation message is displayed

**🏆 Bonus:** Build a script that archives workflow execution results before deletion for audit purposes.

---

## 🎓 Kata Complete!

Congratulations! You've successfully built an automated CV review workflow using the CodeMie Python SDK.

### What You've Accomplished

✅ Set up the CodeMie Python SDK and authenticated
✅ Created two specialized AI assistants with distinct roles
✅ Built a multi-stage workflow with sequential execution
✅ Uploaded and processed documents through the workflow
✅ Retrieved and analyzed results from multiple workflow stages
✅ Learned workflow lifecycle management and cleanup

### Real-World Applications

This workflow pattern can be adapted for many use cases:

- **Document Processing**: Invoice validation, contract review, compliance checks
- **Content Moderation**: Initial filtering followed by detailed policy review
- **Customer Support**: Triage → Detailed Analysis → Response Generation
- **Quality Assurance**: Automated testing with multi-level validation
- **Research**: Literature screening → Detailed analysis → Summary generation

### Next Steps

Want to level up your workflow skills? Try these challenges:

1. **Add Conditional Logic**: Make the evaluator stage conditional based on screening results
2. **Parallel Processing**: Create a workflow that processes multiple CVs in parallel
3. **Integration**: Connect your workflow to external systems (ATS, email, Slack)
4. **Custom Scoring**: Add structured output schemas to extract numeric scores
5. **Human-in-the-Loop**: Add approval steps between automated stages

### Resources

- [CodeMie Python SDK on PyPI](https://pypi.org/project/codemie-sdk-python/)
- [Workflow YAML Configuration Documentation](https://codemie-ai.github.io/docs/user-guide/workflows/configuration/)
- [CodeMie Documentation](https://codemie-ai.github.io/docs/)

Happy coding! 🚀
