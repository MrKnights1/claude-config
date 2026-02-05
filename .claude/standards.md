# Code Quality & Standards

## Code Quality Standards

- Write self-documenting code with clear, descriptive variable and function names
- Prefer meaningful names over comments: `calculateUserTotalPurchases()` not `calc()`
- Keep functions small and focused on a single responsibility
- Add comments only when code intent isn't obvious from names alone
- Maximum function length: ~50 lines (break up larger functions)
- Maximum file length: ~300-400 lines (split into modules)
- Maximum nesting depth: 2-3 levels (use early returns)
- Maximum function parameters: 3-4 (use objects for more)
- Use named constants instead of magic numbers/strings
- Extract complex conditions into named variables or functions
- Separate concerns: data access, business logic, presentation
- Pass dependencies explicitly instead of using global state
- Keep pure functions free of side effects
- Avoid circular dependencies between modules
- No god classes/functions (if it does too many things, split it)
- Prefer composition over inheritance
- Single source of truth for state (don't duplicate data)
- Avoid callback hell (use async/await, Promises)
- Don't mix abstraction levels in same function (high-level logic shouldn't contain low-level details)

## Pull Request Guidelines

### PR Size
- Keep PRs small and focused (< 400 lines changed ideal)
- One feature or fix per PR
- Split large changes into sequential PRs

### PR Title Format
```
[Type]: Brief description

Examples:
feat: Add user authentication flow
fix: Resolve login timeout issue
refactor: Extract payment processing to service
docs: Update API documentation
```

### PR Description Template
```markdown
## Summary
Brief description of changes and why they were made.

## Changes
- Added user authentication middleware
- Created login/logout endpoints
- Added session management

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Add screenshots here]

## Related Issues
Closes #123
```

### PR Best Practices
- Self-review before requesting reviews
- Respond to feedback promptly
- Keep discussions focused and constructive
- Update PR based on feedback (don't just resolve comments)
- Squash commits before merge (clean history)

---

## Code Review Checklist

### For Reviewers

#### Functionality
- [ ] Code does what the PR description says
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] No obvious bugs or logic errors

#### Code Quality
- [ ] Code is readable and self-documenting
- [ ] Functions are small and focused
- [ ] No code duplication (DRY)
- [ ] Naming is clear and consistent

#### Security
- [ ] No hardcoded secrets or credentials
- [ ] User input is validated and sanitized
- [ ] SQL queries are parameterized
- [ ] Authentication/authorization is correct

#### Testing
- [ ] Tests cover the changes
- [ ] Tests are meaningful (not just for coverage)
- [ ] Edge cases are tested

#### Performance
- [ ] No obvious performance issues
- [ ] No N+1 queries
- [ ] Large datasets are paginated

#### Documentation
- [ ] Complex logic is commented
- [ ] Public APIs are documented
- [ ] README updated if needed

### Review Etiquette
- Be constructive, not critical
- Explain the "why" behind suggestions
- Distinguish between blocking issues and suggestions
- Use prefixes: `nit:`, `suggestion:`, `question:`, `blocking:`
- Approve with minor comments when appropriate

---

## Git Branch Conventions

### Branch Naming
```
{issue-number}-{short-description}

Examples:
123-add-user-authentication
456-fix-login-timeout
789-refactor-payment-service
```

### Branch Lifecycle
1. Create from `main`
2. Work on changes, commit frequently
3. Push to remote, create PR
4. Address review feedback
5. Squash merge to main

---

## Definition of Done

A task is complete when:

- [ ] Code is written and works as expected
- [ ] Unit tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Code review approved
- [ ] Documentation updated (if needed)
- [ ] No linting or type errors
- [ ] Merged to main branch
- [ ] Verified in staging/production

---

## Technical Debt Management

### Identifying Tech Debt
- Code that works but needs improvement
- Shortcuts taken for deadlines
- Outdated patterns or libraries
- Missing tests or documentation

### Tracking Tech Debt
```markdown
// TODO(#issue-number): Description of what needs to be done
// Example:
// TODO(#234): Refactor this to use the new auth service
```

### Addressing Tech Debt
- Create issues for significant debt
- Allocate time each sprint for debt reduction
- Prioritize debt that blocks features
- Don't let debt accumulate indefinitely

---

## Performance Guidelines

### General Rules
- Measure before optimizing (use profiling tools)
- Optimize hot paths, not everything
- Cache expensive operations
- Lazy load when possible

### Frontend Performance
- Bundle size: < 200KB initial JS (gzipped)
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3.5s
- Use code splitting for routes
- Optimize images (WebP, lazy loading)

### Backend Performance
- API response time: < 200ms (p95)
- Database queries: < 100ms
- Use connection pooling
- Implement caching (Redis, memory)
- Paginate large datasets

