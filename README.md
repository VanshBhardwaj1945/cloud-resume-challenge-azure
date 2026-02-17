# Cloud Resume Challenge Azure

## Table of Contents
1. [Overview](#overview)
2. [What-is-the-cloud-resume-challenge?](#what-is-the-cloud-resume-challenge?)
3. [Tech Stack and Tools](#tech-stack-and-tools)
4. [Frontend](#frontend)
   - [HTML](#html)
   - [CSS](#css)
5. [Static Website and Front Door CDN Setup](#static-website-and-front-door-cdn-setup)
   - [Deploying Static Website](#deploying-static-website)
   - [Configuring Azure Front Door](#configuring-azure-front-door)
6. [Custom Domain HTTPS and Cloudflare DNS Setup](#custom-domain-https-and-cloudflare-dns-setup)
7. [Next Steps](#next-steps)

---

## Overview

This project is a personal cloud hosted resume built with Azure Storage Static Website, Azure Front Door, and a custom domain. 

**Live Website:**  

https://resume.vanshbhardwaj.com

It demonstrates the following skills:

- Frontend development with HTML and CSS  
- Cloud hosting and CDN configuration  
- Custom domain setup with HTTPS  
- DNS management using Cloudflare  
 

---

#

## What is the cloud resume challenge?
This project follows the Cloud Resume Challenge guidelines. The challenge requires building and deploying a cloud hosted resume that demonstrates real world cloud engineering skills including:

- Hosting a static website in the cloud  
- Using a CDN for global distribution  
- Configuring a custom domain  
- Enabling HTTPS  
- Managing DNS records  
- Demonstrating infrastructure understanding

You can find the link to the instructions here: 
https://cloudresumechallenge.dev/docs/the-challenge/azure/

---

## Tech Stack and Tools

| Tool or Technology | Purpose |
|--------------------|---------|
| HTML | Structure static resume content |
| CSS | Styling and layout |
| Azure Storage Static Website | Host static frontend files |
| Azure Front Door Standard | CDN routing and HTTPS termination |
| Cloudflare | DNS management |
| AFD Managed SSL Certificate | Enable secure HTTPS traffic |
| curl or Browser | Verify site availability |
| github / git | CI/CD workflows|
---

## Frontend

### HTML

**What was done**

* Created `index.html` with sections for work experience education and skills  

**Full source:** [index.html](./frontend/index.html)

---

### CSS
**What was done**

* Created `style.css` for layout fonts and responsive design  
* Linked CSS file to HTML  

**Full source:** [style.css](./frontend/style.css)

<figure>
   <img src="docs/01-storage-static-website.png" width="600">
  <figcaption>
    Preview of website
  </figcaption>
</figure>

**Screenshots**


| Screenshot | Caption |
|------------|---------|
| `docs/02-frontdoor-origin-group.png` | Front Door origin configuration |
| `docs/05-https-works.png` | HTTPS verification screenshot |

## Static Website and Front Door CDN Setup

### Deploying Static Website
- Created Azure Storage account  
- Enabled static website hosting  
- Uploaded HTML and CSS files  
- Verified static endpoint  

### Configuring Azure Front Door

Originally, the challenge suggested using a CDN to improve performance, set up a custom domain, and ensure the site only used HTTPS. As of late 2025, that option was replaced with **Azure Front Door**, which provides a smarter, global way to route traffic. Front Door not only speeds up content delivery like a CDN but also adds advanced routing, security, and high availability across regions, making your site more reliable. I first started by configuring Front Door and turning on HTTPS for secure connections.

**Steps taken:**
1. Created an Azure Front Door profile
2. Added the storage account endpoint as the origin
3. Configured routing and origin groups
4.  Enabled HTTPS for secure connections

> Routing the static website through Front Door required some trial and error. I spent time understanding how endpoints, origin groups, and routing rules interacted, which was a bit confusing at first. After testing different configurations and identifying misconfigurations, I was able to get the routing working correctly. Finally, traffic flowed smoothly through Front Door, with HTTPS enabled and all static content delivered reliably across regions.


---

## Custom Domain HTTPS and Cloudflare DNS Setup

Now, the project recommends using Azure to create a custom domain, but I chose to use Cloudflare instead. This allowed me to protect my DNS setup from potential spoofing or “man-in-the-middle” attacks by enabling DNSSEC, adding an extra layer of security for my domain. 

- Bought a custom domain through cloudfare
- Added custom domain in Azure Front Door
- Added the TXT record in Cloudflare to verify domain ownership
- Configured CNAME in Cloudflare  
- Verified domain ownership
- Made sure HHTPS was Enabled
- Configured DNSSEC

> Rout

---

## Next Steps
- Add CI CD pipeline  
- Add analytics  
- Improve accessibility  
- Add resume download option  
