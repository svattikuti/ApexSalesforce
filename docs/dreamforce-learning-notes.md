# Dreamforce Learning Notes

Dreamforce is useful for this project because it shows where Salesforce is steering the platform. The project should still teach fundamentals first: objects, fields, SOQL, Apex services, triggers, tests, and Lightning Web Components. Dreamforce themes help decide what to learn next.

Checked on 2026-06-11.

## Official Dreamforce Signals

| Resource | Current signal | What it means for this repo |
| --- | --- | --- |
| [Agentforce launch press release](https://www.salesforce.com/news/press-releases/2024/09/12/agentforce-announcement/) | Published September 12, 2024. Salesforce describes Agentforce as autonomous agents that use Data Cloud, guardrails, Flow, MuleSoft, and Apex methods as action building blocks. | Teach service methods as small action boundaries before learners touch Agentforce setup. |
| [Dreamforce 2024 recap](https://www.salesforce.com/news/stories/dreamforce-24-recap/) | Dreamforce 2024 centered on Agentforce and Data Cloud. | Keep data modeling, relationship SOQL, and traceability visible in the project. |
| [Developer's Guide to Dreamforce 2025](https://developer.salesforce.com/blogs/2025/09/developers-guide-dreamforce-2025) | Dreamforce 2025 ran October 14-16, 2025. The developer guide highlights Apex, LWC, APIs, ALM, Agentforce security, Data Cloud, and hands-on learning. | Map sessions to exercises: SOQL, security, LWC tests, integrations, and release management. |
| [Agentforce 360 announcement](https://www.salesforce.com/news/press-releases/2025/10/13/agentic-enterprise-announcement/) | Published October 13, 2025. Salesforce frames Agentforce 360 as a trusted platform connecting humans, agents, and data. | Add an architecture view that shows this repo's equivalents: objects, Apex services, LWC, tests, and future action/integration layers. |
| [Developers at Dreamforce 2025 on Salesforce+](https://www.salesforce.com/plus/experience/dreamforce_2025/series/developers_at_dreamforce_2025) | Salesforce+ lists 17 developer episodes, including Apex roadmap, LWC roadmap, Data 360, integrations, Agentforce Vibes, MCP, and security topics. | Use a watchlist rule: every watched session must produce one small repo exercise. |
| [Agentforce 360 developer feature post](https://developer.salesforce.com/blogs/2025/10/build-and-optimize-agents-with-new-agentforce-360-features) | Published October 2025. It frames agent lifecycle work around build, integrate, execute, monitor, and optimize. | Mirror the lifecycle without requiring Agentforce: build an Apex service, integrate with external IDs, execute through scripts/LWC, monitor with tests or audit rows. |
| [Dreamforce 2026 Call for Participation](https://developer.salesforce.com/blogs/2026/04/the-dreamforce-2026-call-for-participation-is-now-open) | Published April 29, 2026. It lists developer topics including Agentforce, Data 360, Apex, LWC, Model Context Protocol, and vibe coding. | Keep 2026 as a watchlist; no 2026 session replays exist yet as of 2026-06-11. |
| [Dreamforce 2026](https://www.salesforce.com/dreamforce/) | Scheduled for September 15-17, 2026 in San Francisco and on Salesforce+. Salesforce describes the theme as the Agentic Enterprise and lists 1,600+ sessions plus 150+ hands-on trainings and demos. | Keep the repo hands-on. Every concept should have a runnable script, Apex test, or UI exercise. |
| [Dreamforce 2026 agenda at a glance](https://www.salesforce.com/dreamforce/) | Current session themes include Agentforce, Slack, Data 360, secure AI at scale, multi-agent design, and building faster with Agentforce Builder. | Add "future extension" exercises that connect clean personnel data and SOQL skills to agent-ready Salesforce data. |
| [Salesforce+ events](https://www.salesforce.com/plus) | Salesforce+ lists Dreamforce 2026 as an upcoming event and surfaces Dreamforce 2025 sessions such as the main keynote, Agentforce keynote, Data Cloud keynote, Slack keynote, and "Double Click into Agentforce." | Add Salesforce+ as the place to watch recent Dreamforce sessions after the local lessons. |

## What To Watch For As A New Developer

Dreamforce content can be overwhelming. Use this filter:

1. **Platform fundamentals**: Apex, SOQL, Lightning Web Components, Salesforce DX, permissions, testing, and release management.
2. **Data foundation**: Data quality, Data Cloud/Data 360 concepts, identity, and metadata. Even AI-heavy sessions depend on clean object models and trustworthy fields.
3. **Agentforce readiness**: How agents find data, invoke actions, and respect governance. This project can prepare you by teaching service-layer actions and narrow SOQL.
4. **Security and governance**: Sharing, CRUD/FLS, user-mode data operations, auditability, and safe dynamic queries.
5. **Developer workflow**: CLI, VS Code or Cursor, scratch orgs, source control, tests, and deploy loops.

## How Dreamforce Fortifies This Project

### 1. Keep SOQL Central

Agentic and AI workflows still need trustworthy data retrieval. The new `docs/soql-guide.md` and `scripts/apex/06_soql_practice.apex` give learners a practical base for:

- Selecting only the fields an action needs.
- Using bind variables for safe filters.
- Understanding relationship names before building larger automations.
- Summarizing records with aggregate queries.

### 2. Treat Services As Future Actions

Agentforce and automation-heavy Salesforce apps need small, clear operations. In this repo, methods such as `PersonnelAssignmentService.createAssignment` and `PersonnelService.terminatePersonnel` already look like future action boundaries:

```text
Validate request
  -> Query required records
  -> Apply business rule
  -> Perform DML
  -> Return a clear result
```

When you build more, keep service methods narrow and testable.

### 3. Add Security Earlier

Dreamforce's AI and agent themes make security more important, not less. Before turning this into a real org app, add a learning module that explains:

- `with sharing` for record visibility.
- User-mode SOQL/DML or `Security.stripInaccessible` for CRUD/FLS.
- Why dynamic SOQL requires whitelists.
- How permission sets connect metadata access to app behavior.

### 4. Connect LWC To Current Platform Direction

Salesforce's LWC docs now make API versioning a modern baseline. The dashboard component already declares an API version. New developers should learn:

- LWC configuration files are metadata.
- `@wire` is for cacheable reads.
- Imperative Apex is for user-triggered writes.
- Data returned from Apex should be treated as immutable in JavaScript.

### 5. Add Agent-Ready Exercises Later

Do not start with Agentforce. Start with the data and Apex fundamentals in this repo. Once those are comfortable, add exercises like:

- `PersonnelSkill__c`: model skills so an agent or flow can answer "who can cover this project?"
- `Personnel_Audit__c`: record service outcomes for traceability.
- `Queueable` follow-up task: turn termination into a background workflow.
- Read-only LWC filter: teach client-side state before adding more server calls.
- Secure UI controller: enforce CRUD/FLS so UI and future actions respect permissions.

## Fortification Backlog

Use this backlog when deciding what to build next. It is ordered by learning value for a new Salesforce programmer.

| Priority | Module | Why it matters | Likely files |
| --- | --- | --- | --- |
| 1 | Security and sharing guide | Dreamforce AI and agent themes make permission boundaries more important. Teach `with sharing`, CRUD/FLS, user-mode operations, and `Security.stripInaccessible`. | `docs/security-and-sharing-guide.md`, `PersonnelDashboardController.cls`, `PersonnelDashboardControllerTest.cls`, permission sets |
| 2 | LWC Jest and metadata-backed picklists | JavaScript developers expect component tests, and Salesforce UIs should learn picklist values from metadata instead of hardcoding forever. | `package.json`, `jest.config.js`, `force-app/main/default/lwc/personnelDashboard/__tests__`, `personnelDashboard.js` |
| 3 | Agentforce readiness without Agentforce setup | Learners can practice agent-safe action contracts with invocable Apex, DTOs, narrow queries, and clear results before configuring Agentforce. | `PersonnelAgentActions.cls`, `PersonnelAgentActionsTest.cls`, `docs/agentforce-readiness.md` |
| 4 | `PersonnelSkill__c` extension | Clean skill data makes the project more useful for "who can cover this work?" queries and later agent use cases. | `objects/PersonnelSkill__c`, `PersonnelSkillService.cls`, `PersonnelSkillSelector.cls`, `scripts/apex/07_assign_personnel_skills.apex` |
| 5 | Async and callout lesson | Dreamforce themes frequently connect agents, Slack, and external systems. Teach Queueable Apex and `HttpCalloutMock` without real secrets. | `PersonnelTerminationQueueable.cls`, `PersonnelNotificationClient.cls`, `docs/async-and-callouts.md` |
| 6 | Code Analyzer and CI loop | Static analysis and CI turn the project from sample code into a professional development loop. | `.github/workflows/validate.yml`, `code-analyzer.yml`, `package.json` |
| 7 | Release-readiness lab | Salesforce ships seasonal releases. Teach API version pinning, LWC versioning, and how to evaluate a version bump. | `docs/release-readiness.md`, `sfdx-project.json`, `manifest/package.xml`, `personnelDashboard.js-meta.xml` |

The next best implementation task is the security and sharing guide. It directly improves the current LWC controller lesson and protects learners from copying a common beginner mistake: assuming `with sharing` also enforces field-level security.

## Suggested Dreamforce Viewing Path

Use Salesforce+ and search for recent Dreamforce sessions in this order. After each session, write one small exercise for this repo.

1. **Dreamforce Main Keynote 2025** for platform direction.
2. **Agentforce Keynote: Become an Agentic Enterprise** for how Salesforce explains agents.
3. **Data Cloud Keynote: Activate Trusted Data Everywhere** for why data quality matters.
4. **Double Click into Agentforce** for a deeper technical pass.
5. **Developer Keynote: Build Your Agentic Enterprise** for Agentforce, Data Cloud, Slack, and unified platform direction.
6. **Apex Roadmap: What's New and What's Coming** for Apex-specific direction.
7. **LWC Roadmap: What's New and What's Coming** for JavaScript UI direction.
8. **Unlocking Data 360: A Developer's Practical Guide** for how data modeling and querying support newer platform use cases.

Write notes as "what should I change in this repo?" If a session does not lead to a concrete exercise, save it for later.