### Database Performance
- Add indexes for frequent queries
- Avoid N+1 queries
- Use EXPLAIN to analyze queries
- Monitor slow query logs

---

# Accessibility

- ALWAYS make interactive elements keyboard accessible (Tab, Enter, Space, Arrow keys)
- ALWAYS use proper semantic HTML tags (`<button>`, `<nav>`, `<main>`, `<article>`)
- ALWAYS add ARIA labels for screen readers where semantic HTML insufficient
- ALWAYS ensure color contrast meets WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- NEVER rely solely on color to convey information
- ALWAYS provide text alternatives for images (alt text)
- ALWAYS ensure forms are accessible (labels, error messages, focus states)

### Accessibility Checklist
- [ ] All interactive elements are keyboard accessible
- [ ] Focus states are visible
- [ ] Images have alt text
- [ ] Form fields have labels
- [ ] Color contrast passes WCAG AA
- [ ] Page structure uses semantic HTML
- [ ] Error messages are announced to screen readers

---

# Documentation Requirements

- Update README.md when adding new features or changing setup
- Document all environment variables in `.env.example`
- Keep API documentation up to date with actual implementation
- Include setup instructions for new developers
- Document architectural decisions (ADRs for significant changes)

### README Structure
```markdown
# Project Name

Brief description of the project.

## Getting Started

### Prerequisites
- Node.js >= 18
- PostgreSQL >= 14

### Installation
npm install

### Environment Setup
cp .env.example .env
# Edit .env with your values

### Running Locally
npm run dev

## Available Scripts
- npm run dev - Start development server
- npm run build - Build for production
- npm test - Run tests
- npm run lint - Check code style

## Project Structure
Brief overview of directory structure.

```

---

# UI/UX Consistency

- Use consistent spacing scale (4px, 8px, 16px, 24px, 32px)
- Use design system/component library for consistency
- Keep button styles and colors consistent
- Use consistent loading states (spinners, skeletons)
- Provide feedback for all user actions (success, error, loading)
- Keep forms consistent (labels, validation, error display)

### Loading States
- Use skeleton loaders for content areas
- Use spinners for actions (buttons, forms)
- Disable interactive elements while loading
- Show progress for long operations

### Error States
- Display errors near the relevant field/action
- Use consistent error styling (color, icon)
- Provide clear recovery instructions
- Log errors for debugging

---

# Code Cleanup Guidelines

After any code change or refactor:

### Always Remove
- [ ] Unused imports and dependencies
- [ ] Commented-out code (use git history)
- [ ] Unused variables, functions, and classes
- [ ] Debug `console.log` statements
- [ ] Temporary test code
- [ ] Unused files (orphaned components)
- [ ] Unused CSS classes and styles
- [ ] Completed TODO comments
- [ ] Dead code paths (unreachable code)

### Always Update
- [ ] Outdated comments
- [ ] `.env.example` (add/remove variables)
- [ ] Type definitions (if signatures changed)
- [ ] Tests (if behavior changed)

### Verification
- Run linter to catch unused code
- Check for unused dependencies (`npm-check`, `depcheck`)
- Review git diff before committing
- Run full test suite

---

## Naming Conventions

### Variables and Functions
```typescript
// camelCase for variables and functions
const userName = 'John';
function calculateTotal() {}

// PascalCase for classes and components
class UserService {}
function UserProfile() {}

// UPPER_SNAKE_CASE for constants
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// Prefix booleans with is/has/can/should
const isActive = true;
const hasPermission = false;
const canEdit = true;
```

### File and Directory Names
```
# Components: PascalCase
UserProfile.tsx
LoginForm.vue

# Utilities: camelCase
formatDate.ts
apiClient.ts

# Constants: camelCase or UPPER_SNAKE
config.ts
API_ENDPOINTS.ts

# Directories: lowercase with hyphens
user-profile/
api-client/
```

---

## Error Handling Standards

### Backend
```typescript
// Use custom error classes
class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500
  ) {
    super(message);
  }
}

// Throw meaningful errors
throw new AppError('NOT_FOUND', 'User not found', 404);

// Centralized error handler
app.use((err, req, res, next) => {
  logger.error({ err, requestId: req.id });
  res.status(err.statusCode || 500).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message || 'An error occurred'
    }
  });
});
```

### Frontend
```typescript
// Use error boundaries for React
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    logError(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}

// Handle async errors consistently
async function fetchData() {
  try {
    const data = await api.get('/users');
    return data;
  } catch (error) {
    showErrorToast('Failed to load users');
    logError(error);
    throw error; // Re-throw for error boundaries
  }
}
```
