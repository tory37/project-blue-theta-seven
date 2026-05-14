---
name: djt-trello
description: "Retrieve or add Trello cards across BUGS, TECH DEBT, and BACKLOG columns. Use for lightweight card management without the full engineering workflow."
trigger: /djt-trello
---

# /djt-trello

Retrieve the next card from a Trello column, or add a new card to one.

## Usage

```
/djt-trello bugs           # retrieve top BUGS card → move to DOING
/djt-trello techdebt       # retrieve top TECH DEBT card → move to DOING
/djt-trello backlog        # retrieve top BACKLOG card → move to DOING (no workflow)
/djt-trello add bugs       # create a new card in BUGS
/djt-trello add techdebt   # create a new card in TECH DEBT
/djt-trello add backlog    # create a new card in BACKLOG
/djt-trello                # → prompts for column
```

---

## Ambiguity Rule

If the column is not specified (e.g. bare `/djt-trello` or `/djt-trello add`), respond with exactly:

> "This skill supports 3 columns: BUGS, TECH DEBT, and BACKLOG. Which column did you mean?"

Do NOT fall back to a default column silently. Wait for the user's answer before proceeding.

---

## Retrieve Workflow

When retrieving (`/djt-trello <column>`):

1. Fetch **all** cards from the specified column list (see Trello Config below).
2. **Filter** out any card named "Bug Template" or "Feature Template".
3. Present the list of available cards to the user with their names and (brief) descriptions.
4. **Ask the user to pick which card they want to start.**
5. Once the user selects a card:
    - Move the card to **DOING** (`69fba5b0b558e6bf3b494a88`) and assign yourself.
    - Present the full card name, description, and URL to the user.
    - Stop — do not begin an engineering workflow unless the user asks.


---

## Add Workflow

When adding (`/djt-trello add <column> [@path/to/template.md]`):

- If a filled template file is provided via `@path`, read it and use its fields to populate the card.
- If no file is provided, prompt the user for each field in the order it appears in the template below.

### Bug cards (`add bugs`)

Template schema:

# Bug Report

## Summary
<!-- One sentence: what is broken? -->
[SUMMARY]

## Expected Behavior
<!-- What should happen? -->
[EXPECTED BEHAVIOR]

## Actual Behavior
<!-- What actually happens instead? -->
[ACTUAL BEHAVIOR]

## Steps to Reproduce
<!-- Minimal, numbered steps that reliably trigger the bug. -->
1. [STEP 1]
2. [STEP 2]
3. [STEP 3]

## Environment
<!-- Where does this occur? Fill in what applies. -->
- Branch/commit: [BRANCH OR COMMIT SHA]
- Service/app: [SERVICE NAME]
- Environment: [local | staging | prod]
- User/tenant affected: [USER ID OR TENANT — omit if not applicable]

## Error Output
<!-- Paste error messages, stack traces, or log lines. -->
```
[ERROR OR STACK TRACE]
```

## Affected Files / Components
<!-- List any files or modules you already suspect. Leave blank if unknown. -->
- [FILE OR COMPONENT]

## Related Tickets / Links
<!-- Jira key, GitHub issue, PR, Slack thread, etc. -->
- [TICKET OR LINK]

## Notes for the Agent
<!-- Prior investigation, attempted fixes, relevant context. -->
[NOTES]


**Mapping to Trello:**
- **Card name** ← Summary
- **Description** ← Expected Behavior + Actual Behavior + Environment + Error Output + Related Tickets/Links
- **Checklist "Steps to Reproduce"** ← each numbered step as a checklist item
- **Checklist "Affected Files"** ← each file or component as a checklist item

### Feature / Tech Debt / Backlog cards (`add techdebt`, `add backlog`)

Template schema:

# Feature Spec

## Feature Name
<!-- Short, imperative title — e.g. "Add OAuth login via Google" -->
[FEATURE NAME]

## Goal
<!-- One or two sentences: what user need does this address, and why now? -->
[GOAL]

## User Story
<!-- "As a [role], I want [capability], so that [benefit]." -->
As a [ROLE], I want [CAPABILITY], so that [BENEFIT].

## Acceptance Criteria
<!-- Each line is a testable, binary pass/fail condition. -->
- [ ] [CRITERION 1]
- [ ] [CRITERION 2]
- [ ] [CRITERION 3]

## Scope
<!-- What is explicitly in and out of scope for this feature? -->

### In scope
- [IN SCOPE ITEM]

### Out of scope
- [OUT OF SCOPE ITEM]

## Affected Areas
<!-- List files, modules, or services you know are touched. Leave blank if unknown. -->
- [FILE OR MODULE]

## Constraints & Non-Goals
<!-- Technical limits, deadlines, things intentionally not addressed. -->
- [CONSTRAINT OR NON-GOAL]

## Related Tickets / Links
<!-- Jira key, GitHub issue, design doc URL, etc. -->
- [TICKET OR LINK]

## Notes for the Agent
<!-- Anything that would help the agent get started — prior context, gotchas, preferred approach. -->
[NOTES]


**Mapping to Trello:**
- **Card name** ← Feature Name
- **Description** ← Goal + User Story + Scope (In/Out) + Constraints & Non-Goals + Related Tickets/Links
- **Checklist "Acceptance Criteria"** ← each checkbox item as a checklist item
- **Checklist "Test Plan"** ← empty (filled during implementation)

After creating the card, present the URL to the user.

---

## Trello Config

| Column    | List ID                      | Excluded Templates          |
|-----------|------------------------------|-----------------------------|
| BUGS      | `69fba5b0b558e6bf3b494a8a`       | "Bug Template"              |
| TECH DEBT | `6a04c9b48d4728367cdf7b83`   | "Feature Template"          |
| BACKLOG   | `69fba5b0b558e6bf3b494a87`    | "Feature Template"          |
| DOING     | `69fba5b0b558e6bf3b494a88`      | —                           |

- Board ID: `QSqmJAA7`
- MCP server: `trello` (defined in `.agents/mcp/trello.json`)
---
