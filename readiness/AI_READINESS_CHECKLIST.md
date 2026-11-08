# AI-readiness checklist for CRM and customer-data platforms

Use this before you connect an AI feature to a CRM, billing or service platform. It finds the platform problems that turn an ordinary AI project into a data-exposure or data-quality problem. It is written with long-lived, heavily customized platforms in mind: older on-premises CRM suites of the kind long used by telecommunications and financial-services companies, home-grown customer databases, and hybrid set-ups where a modern front end sits on an old core.

**How to use it.** Work through sections R1 to R8 for the platform (once) and for each use case (the items marked **UC**). Record answers in `readiness_checklist.csv`. Section R9 turns the answers into a decision. Most items take a conversation with the CRM administrator and an hour in the system, not a project.

Status values: `yes`, `partial`, `no`, `unknown`. Treat `unknown` as `no` until proven otherwise.

---

## R1. Platform and ownership

- **R1.1** Is there a named owner for the platform who can approve AI access? (Links to RACI "CRM platform owner".)
- **R1.2** Which product and version runs in production, and is it within vendor support? Unsupported versions limit what security fixes and API features you can rely on.
- **R1.3** How much of the platform is customized (scripts, workflows, custom objects)? Where is the customization documented? AI integrations built on undocumented custom logic break at upgrades.
- **R1.4** Is there a non-production environment that matches production closely enough to test AI integrations, with masked data (SAF-11)?
- **R1.5** Is an upgrade or migration planned in the next 12-18 months? If yes, decide whether the AI integration waits for it, or is built so it can move with it.

## R2. Data quality

AI amplifies what is in the data. Poor data gives confident wrong answers.

- **R2.1 UC** For the fields the use case needs: how complete are they, and how current? Sample 50 records and count.
- **R2.2** Are there duplicate customer records? Is there a rule for which record is the "golden" one?
- **R2.3** Are reference values (product codes, status codes, categories) consistent, or do several codes mean the same thing?
- **R2.4 UC** Free-text fields (notes, comments, transcripts): what do staff actually write there? Sample them. Expect personal details, payment data or passwords typed in by mistake; this decides masking (SAF-19).
- **R2.5** Are there known data-quality issues already tracked? Link them.

## R3. Data sensitivity, consent and customer-specific rules

- **R3.1** Is there a data classification for CRM objects and fields (SAF-18)? If not, create one for the fields in scope first.
- **R3.2** Where does CPNI live? List the objects and fields with call detail, services subscribed, usage and billing detail. Ask counsel which of them are CPNI under 47 CFR s.64.2003 ([CPNI]).
- **R3.3** Are customer CPNI approval or opt-out choices stored, reliable and machine-readable, so an AI use case can respect them ([CPNI] s.64.2007)?
- **R3.4** Are marketing and contact preferences stored in a way an AI feature can check before it suggests contacting a customer?
- **R3.5** Are there accounts that need extra protection (business customers with contract terms, accounts flagged for fraud, customers who asked for extra security)? How are they flagged?
- **R3.6 UC** For a customer-facing assistant: how does it authenticate the customer before disclosing account or call detail information, and does that meet [CPNI] s.64.2010?
- **R3.7** Are there data-location or contract limits that stop data leaving a country or a cloud?

## R4. Access paths

List every way data can be read or written. AI should use the safest path, not the easiest.

- **R4.1** User interface (staff and customer portals)
- **R4.2** Official APIs or web services: which exist, what authentication they support (OAuth, tokens, basic auth, session-based), and whether they enforce the CRM's own visibility rules
- **R4.3** Direct database access: who has it, with which accounts? AI must not use it (SAF-02).
- **R4.4** Reporting replicas, data warehouses and data lakes: how fresh, which access rules apply? A copy without the CRM's visibility rules is a common way to over-share with AI.
- **R4.5** Batch exports, import/export tools and file transfers: where do files land, who can read them, how long do they stay?
- **R4.6 UC** Which path will the AI use, and does it apply the field allowlist and the user's visibility?

## R5. Integration inventory

Use `integration_inventory_template.csv`. One row per interface.

