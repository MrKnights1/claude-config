# Project Structure

A project's directory layout encodes intent. Done well, the location of a file already tells anyone reading it what the file does, what depends on it, and what it is allowed to touch. Done badly, it is a slow tax paid on every change.

Naming rules for files and directories live in `naming.md` — this file covers *where things go*, not *what to call them*.

---

## Core principles

- **One concern per directory.** A directory's name is a promise about what lives inside it. Mixing source with configuration, or tests with documentation, breaks that promise and forces every file decision to be re-explained from scratch.
- **Things that change together live together.** Code, its tests, its styles, and its types belong in the same place when they belong to the same feature. Distance between related files is friction on every change.
- **Dependencies flow one direction.** Lower-level modules never import from higher-level ones. Cycles are a design smell — break them with extraction or inversion, not with workarounds.
- **Shallow beats deep.** Three levels of nesting from the project root is the working ceiling. Past that, navigation cost rises sharply and paths stop being memorable.
- **Predictable beats clever.** A layout that matches what someone arriving at the repo expects to see wins over a bespoke arrangement, even when the bespoke arrangement is locally better.

---

## Top level of the repo

Only files that describe, configure, or enter the project belong at the root: the manifest, the lockfile, the readme, the license, the ignore file, the top-level configs for build tooling, linters, formatters, and CI.

Source code does not live at the root. A flat scatter of source files in the project root is the single most common structural mistake — it makes the project's surface unreadable and forces every tool to guess where code begins.

| Goes at root | Does not go at root |
|---|---|
| Manifest, lockfile | Source files |
| Readme, license, contributing guide | Business logic |
| Ignore file, editor config | Domain models |
| Build / test / lint / format configs | Feature folders |
| CI configuration | Database schemas |

---

## Source code lives under one root

All first-party source code lives under a single, well-known directory at the top of the repo. Pick one name and use it everywhere — splitting source across multiple top-level folders fractures tooling, imports, and search.

The same rule applies inside that source root: each subdirectory holds one kind of thing. Components in one place, route handlers in another, business logic in another, external integrations in another. The name on the folder is the contract.

---

## Feature folders over deep layer trees

Two ways to slice a codebase:

- **By layer** — all controllers in one folder, all models in another, all views in another. Every change touches many folders.
- **By feature** — each feature owns its controller, model, view, tests, and styles together. A change to one feature stays in one folder.

Feature folders win at scale. Cohesion is higher (everything for a feature is in one place), coupling is lower (features can be deleted by deleting one folder), and parallel work conflicts less. Pure layer trees are acceptable for small projects but degrade as the project grows: every conceptually small change spreads across layers, and cross-layer leakage becomes hard to police.

A hybrid is common and fine — feature folders at the top of the source tree, with a small layer-style structure inside each feature.

| Symptom | Likely cause |
|---|---|
| One conceptual change edits five folders | Layer-sliced where it should be feature-sliced |
| A folder named `helpers/`, `utils/`, `misc/`, `shared/` keeps growing | Missing feature boundaries — extract |
| Two features import each other | Missing shared module, or one feature is doing the other's job |

---

## Tests sit next to the code they cover

Co-located tests (`Thing.test.ext` beside `Thing.ext`) outperform a parallel `tests/` mirror tree for unit tests: they get updated when the code does, they are discoverable without leaving the file, and coverage gaps are visible at a glance.

Reserve a separate top-level tests directory for tests that don't have a single source file to sit beside — integration tests that span modules, end-to-end tests that drive the whole system, shared fixtures, and test helpers.

Pick one convention per project and apply it everywhere. Mixing co-located and mirrored unit tests inside the same project is worse than either choice on its own.

---

## Static assets: served vs. bundled

Two different kinds of asset, two different homes:

| Goes in the public/served directory | Goes in the source/bundled directory |
|---|---|
| Files needing exact, stable URLs (`favicon.ico`, `robots.txt`, `sitemap.xml`, `manifest.json`) | Images, fonts, icons imported from code |
| Files referenced from outside the build (HTML meta tags, external verifications) | Assets that benefit from content hashing and cache busting |
| Large media that should not enter the bundle | SVGs imported as components |

Rule of thumb: external URL reference goes in the served directory; import from code goes in the bundled directory. Files in the served directory are copied as-is with no transformation; files in the bundled directory get processed, hashed, and tree-shaken.

---

## Environment configuration

