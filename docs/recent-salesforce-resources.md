# Recent Salesforce Resources

This project is intentionally guided and smaller than the official sample repositories. Use these resources after you finish the walkthroughs here.

Dates below were checked on 2026-06-11.

## Official Current References

| Resource | Recency signal | Why it matters here |
| --- | --- | --- |
| [Agentforce launch press release](https://www.salesforce.com/news/press-releases/2024/09/12/agentforce-announcement/) | Published September 12, 2024. | Shows why Apex service methods and clean data can later become action building blocks. |
| [Developer's Guide to Dreamforce 2025](https://developer.salesforce.com/blogs/2025/09/developers-guide-dreamforce-2025) | Published September 2025 for the October 14-16, 2025 event. | Confirms developer topics worth adding later: Advanced Apex, LWC design/testing, APIs, ALM, Agentforce security, and Data Cloud. |
| [Agentforce 360 announcement](https://www.salesforce.com/news/press-releases/2025/10/13/agentic-enterprise-announcement/) | Published October 13, 2025. | Frames the future architecture around humans, agents, and data on a trusted platform. |
| [Developers at Dreamforce 2025 on Salesforce+](https://www.salesforce.com/plus/experience/dreamforce_2025/series/developers_at_dreamforce_2025) | Current Salesforce+ page checked 2026-06-11; lists 17 developer episodes. | Good watchlist after learners finish the local project walkthroughs. |
| [Dreamforce 2026 Call for Participation](https://developer.salesforce.com/blogs/2026/04/the-dreamforce-2026-call-for-participation-is-now-open) | Published April 29, 2026. | Confirms 2026 developer topics such as Agentforce, Data 360, Apex, LWC, MCP, and vibe coding. |
| [Dreamforce 2026](https://www.salesforce.com/dreamforce/) | Official page checked 2026-06-11; event listed for September 15-17, 2026 in San Francisco and Salesforce+. | Use Dreamforce as a platform compass, especially for Agentforce, Data 360, Slack, hands-on training, and secure AI themes. |
| [Salesforce+ Events](https://www.salesforce.com/plus) | Official page checked 2026-06-11; lists Dreamforce 2026 and Dreamforce 2025 sessions. | Use Salesforce+ to watch recent Dreamforce sessions after completing local exercises. |
| [LWC Developer Guide: API Versioning](https://developer.salesforce.com/docs/platform/lwc/guide/get-started-api-versioning.html) | Salesforce docs mention Winter '24 support and Spring '25 required versioning for custom components. | This repo sets an explicit LWC `apiVersion`, which new JavaScript developers should notice. |
| [LWC Developer Guide: Call Apex Methods](https://developer.salesforce.com/docs/platform/lwc/guide/apex.html) | Current docs checked 2026-06-11. | Supports the dashboard lesson: use `@wire` for cacheable reads and imperative Apex for button-driven writes. |
| [Trailhead: Write SOQL Queries](https://trailhead.salesforce.com/content/learn/modules/apex_database/apex_database_soql) | Current Trailhead unit checked 2026-06-11. | Matches this repo's SOQL guide: inline SOQL, bind variables, relationship queries, and SOQL for-loops. |
| [Salesforce Code Analyzer](https://developer.salesforce.com/docs/platform/salesforce-code-analyzer/guide/analyze.html) | Current docs checked 2026-06-11; the docs describe CLI commands such as `code-analyzer rules`, `code-analyzer run`, and `code-analyzer config`. | Good next step after the sample deploys: teach static analysis, security checks, and CI-friendly output. |
| [salesforce/sfdx-lwc-jest](https://github.com/salesforce/sfdx-lwc-jest) | Current GitHub repo checked 2026-06-11. | Natural next step for JavaScript learners who want local LWC component tests. |

## Official Sample Repositories

| Resource | Recency signal | How to use it |
| --- | --- | --- |
| [trailheadapps/apex-recipes](https://github.com/trailheadapps/apex-recipes) | GitHub API showed pushed `2026-06-02` and updated `2026-06-07`. | Use after this project to study broader Apex patterns such as security, async Apex, platform events, and integrations. |
| [trailheadapps/lwc-recipes](https://github.com/trailheadapps/lwc-recipes) | GitHub API showed pushed `2026-06-03` and updated `2026-06-11`. | Use after the dashboard walkthrough to compare more LWC examples, especially wire adapters, Jest tests, and Apex calls. |
| [trailheadapps/ebikes-lwc](https://github.com/trailheadapps/ebikes-lwc) | GitHub API showed pushed `2026-06-03` and updated `2026-06-07`. | Use when you want a larger app-shaped example after the guided personnel sample feels clear. |

## How These Resources Changed This Repo

- Added `docs/soql-guide.md` and `docs/soql-guide.html` so SOQL has its own learning path instead of being hidden inside selectors.
- Added `docs/dreamforce-learning-notes.md` so current conference themes become practical learning exercises instead of buzzwords.
- Added `scripts/apex/06_soql_practice.apex` to make query concepts runnable from VS Code or Cursor.
- Kept `PersonnelSelector.cls` as the main query layer because the selector pattern helps new developers see where SOQL belongs.
- Called out LWC API versioning because modern custom components must declare an API version when changed.
- Added a Dreamforce fortification backlog that prioritizes security, LWC testing, agent-ready action contracts, skills modeling, async callouts, Code Analyzer, and release-readiness.
- Kept the project smaller than Apex Recipes and LWC Recipes so beginners can finish one coherent walkthrough before jumping into reference libraries.
