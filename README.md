# Cloud Resume Challenge Azure

## Table of Contents
1. [Overview](#overview)
2. [What-is-the-cloud-resume-challenge?](#what-is-the-cloud-resume-challenge)
3. [Tech Stack and Tools](#tech-stack-and-tools)
4. [Frontend](#frontend)
   - [HTML](#html)
   - [CSS](#css)
5. [Static Website and Front Door CDN Setup](#static-website-and-front-door-cdn-setup)
   - [Deploying Static Website](#deploying-static-website)
   - [Configuring Azure Front Door](#configuring-azure-front-door)
6. [Custom Domain HTTPS and Cloudflare DNS Setup](#custom-domain-https-and-cloudflare-dns-setup)
7. [Setting up Visitor Count via API and Database](#setting-up-visitor-count-via-api-and-database)
   - [Creating the Database (Cosmos DB)](#71-creating-the-database-cosmos-db)
   - [Creating and Deploying the API with Azure Functions](#72-creating-and-deploying-the-api-with-azure-functions)
     - [Creating the Azure Function Project](#creating-the-azure-function-project)
     - [Testing the Function Locally](#testing-the-function-locally)
     - [Deploying to Azure Function apps](#deploying-to-azure-function-apps)
   - [Connecting the Frontend](#connecting-the-frontend)
8. [Creating our CI/CD Workflow](#creating-our-CI/CD-workflow)
     - [Creating out Frontend workflow](#creating-our-frontend-workflow)
     - [Implementing Unit Testing](#creating-our-frontend-workflow)
     - [Creating out Backend workflow](#creating-our-backend-workflow)
9. [Next Steps](#next-steps)


---

## Overview

This project is my personal cloud-hosted resume. It’s a simple static website served globally via Azure Front Door, with a small serverless API that keeps track of visitor counts. The goal was to learn real-world cloud deployment while keeping everything automated and secure.


**Live Website:**   [https://resume.vanshbhardwaj.com](https://resume.vanshbhardwaj.com)

Skills demonstrated in this project:

- Frontend development with HTML, CSS, and a bit of JavaScript
- Hosting a static site in the cloud with Azure Storage
- Global content delivery via Azure Front Door
- Custom domain setup with HTTPS and Cloudflare DNS management
- Serverless API with Azure Functions to safely handle backend data
- CI/CD automation with GitHub Actions
- Demonstrating infrastructure understanding

---

## What is the Cloud Resume Challenge?

The Cloud Resume Challenge is a small, practical project designed to teach the basics of deploying a real cloud application: a static resume site served from the edge plus a tiny backend for a visitor counter. It’s a great checklist to force you to think about hosting, DNS, HTTPS, a serverless API, and automated deploys — all the parts that matter in real-world cloud work.

**Official challenge instructions:** [https://cloudresumechallenge.dev/docs/the-challenge/azure/](https://cloudresumechallenge.dev)

A few quick notes about how I used the challenge here:

- I followed the Azure variant of the guide and then extended it — adding Front Door, Cloudflare DNS, a Python Azure Function, and GitHub Actions for CI/CD.
- The goal wasn’t just to complete the checklist. It was to make a small, realistic deployment you can iterate on and show to employers.

---

## Tech Stack and Tools

| Tool or Technology | Purpose |
|--------------------|---------|
| HTML | Structure static resume content |
| CSS | Styling and layout |
| JavaScript | Frontend logic and API calls |
| Python | Language for backend API |
| pytest | Run unit tests locally |
| Azure Portal | Configure and manage Azure resources |
| Azure Storage Static Website | Host static frontend files |
| Azure Front Door | Global routing, CDN, and HTTPS termination |
| Cloudflare | DNS management and DNSSEC |
| AFD Managed SSL Certificate | Enable secure HTTPS traffic |
| Azure Cosmos DB | Store and persist visitor count data |
| Azure Functions (Python) | Serverless API to read and update the database |
| Azure Functions Core Tools | Local development and testing of functions |
| Git and GitHub | Version control and source code management |
| curl | Test API endpoints and site availability |
| Web browser | Manual testing and HTTPS verification |

---

## Frontend

To start this project, I needed to create a simple webpage using HTML and CSS. I’ve been playing around with this since I was a kid, so I was able to put one together quickly. It might not be the prettiest yet, but my main focus was learning how to deploy it through Azure. I hope to improve the design later, but for now, getting it up and running was the goal. I also decided to add JavaScript later in the project, since it’s primarily needed when connecting the frontend to my Azure Function API.

### HTML

**Steps taken:**
- Created `index.html` with sections for work experience, education, and skills  

**Full source:** [index.html](./frontend/index.html)

### CSS

**Steps taken:**
- Created `style.css` for layout, fonts, and responsive design  
- Linked CSS file to HTML  

**Full source:** [style.css](./frontend/style.css)

<figure>
   <img src="docs/01-storage-static-website.png" width="600">
   <figcaption>
     Preview of website
   </figcaption>
</figure>

---

## Static Website and Front Door CDN Setup

### Deploying Static Website

**Steps taken:**
1. Created Azure Storage account  
2. Enabled static website hosting  
3. Uploaded HTML and CSS files  
4. Verified the static endpoint  

### Configuring Azure Front Door

Originally, the challenge suggested using a CDN to improve performance, set up a custom domain, and ensure the site only used HTTPS. As of late 2025, that option was replaced with Azure Front Door, which provides a smarter, global way to route traffic. Front Door not only speeds up content delivery like a CDN but also adds advanced routing, security, and high availability across regions, making your site more reliable. I first started by configuring Front Door and turning on HTTPS for secure connections.

**Steps taken:**
1. Created an Azure Front Door profile  
2. Added my Azure Storage static website endpoint as an origin.
3. Created an origin group and routing rules to send traffic for the site hostname to that origin group. 
4. Enabled HTTPS for secure connections  

> *Routing the static website through Front Door required some trial and error. I spent time understanding how endpoints, origin groups, and routing rules interacted, which was a bit confusing at first. After testing different configurations and fixing misconfigurations, I was able to get the routing working correctly. Traffic now flows smoothly through Front Door, with HTTPS enabled and all static content delivered reliably across regions.*

**Screenshots**

| Screenshot | Caption |
|------------|---------|
| `docs/02-frontdoor-origin-group.png` | Front Door origin configuration |
| `docs/05-https-works.png` | HTTPS verification screenshot |

---

## Custom Domain HTTPS and Cloudflare DNS Setup

Now, the project recommends using Azure to create a custom domain, but I chose to use Cloudflare instead. This allowed me to protect my DNS setup from potential spoofing or “man-in-the-middle” attacks by enabling DNSSEC, adding an extra layer of security for my domain.

**Steps taken:**
1. Bought a custom domain through Cloudflare  
2. Added the custom domain in Azure Front Door  
3. Added the TXT record in Cloudflare to verify domain ownership  
4. Configured CNAME in Cloudflare  
5. Verified domain ownership  
6. Made sure HTTPS was enabled  
7. Configured DNSSEC  

> *Connecting Cloudflare’s domain to Azure Front Door had a few challenges. Initially, routing didn’t work because the proxy was enabled on the CNAME record, which prevented Azure Front Door from validating and routing the domain. After setting the CNAME to DNS-only, the routing worked as expected. I also learned that the TXT record for domain verification works independently of the proxy, which made that part straightforward.*

---

## Setting up Visitor Count via API and Database

This project introduces backend integration by requiring the website to retrieve and update a visitor count using a database. While I have worked with APIs before, I had never actually designed and built my own backend architecture from scratch. Figuring out how the frontend, API, and database should securely communicate with each other was easily one of the most challenging parts of the project, but it was also one of the most rewarding because it made everything finally click.

The project specifically requires:
- A database to store the visitor count
- An API to handle read and update operations
- Secure separation between frontend and database
- Deployment of the API to Azure
- Integration with the static website
- To meet these requirements, I implemented the following architecture:
- Frontend (JavaScript) → Azure Function API → Cosmos DB

This design keeps database credentials secure, enforces controlled access to data, and reflects how real-world cloud applications are structured.

---

### Creating the Database (Cosmos DB)

I used serverless Cosmos DB to create the database for storing visitor counts.
Using Cosmos DB allows for globally scalable, low-latency storage while maintaining a simple document structure.

**Database name:** `counter`  
**Container name:** `visitorcount`  
**Item:** `counter`  

**Example document stored in the container:**
```json
{ 
   "id": "counter",
   "count": 36
}
```

This document represents the current visitor count. Each time the API is called, the count value is incremented and updated.

### Creating and Deploying the API with Azure Functions

Instead of letting the frontend talk directly to Cosmos DB, I wanted to make the setup more secure and realistic, so I built an API layer to handle all database operations. 
To do this, I created a Python-based Azure Function with an HTTP trigger..

### Creating the Azure Function Project

I created a new Azure Function project in: `resume-challenge/backend/api/` using the HTTP trigger template.

**Steps taken:**
1. Created a new Azure Function project in `resume-challenge/backend/api/` using the HTTP trigger template.  
2. Added the Cosmos DB connection string to `local.settings.json` for local testing.  
3. Implemented the main function in `function_app.py` to:  
   - Connect to Cosmos DB  
   - Read the current visitor count  
   - Increment the count by 1  
   - Update the item in the database  
   - Return the updated count as JSON  
4. Verified that `.gitignore` excluded sensitive files like `local.settings.json` and the `.venv` folder.

> *Although I have a strong background in Python, working with the ```python azure.functions ``` framework felt almost like learning Python in a new context. I had never used Azure Functions before, so understanding how decorators, triggers, and bindings worked within the Azure environment required a shift in mindset. I relied on Microsoft’s official documentation as a primary reference, along with additional research to better understand how everything fit together. Working with JSON was more familiar, but it still required careful thought to structure responses correctly and ensure the API returned clean, usable data to the frontend.*

###  Testing the Function Locally

Before connecting the frontend, I tested the Azure Function locally to make sure it correctly incremented and returned the visitor count from Cosmos DB.

**Steps taken:**
1. Ran the Azure Function project locally using:  
```bash
func host start
```
2. Verified that the function:
   - Incremented the visitor count in Cosmos DB
   - Returned JSON like ```json { "count": 37 } ```
   - Worked without errors or exceptions
3. Confirmed that the function logic was correct and ready to be deployed to Azure.

### Deploying to Azure Function apps

After confirming the function worked locally, I deployed the Azure Function to the cloud and configured it to work securely with the frontend and Cosmos DB.

**Steps taken:**
1. Created a new Azure Function App in the Azure portal.  
2. Configured **Application Settings**, including the Cosmos DB connection string and any necessary environment variables.  
3. Deployed the local Azure Function project to the Azure Function App.  
4. Configured **CORS** settings to allow requests from the frontend:  
   - Enabled `Access-Control-Allow-Credentials`  
   - Added the custom domain `resume.vanshbhardwaj.com` as an allowed origin  
5. Verified that the deployed function could access Cosmos DB and respond to HTTP requests correctly.

### Connecting the Frontend
With the Azure Function API deployed, I updated the frontend JavaScript to fetch the visitor count and display it on the website.

**Steps taken:**
1. Updated the HTML to include a counter element, e.g., `<span id="counter"></span>`.  
2. Added JavaScript in `script.js` to fetch the visitor count from the deployed Azure Function API:  
```javascript
fetch('https://<your-function-app>.azurewebsites.net/api/getResumeCounter?code=<function-key>')
  .then(response => response.json())
  .then(data => {
    document.getElementById('counter').innerText = data.count;
  })
  .catch(err => console.error(err));
```
3. Uploaded the updated HTML and JS files to the Azure Static Website storage.
4. Verified that visiting the site through the custom domain correctly loads the API and displays the visitor count.

## Creating our CI/CD Workflow

Up until this point, I had been uploading and updating everything manually. For this step, I created a GitHub Actions workflow and configured a Service Principal so GitHub could securely authenticate with Azure and deploy the site automatically. Instead of hardcoding credentials, I stored them as encrypted GitHub secrets and used them in the workflow file. Now, whenever I push changes to the repository, the website updates on its own — which felt like a big shift from manual uploads to a more real-world, automated deployment process.

### Creating our frontend workflow

TThis section automates frontend deployment using GitHub Actions:

- **Version Control** – Code tracked in GitHub with structured commits.
- **CI (Continuous Integration)** – Each push triggers the workflow automatically.
- **CD (Continuous Deployment)** – Updates deploy to Azure Storage without manual steps.

While I had experience being part of a CI/CD workflow, actually creating one from scratch was a different story. This replaced manual uploads with a reliable, repeatable, automated process.

**Steps taken**
1. Created a new GitHub repository for the project.  
2. Reviewed all `.gitignore` files and added a root-level `.gitignore` to ensure no sensitive or unnecessary files were committed.  
3. Created a workflow file at `.github/workflows/frontend-main.yaml`.  
4. Created a Service Principal and assigned it the **Contributor** role using RBAC:
```bash
az ad sp create-for-rbac --name "AzureResumeACG" --role contributor --scopes /subscriptions/****-****-****-**** --sdk-auth
```
5. Stored the generated credentials as encrypted GitHub Secrets.
6. Used the Microsoft GitHub Actions template as a base and modified the YAML file to match my architecture and storage setup.
7. Pushed the code to the repository to trigger the workflow.

> *While doing this I had problems with the template woflow code given by microsoft here:
> https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-static-site-github-actions?tabs=userlevel
> Although the workflow was triggering correctly, the deployment to Azure Static Website storage was failing. After troubleshooting and reviewing the GitHub Actions logs, I found the following error:*
> ```git
> ERROR: The specified blob already exists.
> RequestId:ad9764e0-501e-0051-15d3-9f4098000000
> ErrorCode:BlobAlreadyExists
> If you want to overwrite the existing one, please add --overwrite in your command.
> ```
> *After revisiting the documentation, I added the ```--overwrite```flag in the workflow configuration. Once updated, the deployment worked successfully and the site began updating automatically on each push.*

### Implementing Unit Testing 

While I’d done basic unit testing in college, testing a live API was a whole different challenge. The goal was to ensure my Python logic for incrementing the visitor counter worked before touching the production database. To avoid writing “fake” data to Cosmos DB, I learned mocking—simulating database responses so tests could run safely and reliably.

**Steps taken:**
1. **Project Structure:** Created a `/tests` directory and added `__init__.py` to treat the folder as a package, along with `test_function.py` for the actual test cases.
2. **Environment Setup:** Configured a Python virtual environment `.venv` within the `/api` folder to keep dependencies isolated and manageable.
3. **Dependency Management:** Installed pytest and added it to the requirements.txt file to ensure the testing framework was available both locally and in the GitHub Actions runner.
4. **Writing the Tests:** Developed test cases that "mocked" the Azure Cosmos DB and Azure Functions libraries. Since the official documentation was a bit dense, I used AI to help me identify the specific objects within the Azure SDK that needed to be mocked.
6. **Manual Verification:** Ran the suite locally to ensure a 100% pass rate before attempting to automate the process.
```bash 
source api/.venv/bin/activate
python -m pytest tests
```

>*Mocking was the "brick wall" of this challenge. Digging through the Azure Cosmos DB and Functions libraries was tough, and I eventually used AI to help me bridge the gap on the specific syntax needed to mock the database client. It was a huge "aha!" moment when the tests finally passed, and it taught me how crucial it is to have a testable architecture..*

### Creating our Backend workflow

With the API working and tests passing locally, the final step was automating backend deployment. I set up a full CI/CD pipeline: GitHub automatically runs unit tests (CI) and, if they pass, deploys the updated function to Azure (CD). This ensures the live resume never breaks from a bad update.

**Steps taken:**
1. Workflow Configuration: Created .github/workflows/backend-main.yaml using a standard Microsoft Azure Functions template as the foundation.
2. Integrating CI (Testing): Added a specific step in the `YAML` file to set up the Python environment, install requirements, and run pytest before any deployment happens.

```yaml
    - name: Run Unit Tests
      shell: bash
      run: |
        cd backend/api
        python -m venv .venv
        source .venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        cd ..
        python -m pytest tests -v
```

4. Security & Authentication: Configured an Azure Login action using a Service Principal and GitHub Secrets to allow GitHub to securely talk to my Azure subscription.

```yaml
    - name: 'Login via AzureCLI'
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
```

6. Deployment: SSet up the final step to push the validated code to the Azure Function App only after tests passed.

## Next Steps
- Add resume download option  
- Harden Azure permissions and roles (least privilege)  
- Secure CI/CD pipeline: signed commits, dependency scanning, CodeQL, SBOM, Grype  
- Add test/staging environments with PR deployments and smoke/end-to-end tests  
- Implement monitoring and alerts with Application Insights, Azure Monitor, PagerDuty, and Slack  
- Automate frontend and backend deployments using IaC, pipelines, and smoke tests