- **R5.1** Is there a complete list of integrations (inbound and outbound, real-time and batch, middleware, scheduled jobs, file flows, scripts)? Large CRM estates often have more than anyone remembers; search schedulers, middleware configs and server cron tables, not only documents.
- **R5.2** For each: owner, direction, protocol, authentication method, account used, data objects, schedule, monitoring.
- **R5.3** Which integrations use shared or highly privileged accounts? Plan to split them before adding AI (SAF-01).
- **R5.4** Where are integration credentials stored? Config files, scripts and database tables with clear-text passwords are common in older estates; move them to a secrets manager (SAF-05).
- **R5.5 UC** Which existing integrations will the AI use case touch or depend on?

## R6. Legacy platform constraints

- **R6.1** Can the platform give a non-human identity its own limited role, or do all integrations run as one user?
- **R6.2** Does the platform support modern authentication for APIs (for example OAuth 2.0 client credentials or token exchange)? If not, put a gateway or API layer in front that does, and keep the legacy credential inside it.
- **R6.3** Can the platform log reads, not only writes? If not, log at the API or gateway layer (SAF-15).
- **R6.4** Does the platform support current TLS versions and certificate validation on all integration endpoints?
- **R6.5** Is there performance headroom? AI features can add many small queries; test load in non-production.
- **R6.6** Are business rules enforced in the application layer (so an AI write through the API is validated), or only in the user interface?
- **R6.7** Can changes be rolled back? Is the audit trail enabled for the objects AI would change (SAF-22)?

## R7. Identity and audit

- **R7.1** Are staff accounts in the CRM linked to the central directory (SSO), so an assistant acting for a user can carry that user's identity (SAF-03)?
- **R7.2** Are leavers removed from the CRM on time?
- **R7.3** Are CRM audit logs sent to the central log platform?
- **R7.4** Can you tell, from logs, which records a given integration account read last week?

## R8. Operations

- **R8.1** Is there monitoring and alerting for the platform and its integrations, with a named on-call?
- **R8.2** Is there a change process with maintenance windows and a rollback step?
- **R8.3** Is there a tested backup and restore for the objects an AI feature may change?
- **R8.4 UC** Is there a manual process the business can fall back to if the AI feature is off (SAF-24)?

## R9. Readiness decision

| Result | Meaning | What to do |
|---|---|---|
| **Ready** | No `no` or `unknown` in R3, R4.3, R4.6, R5.3, R5.4, R6.1, R6.3, R6.6, R6.7 for this use case | Continue to Gate 1 (`../governance/APPROVAL_GATES.md`) |
| **Ready for a read-only pilot** | Gaps only in write-back items (R6.6, R6.7, R8.3) | Pilot with suggest-only actions on masked or limited data; fix write-back gaps first |
| **Not ready** | Any `no` or `unknown` in R3 or in access-path items | Fix the foundations first; see the modernization pattern below |

---

## Secure modernization pattern (when the answer is "not ready")

Many organizations will find that the platform needs work before AI can be connected safely. A phased approach that keeps the business running:

| Phase | Goal | Typical work | Security success criteria | Rollback |
|---|---|---|---|---|
| 1. Discover | Know what exists | Integration inventory (R5), data classification for in-scope objects (R3), access-path list (R4) | Inventory reviewed by the platform owner; every integration has an owner | Not applicable (no change) |
| 2. Stabilize foundations | Remove the risks AI would amplify | Split shared integration accounts; move credentials to a secrets manager; turn on audit logging; put an API or gateway layer in front of legacy interfaces | No shared privileged integration account in scope; no clear-text integration credentials; reads logged at API layer | Each change is small and reversible; keep old credentials disabled, not deleted, until the new path is proven |
| 3. Read-only pilot | Prove value with low risk | One Tier 2 use case, suggest-only, field allowlist, masked data, through the gateway | Gate 2 passed; logs show only allowlisted fields; kill switch tested | Kill switch (SAF-24); manual process unchanged |
| 4. Controlled write-back | Let AI change records safely | Writes through business layer with validation, AI markers, limits, human confirmation | Audit trail shows AI identity; rollback tested; volume limits enforced | Restore from before/after values; disable write identity only |
| 5. Operate and review | Keep it safe as it changes | Gate 3 reviews; evaluation re-runs; access reviews | Reviews on schedule; no open SEV-1 or SEV-2 findings | Pause use case via Gate 3 decision |
