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
     - [Creating the Azure Function Project](#721-creating-the-azure-function-project)
     - [Testing the Function Locally](#722-testing-the-function-locally)
     - [Deploying to Azure Function apps](#723-deploying-to-azure-function-apps)
   - [Connecting the Frontend](#73-connecting-the-frontend)
8. [Next Steps](#next-steps)


---

## Overview

This project is a personal cloud-hosted resume built with Azure Storage Static Website, Azure Front Door, and a custom domain.  

**Live Website:**  
[https://resume.vanshbhardwaj.com](https://resume.vanshbhardwaj.com)

It demonstrates the following skills:

- Frontend development with HTML and CSS  
- Cloud hosting and CDN configuration  
- Custom domain setup with HTTPS  
- DNS management using Cloudflare  

---

## What is the Cloud Resume Challenge?

This project follows the Cloud Resume Challenge guidelines. The challenge requires building and deploying a cloud-hosted resume that demonstrates real-world cloud engineering skills including:

- Hosting a static website in the cloud  
- Using a CDN for global distribution  
- Configuring a custom domain  
- Enabling HTTPS  
- Managing DNS records  
- Demonstrating infrastructure understanding

You can find the instructions here:  
:contentReference[oaicite:0]{index=0}

---

## Tech Stack and Tools

| Tool or Technology | Purpose |
|--------------------|---------|
| HTML | Structure static resume content |
| CSS | Styling and layout |
| :contentReference[oaicite:1]{index=1} Storage Static Website | Host static frontend files |
| :contentReference[oaicite:2]{index=2} Standard | CDN routing and HTTPS termination |
| :contentReference[oaicite:3]{index=3} | DNS management |
| AFD Managed SSL Certificate | Enable secure HTTPS traffic |
| curl or Browser | Verify site availability |
| :contentReference[oaicite:4]{index=4} | CI/CD workflows |

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
2. Added the storage account endpoint as the origin  
3. Configured routing and origin groups  
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

this project introduces backend integration by requiring the website to dynamically retrieve and update a visitor count using a database. The goal is to demonstrate a secure, production-style architecture where the frontend does not communicate directly with the database. Instead, requests flow through an API layer.

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

### 7.1 Creating the Database (Cosmos DB)

I used serverless Cosmos DB to create the database for storing visitor counts.

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

Using Cosmos DB allows for globally scalable, low-latency storage while maintaining a simple document structure.

### 7.2 Creating and Deploying the API with Azure Functions

The project explicitly requires that the frontend must not communicate directly with Cosmos DB. Instead, an API layer must handle all database operations.

To accomplish this, I created a Python based Azure Function with an HTTP trigger.

The API layer is critical for security and architecture best practices:
- Prevents exposing database keys in frontend JavaScript
- Allows validation and control over database operations
- Encapsulates business logic in the backend
- Enables future scalability and maintainability

#### 7.2.1 Creating the Azure Function Project

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

   
#### 7.2.2 Testing the Function Locally

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

#### 7.2.3 Deploying to Azure Function apps

After confirming the function worked locally, I deployed the Azure Function to the cloud and configured it to work securely with the frontend and Cosmos DB.

**Steps taken:**
1. Created a new Azure Function App in the Azure portal.  
2. Configured **Application Settings**, including the Cosmos DB connection string and any necessary environment variables.  
3. Deployed the local Azure Function project to the Azure Function App.  
4. Configured **CORS** settings to allow requests from the frontend:  
   - Enabled `Access-Control-Allow-Credentials`  
   - Added the custom domain `resume.vanshbhardwaj.com` as an allowed origin  
5. Verified that the deployed function could access Cosmos DB and respond to HTTP requests correctly.

#### 7.3 Connecting the Frontend
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

   
## Next Steps
- Add CI/CD pipeline  
- Add analytics  
- Improve accessibility  
- Add resume download option  
