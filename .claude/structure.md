# Project Structure Guidelines

## Standard Directory Organization

- `/src` - All source code files
  - `/components` - Reusable UI components
  - `/pages` or `/routes` - Page-level components and route handlers
  - `/lib` or `/utils` - Utility functions and helpers
  - `/services` - Business logic and external service integrations
  - `/hooks` - Custom React hooks (if using React)
  - `/types` - TypeScript type definitions and interfaces
  - `/constants` - Application constants and configuration
  - `/styles` - Global styles and theme files
  - `/assets` - Static assets (images, fonts, icons)
- `/public` - Publicly accessible static files (favicon, robots.txt, etc.)
- `/tests` or `/src/__tests__` - Test files
- `/migrations` - Database migration files
- `/scripts` - Build scripts, utilities, and automation
- `/config` - Configuration files for different environments
- `/docs` - Project documentation

## File Placement Rules

- ALWAYS place components in `/src/components`
- ALWAYS place utility functions in `/src/lib` or `/src/utils`
- ALWAYS place API routes/handlers in `/src/routes` or `/src/pages/api`
- ALWAYS place database models in `/src/models`
- ALWAYS place middleware in `/src/middleware`
- ALWAYS place type definitions in `/src/types` (for shared types)
- ALWAYS place test files next to the files they test OR in `/tests` directory
- NEVER place source code files in root directory
- NEVER place configuration files inside `/src` (except module-specific configs)

## Public vs Source Assets

**Use `/public` for:**
- Files that need exact URLs (favicon.ico, robots.txt, sitemap.xml)
- Files served directly without processing (manifest.json, browserconfig.xml)
- Static files referenced in HTML meta tags or external services
- Large media files that shouldn't be bundled
- Files that must keep their exact filename (og-image.png at specific path)

**Use `/src/assets` for:**
- Images imported in components (will be processed/optimized by bundler)
- Fonts loaded via CSS @font-face
- Icons and images that benefit from bundling and hashing
- SVGs imported as components
- Assets that should be optimized and cache-busted

**Rule of thumb:** If the file needs to be at a specific URL path and referenced externally, use `/public`. If it's imported/used by your source code, use `/src/assets`.

## Configuration Files

- Root level: `package.json`, `tsconfig.json`, `.env.example`, `.gitignore`, `README.md`
- Framework configs: `vite.config.ts`, `next.config.js`, etc. in root
- Tool configs: `.eslintrc`, `.prettierrc`, `jest.config.js` in root

## Naming Conventions

- Use lowercase with hyphens for directories: `user-profile`, `api-client`
- Use PascalCase for component files: `UserProfile.js`, `Button.js`
- Use camelCase for utility/function files: `formatDate.ts`, `apiClient.ts`
- Use `.test.ts`, `.spec.ts` or `.e2e.ts` suffix for test files

## Organization Principles

- Group by feature when project grows large (e.g., `/src/features/auth`, `/src/features/dashboard`)
- Avoid deep nesting (max 3-4 levels)
- One component/function per file (with exceptions for small, tightly coupled helpers)

## Before Creating New Files

1. Verify you're not duplicating existing functionality
2. Follow the established patterns and directory structure (see File Placement Rules above)
