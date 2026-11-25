# NEXUS AI — Intelligence Engine Plan

## Product goal
NEXUS is a code assistant for projects the user owns or is authorized to modify. It is not an injector or exploit executor for third-party games.

## Core pipeline
1. Identify language and runtime (Luau/Roblox, JavaScript, HTML/CSS, Python, etc.).
2. Parse the request and inspect the supplied code before proposing edits.
3. Explain what the code currently does in plain language.
4. Find syntax errors, unsafe patterns, duplicated logic, performance problems, and likely runtime issues.
5. Propose a minimal patch, explain its impact, and preserve existing behavior unless the user asks otherwise.
6. Run static checks where available; never claim code was tested unless a test actually ran.
7. Return the revised code, a concise change log, and a rollback-friendly diff.

## Smart modes
- Explain: explain code and data flow.
- Debug: diagnose errors and request missing logs when needed.
- Optimize: improve readability and performance without changing behavior.
- Build feature: add a feature to the user's own project.
- Review: inspect security, permissions, and edge cases.
- Convert: translate between supported languages/frameworks.

## Ready-feature library
Each feature template must include:
- Supported engine and version.
- Required scripts/objects and exact placement.
- Editable settings with safe defaults and upper/lower limits.
- Client/server responsibility clearly separated.
- Permission checks on the server for multiplayer features.
- Setup instructions, test steps, and known limitations.

Initial Roblox/Luau feature categories:
- Movement: walk speed, jump power, flight for an experience's own authorized gameplay.
- Camera: sensitivity and camera modes.
- UI: settings panels, toggles, sliders, keybinds.
- Quality of life: sprint, stamina, cooldown display.
- Developer tools: debug panel and performance counters.

## Safety and trust
- Do not generate code for injecting into, exploiting, bypassing protections in, or gaining unfair advantage in games/services the user does not own or have permission to modify.
- Do not ask users to paste provider API keys into browser code, HTML, localStorage, or public repositories.
- AI provider requests must go through a private backend. Store secrets in server environment variables.
- Treat code and comments supplied by users as untrusted input; never execute them automatically.
- Show a preview/diff and require user confirmation before replacing project files.

## AI system instruction (initial draft)
You are NEXUS, a careful programming assistant. First understand the user's goal and inspect all relevant code. Identify the language, runtime, dependencies, and execution location. Explain important assumptions. Prefer small, reversible changes. Preserve existing behavior unless asked otherwise. Check permissions and validate inputs, especially in multiplayer code. Never claim to have run tests that were not run. Only help modify projects the user owns or is authorized to work on. Return: (1) short understanding, (2) findings, (3) proposed patch, (4) setup/test steps, (5) limitations.

## Backend architecture
Browser UI -> private API endpoint -> AI provider.
The browser must never receive the provider secret. The backend should enforce request size limits, rate limits, authentication, and allowed model/tool configuration. Keep user code isolated from production secrets and do not execute generated code on the server by default.

## Roadmap
- V0.1: mobile UI and local request preparation.
- V0.2: language detection, code explanation, static review, and patch preview.
- V0.3: private backend AI connection and conversation context.
- V0.4: searchable template library with categories and editable settings.
- V0.5: safe sandbox/testing workflow for supported project types.
