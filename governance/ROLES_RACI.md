# Roles and RACI

In a small or mid-size provider one person often holds several roles. That is fine, with one rule: **the person who builds or buys a Tier 2 or Tier 3 use case should not be its only approver.**

AI RMF 1.0: GOVERN 2.1 (roles and lines of communication documented), GOVERN 2.3 (executive leadership takes responsibility), GOVERN 3.2 (roles for human-AI configurations and oversight). CSF 2.0: GV.RR-01, GV.RR-02.

## Roles

| Role | Typical holder in a small provider | Responsibilities |
|---|---|---|
| Accountable executive | CEO, COO or general manager | Owns AI risk appetite; approves Tier 3 use cases and accepted risks |
| AI governance lead | Security or IT lead | Runs the inventory, tiering and gates; tracks baseline status; reports to leadership |
| Use-case owner | Head of the business area (care, billing, sales) | Purpose, value, human oversight, kill-switch decision, periodic review |
| Technical owner | Platform, CRM or integration lead | Builds and runs the use case; implements baseline controls |
| Security | Security lead or external provider | Reviews controls, monitoring, incident handling |
| Privacy / Legal / Compliance | Counsel, CPNI compliance officer | Data use and disclosure, vendor terms, notification decisions |
| CRM platform owner | CRM administrator or team lead | Permissions, integrations, write-back paths, audit trail |
| Vendor management | Procurement or finance | Contracts and due diligence records for AI vendors |
| Staff users | Care agents, billing staff | Use the tool as trained; report wrong or strange output |

## RACI

R = responsible (does the work), A = accountable (decides, one per row), C = consulted, I = informed.

| Activity | Exec | AI gov lead | Use-case owner | Tech owner | Security | Privacy/Legal | CRM owner | Vendor mgmt |
|---|---|---|---|---|---|---|---|---|
| Set AI risk appetite and prohibited uses | A | R | C | I | C | C | I | I |
| Maintain the AI use-case inventory | I | A/R | R | R | I | I | C | C |
| Assign risk tier | I | A | R | C | C | C | C | I |
| Vendor due diligence (SAF-14) | I | C | C | C | C | C | I | A/R |
| Gate 1 design review | I (Tier 3: C) | A | R | R | C | C | C | C |
| Gate 2 go / no-go, Tier 1-2 | I | A | R | R | C | C | C | I |
| Gate 2 go / no-go, Tier 3 | A | R | R | R | C | C | C | I |
| Implement baseline controls | I | C | I | A/R | C | I | R | I |
| Monitoring and periodic review (Gate 3) | I | A | R | R | C | C | C | I |
| Kill switch decision during an incident | I | C | A | R | R | C | C | I |
| AI incident handling | I (SEV-1: C) | C | C | R | A/R | C | R | I |
| Notification decision (customers, regulators) | C | C | C | I | C | A/R | I | I |
| Retirement (Gate 4) | I | C | A | R | C | C | R | C |

Write the names next to each role in your own copy, and review the table when people change jobs.
