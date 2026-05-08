# Browser Verification with Playwright MCP

When work involves a browser-rendered surface, drive a real browser via Playwright MCP and verify behavior. Type checks and tests verify code correctness; they do not verify what a user actually sees, and reasoning about a rendered page without opening it is guessing.

## Use cases

- **UI/frontend changes**: after implementing, `browser_navigate` to the dev server, drive the relevant flow (click, fill, submit), check `browser_console_messages` and `browser_network_requests` for errors, then capture with the right tool — `browser_snapshot` for structural checks (did the right element appear, did state update correctly?) returns text, while `browser_take_screenshot` returns rendered pixels and is the only way to verify CSS/styling/visual layout. For responsive work, drive `browser_resize` through breakpoints and screenshot each. "Tests pass" ≠ "the feature works," and a passing snapshot ≠ "it looks right."
- **Backend changes a browser actually hits**: when an API change affects what the frontend sends or receives (payload shape, response format, headers, auth, status codes, CORS), drive the real frontend with `browser_navigate` and capture the actual request/response with `browser_network_requests`. This catches contract drift that backend integration tests miss because they don't reproduce what the live browser client sends — different headers, different cookie state, different content negotiation.
- **Finding web context**: prefer `WebFetch` for static, public pages — faster and cheaper. Reach for Playwright when the site is SPA-rendered, requires interaction to reveal content, sits behind a login Playwright can perform, or `WebFetch` returned empty/broken HTML.

## Capture rules

- **`browser_wait_for` before capturing**: navigate-then-snapshot is the wrong default for SPAs and async-loaded content — the page hasn't settled, the data hasn't arrived, the screenshot looks valid but isn't. Wait for the specific element, text, or network state you're verifying, then capture.
- **Capture only what you need**: snapshot a region, screenshot a component, request the specific network entry — full-DOM snapshots and full-page screenshots can be tens of thousands of tokens or hundreds of KB.
- **Mask secrets and PII before reporting captures**: tokens, cookies, session IDs, and any visible personal data. Once leaked into the transcript they don't come back.

## Never auto-start services

If `browser_navigate` fails (connection refused, timeout, wrong port), surface that to the user and ask where the server is running — do NOT start it yourself. You can't reliably tell whether it's already running in another terminal, on a non-default port, or under a process you can't see; a duplicate start causes port conflicts and zombie processes, and you may run the wrong command for this project. Same applies to databases, workers, and any other long-lived service.

## Not installed?

If the `mcp__playwright__browser_*` tools are not present in the available-tools list, install user-wide so Playwright MCP applies to every project on this machine, not just the current one:

```bash
claude mcp add --transport stdio --scope user playwright -- bunx @playwright/mcp@latest
```

The user will see a permission prompt for that Bash command. If they decline, proceed without browser verification and explicitly surface the gap in the task report ("did not verify in browser — Playwright MCP unavailable") rather than silently degrading. Don't fall back to project scope or hand-edited config without asking — user scope is the deliberate default.

After install, verify the `mcp__playwright__browser_*` tools appear in the available-tools list before continuing. Requires Bun.