Environment configuration is split between a committed template and uncommitted real values. The template (`.env.example` or equivalent) lists every variable the project reads, with placeholder values, and is committed. The real values live in an uncommitted file that the ignore file excludes.

Rules:
- Never commit real secrets. The ignore file must exclude every variant of the local env file before the first commit.
- Keep the template current. Adding a variable to the code without adding it to the template is a broken setup for anyone who pulls the change.
- Use different values per environment. Development, staging, and production each get their own; never commit production secrets to any file in the repo.
- Validate required variables at startup. Fail fast when something is missing rather than crashing on first use.

---

## Build output is generated, never committed

Build artifacts, dependency directories, caches, and coverage reports are all regenerable. They do not belong in version control.

The ignore file at the root excludes:

| Pattern | Why |
|---|---|
| Dependency install directory | Reinstallable from the lockfile, huge, churns constantly |
| Build / dist output | Reproducible from source |
| Framework / tool caches | Local-only, machine-specific |
| Coverage reports | Regenerated by the test run |
| Local env files | Contain real secrets |
| Log files | Noise, not artifacts |

A repo that tracks any of the above is a repo where pulls are slow, diffs are noise, and merges conflict on machine-generated bytes.

---

## Imports

Imports follow a fixed order from most external to most local: external packages first, then internal cross-package imports, then absolute imports inside the same package, then relative imports, then type-only imports if the language separates them. A consistent order makes the dependency surface of a file legible at a glance.

Use absolute or aliased paths for anything more than a sibling. Long chains of `../../../` are a structural smell — either the file is in the wrong place or the project needs path aliases.

Imports declare dependency direction. If a low-level module imports from a high-level one, the layering is wrong. If two modules import each other, there is a cycle — fix it by extracting the shared piece into a third module or by inverting the dependency, not by patching around it.

---

## Re-export (index/barrel) files

A re-export file is a single entry point that re-exports the public surface of a directory. It can clarify what a module exposes, but it has real costs: bundlers may struggle to tree-shake through it, test runners may pay a module-graph cost per file, and click-through navigation from import to definition gets an extra hop.

Rules:
- Keep them shallow. One level of re-export at the public boundary of a feature is the sweet spot; chains of re-exports through every subdirectory are not.
- Keep them dumb. Only re-exports — no logic, no side effects, no conditional branches.
- Skip them inside the same feature. Code inside a feature imports siblings directly.

When in doubt, prefer direct imports. The build-time and navigation-time cost of barrels grows faster than the typing-saved benefit.

---

## Shallow hierarchies

Three levels of nesting from the source root is the working ceiling. Each additional level multiplies the cognitive cost of finding a file and the path length in every import.

| Warning sign | What it means |
|---|---|
| Paths in imports are five segments deep | Hierarchy is too nested |
| A folder contains a single subfolder containing the real content | Collapse the wrapping folder |
| A folder contains hundreds of unrelated files | Hierarchy is too flat — introduce structure |
| Reorganizing requires touching imports in dozens of files | Path aliases were not set up, or the move crosses too many boundaries |

Depth should track the structure of the system. If the feature graph is shallow, the folder graph should be shallow. If features genuinely contain sub-features, modest nesting is correct.

---

## Monorepos

A monorepo is multiple packages in one repository, each with its own manifest and build, sharing a single install, a single lockfile, and a single CI pipeline.

Conventions that hold across stacks:

- **Two top-level homes.** Deployable applications go in one directory; reusable libraries go in another. The dependency graph flows from applications into libraries, never the other direction.
- **One install at the root.** Running install inside a package creates a shadow dependency tree that breaks workspace resolution. The lockfile lives at the root and is the only one.
- **Explicit package boundaries.** Each package declares what it exposes. Lint rules or project references enforce that packages do not reach into each other's internals.
- **Affected-only builds and tests.** Tooling should run work only for packages whose inputs changed. Running everything on every change defeats the point of the monorepo at scale.

---

## Before adding a file

1. Check whether something similar already exists — duplicate utilities are a recurring source of drift.
2. Place it by what it does, not by what it is named. A "user service" file belongs with the user feature, not in a generic `services/` bucket.
3. Confirm the directory's contract still holds after adding the file. If the file forces the directory to mean two things, the directory needs splitting.
4. Update any public re-export at the feature boundary, if one exists.
5. If the file does not have an obvious home, that is a signal to design the home first — not a license to invent `misc/`.
