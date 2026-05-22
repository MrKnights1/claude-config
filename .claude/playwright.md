# Browser Verification with Playwright MCP

Type checks and unit tests verify code correctness; they do not verify what a browser actually renders, sends, or executes. For any browser-rendered surface, drive Playwright MCP (`mcp__playwright__browser_*` tools) and observe real behavior — reasoning from source alone is guessing.

## When to reach for Playwright MCP

| Situation | Action |
|---|---|
| UI/frontend change just landed | Navigate, drive the flow, capture state |
| Backend change affects what the browser sends or receives | Drive the real client, inspect `browser_network_requests` |
| Visual/layout/CSS work | Screenshot at the relevant viewports |
| SPA, JS-rendered, login-gated, or interaction-gated content | Use Playwright (`WebFetch` returns empty HTML on these) |
| Static, public HTML page | Use `WebFetch` — faster, cheaper, no browser cost |

E2E browser checks sit at the top of the testing pyramid: highest confidence, highest cost. Use them to confirm user-visible behavior — not to replace unit or integration tests below them.

## Capture: snapshot vs screenshot

Pick by what is being verified, not by habit. Both are expensive; pick one.

| Goal | Tool | Why |
|---|---|---|
| Did the right element appear? Did state update? Is the role/text correct? | `browser_snapshot` | Returns accessibility tree (text). Stable across cosmetic changes. Supports partial matching. |
| Does CSS/layout/styling/spacing look right? Visual regression across breakpoints? | `browser_take_screenshot` | Pixels are the only source of truth for visual correctness. |
| Need both structure and visual context (rare) | Both, scoped | Default to one; add the other only when justified. |

## Wait before capturing

Playwright's action APIs (click, fill, navigate) auto-wait for actionability — visible, stable, enabled, editable. Capture APIs do not. Navigate-then-snapshot on an SPA captures a half-rendered page that looks valid but is not.

- Use `browser_wait_for` against the specific element, text, or network condition being verified, then capture.
- Never insert fixed-duration sleeps to "let the page settle." Fixed waits are flaky and slow; auto-waits and explicit conditions are the documented replacement.

## Control token cost

A single Playwright MCP snapshot can return tens of thousands of tokens; one published benchmark put a full task at ~114K tokens. Every navigation re-emits the full accessibility tree.

- Scope captures: snapshot a region, screenshot a component, request the specific network entry — avoid full-page snapshots and full-DOM dumps.
- Capture once per state change, not after every action.
- Drop stale captures from working memory once a new state is verified.

## Network verification

API contract drift between frontend and backend is invisible to backend integration tests because those tests don't reproduce what the live client sends — headers, cookies, content negotiation, auth state all differ.

- For any API change a browser hits, drive the real frontend with `browser_navigate` and inspect the actual request/response via `browser_network_requests` or `browser_network_request`.
- Watch `browser_console_messages` for silent failures: many apps log API errors to the console without surfacing them in the UI.

## Mask before reporting

Anything captured into the transcript stays in the transcript. Playwright MCP is not a security boundary — captured data flows into the model context.

- Redact tokens, cookies, session IDs, Authorization headers, and any visible PII before quoting snapshots, screenshots, or network entries.
- Never paste raw response bodies that contain credentials or personal data.

## Never auto-start services

If `browser_navigate` fails (connection refused, timeout, wrong port), report it and ask where the server is running. Do not start it. Detection is unreliable across terminals, ports, and process owners; a duplicate start causes port conflicts and zombie processes, and the wrong start command can corrupt local state. Same rule applies to databases, workers, and any other long-lived service.

## When Playwright MCP is unavailable

If the `mcp__playwright__browser_*` tools are absent from the tool list, install at user scope so every project on the machine inherits the server:

```bash
claude mcp add --transport stdio --scope user playwright -- bunx @playwright/mcp@latest
```

After install, confirm the tools appear before continuing.

If install is declined or unavailable, proceed without browser verification and state the gap explicitly in the task report ("did not verify in browser — Playwright MCP unavailable"). Do not silently downgrade to code-only reasoning while implying the change was verified.
