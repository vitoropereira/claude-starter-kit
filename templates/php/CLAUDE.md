# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PHP web application project. Update this section with your specific project description, purpose, and target audience.

**Tech Stack:**
- Backend: PHP (vanilla or framework-based)
- Frontend: HTML5, Tailwind CSS, vanilla JavaScript
- Data: JSON files or database (MySQL/PostgreSQL)
- Server: Apache with .htaccess URL rewriting (or Nginx with PHP-FPM)

## Architecture

### Routing System
The site uses a single entry point (`index.php`) with routing logic. The routing:
1. Reads request parameters or URL path
2. Sets dynamic meta tags (`$pageTitle`, `$pageDescription`) per page
3. Includes header, then the appropriate page file, then footer

### File Structure
```
├── index.php              # Main router and entry point
├── includes/
│   ├── header.php        # Navigation, meta tags, CSS config
│   └── footer.php        # Footer, closing tags, scripts
├── pages/                # Individual page content
│   ├── home.php
│   ├── about.php
│   └── contact.php
├── api/                  # API endpoints (if any)
│   └── endpoint.php
├── data/
│   └── data.json         # Data source files
├── assets/
│   ├── css/custom.css    # Custom styles beyond Tailwind
│   └── js/main.js        # Global JS (mobile menu, animations)
├── .htaccess             # URL rewriting, compression, caching
└── .env.example          # Environment variables template
```

### Key Components

**Header (`includes/header.php`):**
- Contains all `<head>` meta tags (SEO, Open Graph, Twitter Cards)
- CSS framework loading and configuration
- Navigation bar with responsive mobile menu
- Active page highlighting with PHP conditionals

**Pages:**
- Each page in `pages/` is a pure content file (no HTML structure, just sections)
- Pages should not include their own `<html>` or `<body>` tags

**Data Management:**
- Data can be stored in JSON files, database tables, or PHP arrays
- Use structured formats with clear schemas

**JavaScript:**
- `assets/js/main.js`: Mobile menu toggle, animations, smooth scrolling
- Inline JS in page files for page-specific functionality

## Development Workflow

### Local Development
**Requirements:**
- PHP 7.4+ (8.x recommended)
- Apache or Nginx with PHP-FPM
- Composer (for dependency management)
- No build process needed for vanilla PHP projects

**Running Locally:**
1. Set up virtual host pointing to project root (or use `php -S localhost:8000`)
2. Ensure mod_rewrite is enabled (Apache)
3. Copy `.env.example` to `.env` and configure
4. Access via browser

**Apache Configuration:**
The `.htaccess` file handles:
- URL rewriting to index.php
- Gzip compression
- Static file caching
- Security headers

### Code Formatting
- Use php-cs-fixer with PSR-12 rules for code formatting
- JSON files formatted with 4-space indentation
- Install php-cs-fixer: `composer global require friendsofphp/php-cs-fixer`
- Format: `php-cs-fixer fix <file> --rules=@PSR12`

### Git Workflow
- Always write commit messages in English
- Follow conventional commits format
- Save planning documents as `.md` files when doing task breakdowns

## Styling & Design

### Tailwind Configuration
Colors and theme can be configured inline or via tailwind.config.js:
```javascript
tailwind.config = {
    theme: {
        extend: {
            colors: {
                primary: '#2563eb',
                secondary: '#1e40af',
                accent: '#f59e0b',
            }
        }
    }
}
```

### Custom CSS
Custom CSS file contains:
- Gradient backgrounds
- Section spacing utilities
- Container classes
- Card components with hover effects
- Animation classes
- Technology badge styling

### Animations
Fade-in animations using Intersection Observer:
- Elements with `.fade-in` class animate on scroll into view
- Opacity and translateY transitions
- Configurable timing

## Content Management

### Adding Pages
1. Create file in `pages/` directory
2. Add route case in index.php
3. Add navigation link in header.php
4. Set page title and meta description

### API Endpoints
- Place endpoint files in `api/` directory
- Always validate required fields
- Sanitize all inputs to prevent XSS
- Return JSON responses with `success` boolean and `message` string
- Return appropriate HTTP status codes (200, 400, 405, 500)
- Use environment variables for sensitive data

## Code Preferences

- Prefer functions over classes unless absolutely necessary
- Keep files focused and single-purpose
- Use meaningful variable names
- Validate and sanitize all user inputs
- Always provide commit message suggestions after modifications

## Performance & Security

**Performance:**
- Gzip compression enabled via .htaccess
- Static asset caching (1 year for assets)
- Lazy loading for images
- Minimal JavaScript footprint

**Security:**
- Input sanitization via whitelist patterns
- .htaccess protects against common exploits
- Environment variables for sensitive data (API keys, tokens)
- Never commit credentials to repository
- HTTPS redirect in production

## Common Tasks

- **Update site content:** Edit page files in `pages/` directory
- **Add new page:** Create file in `pages/`, add route in index.php, add nav link in header.php
- **Modify styles:** Use Tailwind classes or add to custom.css
- **Update data:** Edit JSON files in `data/` or database records
- **Change colors:** Modify tailwind config
- **Deploy:** Push to production server (FTP, rsync, or CI/CD)
