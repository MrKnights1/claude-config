# Project Structure Guidelines

## Standard Directory Organization

### Web Application (Frontend/Fullstack)
```
project-root/
├── src/                      # All source code
│   ├── components/           # Reusable UI components
│   ├── pages/                # Page-level components / route handlers
│   ├── layouts/              # Page layout components
│   ├── features/             # Feature-based modules (alternative)
│   ├── lib/                  # Utility functions and helpers
│   ├── services/             # API clients, external integrations
│   ├── hooks/                # Custom hooks (React/Vue)
│   ├── stores/               # State management (Redux, Zustand, Pinia)
│   ├── types/                # TypeScript definitions
│   ├── constants/            # Application constants
│   ├── styles/               # Global styles and themes
│   └── assets/               # Images, fonts, icons (bundled)
├── public/                   # Static files (served as-is)
├── tests/                    # Test files (alternative to co-location)
├── migrations/               # Database migrations
├── scripts/                  # Build and automation scripts
├── config/                   # Environment configs
└── docs/                     # Documentation
```

### Backend API
```
project-root/
├── src/
│   ├── routes/               # API route handlers
│   ├── controllers/          # Request/response handling
│   ├── services/             # Business logic
│   ├── models/               # Database models/entities
│   ├── middleware/           # Express/Koa middleware
│   ├── validators/           # Input validation schemas
│   ├── utils/                # Helper functions
│   ├── types/                # TypeScript definitions
│   └── config/               # App configuration
├── tests/
├── migrations/
├── seeds/                    # Database seed data
└── scripts/
```
---

## File Placement Rules

### Source Code
- ALWAYS place source code in `/src` directory
- ALWAYS place components in `/src/components`
- ALWAYS place utility functions in `/src/lib` or `/src/utils`
- ALWAYS place API routes in `/src/routes` or `/src/pages/api`
- ALWAYS place database models in `/src/models`
- ALWAYS place middleware in `/src/middleware`
- ALWAYS place type definitions in `/src/types`
- NEVER place source code files in root directory
- NEVER mix source and configuration in same directory

### Tests
- Place all tests in `/tests` directory mirroring `/src` structure
- Place integration tests in `/tests/integration`
- Place E2E tests in `/tests/e2e`

### Configuration
- Root level: `package.json`, `tsconfig.json`, `.env.example`, `.gitignore`
- Framework configs in root: `vite.config.ts`, `next.config.js`, etc.
- Tool configs in root: `.eslintrc`, `.prettierrc`, `jest.config.js`
- NEVER place config files inside `/src`

---


## Public vs Source Assets

### Use `/public` for:
- Files needing exact URLs: `favicon.ico`, `robots.txt`, `sitemap.xml`
- Files served without processing: `manifest.json`
- Files referenced in HTML meta tags
- Large media files that shouldn't be bundled
- Files for external services (verification files)

### Use `/src/assets` for:
- Images imported in code (bundler optimizes them)
- Fonts loaded via CSS `@font-face`
- Icons and images benefiting from bundling/hashing
- SVGs imported as components
- Assets needing cache-busting

**Rule of thumb:** External URL reference → `/public`. Code import → `/src/assets`.

---

## Naming Conventions

### Directories
- Use lowercase with hyphens: `user-profile/`, `api-client/`
- Use singular for modules: `model/`, `service/`
- Use plural for collections: `components/`, `utils/`, `hooks/`

### Files

File names must describe what the file does, not just the subject. Use verb+noun or clear action names.

| Bad | Good | Why |
|-----|------|-----|
| `slug.js` | `generateSlug.js` | Describes the action |
| `email.js` | `sendEmail.js` | Clarifies purpose |
| `password.js` | `hashPassword.js` | Specific function |
| `user.js` | `UserService.js` | Indicates service role |
| `auth.js` | `validateToken.js` | States what it does |

| Type | Convention | Example |
|------|------------|---------|
| React components | PascalCase | `UserProfile.tsx` |
| Vue components | PascalCase | `UserProfile.vue` |
| Utilities | camelCase, verb+noun | `generateSlug.ts`, `formatDate.ts` |
| Constants | camelCase or UPPER_SNAKE | `config.ts`, `API_ENDPOINTS.ts` |
| Types | PascalCase | `User.types.ts` |
| Tests | Match source + suffix | `UserProfile.test.tsx` |
| Styles | Match component | `UserProfile.module.css` |

### Index Files
- Use `index.ts` for public exports from a directory
- Re-export components: `export { Button } from './Button'`
- Avoid logic in index files (only exports)

---

## Import Organization

### Import Order
```typescript
// 1. External packages
import React from 'react';
import { useQuery } from '@tanstack/react-query';

// 2. Internal packages (monorepo)
import { Button } from '@repo/ui';

// 3. Absolute imports (aliases)
import { useAuth } from '@/hooks/useAuth';
import { formatDate } from '@/lib/utils';

// 4. Relative imports
import { UserCard } from './UserCard';
import styles from './UserList.module.css';

// 5. Types (if separate)
import type { User } from '@/types';
```

### Path Aliases
```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"]
    }
  }
}
```

---

## Environment Configuration

### File Hierarchy
```
.env                  # Default values (committed, no secrets)
.env.local            # Local overrides (git-ignored)
.env.development      # Development-specific
.env.production       # Production-specific
.env.test             # Test-specific
.env.example          # Template with all variables (committed)
```

### Environment Loading Order
1. `.env` (base)
2. `.env.{NODE_ENV}` (environment-specific)
3. `.env.local` (local overrides, highest priority)

### Guidelines
- NEVER commit `.env.local` or files with real secrets
- ALWAYS maintain `.env.example` with all required variables
- Use descriptive names: `DATABASE_URL`, `API_BASE_URL`
- Prefix client-exposed vars: `NEXT_PUBLIC_*`, `VITE_*`

---

## Build Output

### Standard Output Directories
```
project/
├── dist/             # Production build output
├── build/            # Alternative build output
├── .next/            # Next.js build cache
├── node_modules/     # Dependencies
├── coverage/         # Test coverage reports
└── .cache/           # Build tool caches
```

### Git-Ignored Directories
Add to `.gitignore`:
```
dist/
build/
.next/
node_modules/
coverage/
.cache/
*.log
.env.local
.env*.local
```

---

## Organization Principles

### DO
- Keep directory depth shallow (max 3-4 levels)
- One component/function per file
- Group related files together
- Use consistent patterns across project
- Document non-obvious structure decisions

### DON'T
- Create deeply nested structures
- Mix concerns in same directory
- Use generic names (`helpers/`, `misc/`)
- Duplicate code across features (extract to shared)
- Leave empty directories

---

## Before Creating New Files

1. Check if similar functionality already exists
2. Determine correct directory based on file type
3. Follow established naming conventions
4. Consider if code should be shared or feature-specific
5. Update exports/index files if needed
