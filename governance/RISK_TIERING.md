# Risk tiering method

Purpose: decide quickly how much review a use case needs, so low-risk uses are not held up and high-risk uses get real scrutiny. This is a screening method, not a full risk assessment. Record the result and the reasons in the inventory (`risk_tier`, `tier_rationale`).

AI RMF 1.0: GOVERN 1.3 (level of risk management based on risk tolerance), MAP 1.5 (risk tolerances documented), MAP 3.2 (potential costs of errors), MAP 5.1 (likelihood and magnitude of impacts), MANAGE 1.2 and MANAGE 1.3 (prioritized treatment and response).

## Step 1 - Answer four questions

| Factor | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **D. Data** - most sensitive class the AI receives or can retrieve (SAF-18) | Public only | Internal | Confidential (customer personal data) | Restricted (CPNI and call detail, payment data, government IDs, authentication data) |
| **A. Action** - what the AI can do | Nothing beyond showing text to staff | Suggests; a person decides and acts | Writes or acts with human confirmation | Writes or acts without per-action human confirmation |
| **P. People affected** - who sees output or is affected by it | Internal staff, no effect on customers | Staff output that may reach customers after review | Customers see output directly | Output affects a customer's service, charges, eligibility or account security |
| **X. Exposure** - where data goes | Stays on systems you run | Approved enterprise vendor, no-training and retention terms in contract (SAF-14) | Vendor terms incomplete or not yet reviewed | Consumer-grade tool or unknown terms |

## Step 2 - Apply the tier rules

- **Tier 3 (high)** if any of: D = 3; A = 3; P = 3; X = 3; or the total D+A+P+X is 8 or more.
- **Tier 2 (medium)** if not Tier 3 and any of: D = 2; A = 2; P = 2; X = 2; or the total is 4 or more.
- **Tier 1 (low)** otherwise.

The thresholds are a starting point. Change them to match your risk appetite, write the change in the change log of your own copy, and apply them consistently.

**Examples (fictional).** An internal tool that drafts knowledge-base articles from public product documents: D0 A1 P1 X1 = Tier 1. A ticket summarizer that reads masked service-request notes, suggest-only: D2 A1 P0 X1 = Tier 2. An agent that applies account credits: A2, P3 = Tier 3.

## Step 3 - Apply what the tier requires

| | Tier 1 | Tier 2 | Tier 3 |
|---|---|---|---|
| Inventory entry | Required | Required | Required |
| Approver at Gate 2 | Use-case owner + AI governance lead | + Security, + Privacy/Legal | + Accountable executive |
| SAF baseline | Essential controls that apply | All Essential controls | All Essential + all Enhanced controls |
| Evaluation before release (SAF-17, SAF-21) | Basic quality check | Evaluation set incl. injection tests | Evaluation set + independent review by someone outside the build team |
| Human oversight | Optional | Defined and documented | Defined, documented and tested; per-action confirmation for high-impact actions (SAF-03) |
| Periodic review (Gate 3) | Every 12 months | Every 6 months | Every 3 months and after every model or prompt change |
| Kill switch tested (SAF-24) | Not required | Before production | Before production and every 6 months |

## Prohibited and restricted uses (fill in with leadership)

Write down what the organization will not do with AI, and what needs a decision from the accountable executive. Examples to discuss:

- Not allowed: entering Restricted data into consumer AI tools; using AI to make final decisions to disconnect service without human review; letting an AI system change account security settings (contact details, SIM, port-out) without human confirmation.
- Executive decision needed: customer-facing generative assistants that can disclose account information; any use of CPNI for a new purpose (check approval rules with counsel, [CPNI] s.64.2007).

## Re-tier when

The model or vendor changes, the data scope grows, actions are added, the audience changes (for example from staff to customers), or an incident occurs.
