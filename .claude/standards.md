# Code Quality & Standards

## Code Quality Standards

- Write self-documenting code with clear, descriptive variable and function names
- Prefer meaningful names over comments (e.g., `calculateUserTotalPurchases()` instead of `calc()` with comment)
- Keep functions small and focused on a single responsibility
- Add comments only when code intent isn't obvious from names alone

## Testing & Accessibility Reminders

- Test edge cases and error conditions
- Use transactions for multi-step database operations
- Provide clear form validation error messages
- Include alt text for images

---

# Accessibility

- ALWAYS make interactive elements keyboard accessible (Tab, Enter, Space, Arrow keys)
- ALWAYS use proper semantic HTML tags (`<button>`, `<nav>`, `<main>`, `<article>`)
- ALWAYS add ARIA labels for screen readers where semantic HTML insufficient
- ALWAYS ensure color contrast meets WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- NEVER rely solely on color to convey information
- ALWAYS provide text alternatives for images (alt text)
- ALWAYS ensure forms are accessible (labels, error messages, focus states)

---

# Documentation Requirements

- Update README.md when adding new features or changing setup
- Document all environment variables in `.env.example`
- Keep API documentation up to date with actual implementation
- Include setup instructions for new developers

---

# UI/UX Consistency

- Use consistent spacing (e.g., 4px, 8px, 16px, 24px, 32px)
- Use design system/component library for consistency
- Keep button styles and colors consistent
- Use consistent loading states (spinners, skeletons)
- Provide feedback for all user actions
- Keep forms consistent (labels, validation, error display)

---

# Code Cleanup Guidelines

After any code change or refactor:

- ALWAYS remove unused imports and dependencies
- ALWAYS delete commented-out code (use git history if you need it later)
- ALWAYS remove unused variables, functions, and classes
- ALWAYS remove debug console.log statements before committing
- ALWAYS clean up temporary test code
- Delete unused files (orphaned components, old modules)
- Remove unused CSS classes and styles
- Remove completed TODO comments
- Remove dead code paths (unreachable code after refactor)
- Update or remove outdated comments
- Remove unused environment variables from `.env.example`
- Run linter to catch unused code
- Check for unused dependencies
- Clean up unused API endpoints
- Remove unused types/interfaces
