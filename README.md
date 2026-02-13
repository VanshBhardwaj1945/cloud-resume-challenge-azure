# Cloud Resume Challenge Azure

## Table of Contents
1. [Overview](#overview)
2. [Resume Challenge Directions](#resume-challenge-directions)
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

## Resume Challenge Directions
This project follows the Cloud Resume Challenge guidelines. The challenge requires building and deploying a cloud hosted resume that demonstrates real world cloud engineering skills including:

- Hosting a static website in the cloud  
- Using a CDN for global distribution  
- Configuring a custom domain  
- Enabling HTTPS  
- Managing DNS records  
- Demonstrating infrastructure understanding  

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

---

## Frontend

### HTML
**What was done**

- Created `index.html` with sections for work experience, education, and skills  
- Used semantic HTML structure  

**Screenshots**

| Screenshot | Caption |
|------------|---------|
| `docs/01-html-index.png` | HTML file structure |

---

### CSS
**What was done**

- Created `style.css` for layout, fonts, and responsive design  
- Linked CSS file to HTML  

**Screenshots**

| Screenshot | Caption |
|------------|---------|
| `docs/02-css-style.png` | CSS styling applied |

---

## Static Website and Front Door CDN Setup

### Deploying Static Website
- Created Azure Storage account  
- Enabled static website hosting  
- Uploaded HTML and CSS files  
- Verified static endpoint  

### Configuring Azure Front Door
- Created Front Door profile  
- Added storage endpoint as origin  
- Configured routing  
- Enabled managed HTTPS certificate  

---

## Custom Domain HTTPS and Cloudflare DNS Setup
- Added custom domain in Azure Front Door  
- Configured CNAME in Cloudflare  
- Verified domain ownership  
- Enabled HTTPS  

---

## Next Steps
- Add CI CD pipeline  
- Add analytics  
- Improve accessibility  
- Add resume download option  
