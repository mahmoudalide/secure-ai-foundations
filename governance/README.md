# T2 - AI Governance Template (mapped to NIST AI RMF 1.0)

This is a small, working governance kit for an organization that has a security or IT lead, a few managers, and no dedicated AI governance team. It gives you five things to fill in and run, each tied to the four functions of the NIST AI Risk Management Framework ([AI-RMF]): **Govern, Map, Measure, Manage**.

| File | Purpose | Main AI RMF functions |
|---|---|---|
| `ai_use_case_inventory.csv` + `INVENTORY_GUIDE.md` | One row per AI use case, including vendor features you switched on; the guide explains each column | Govern, Map |
| `RISK_TIERING.md` | A simple method to place each use case in Tier 1, 2 or 3, and what each tier requires | Map, Measure, Manage |
| `APPROVAL_GATES.md` | Five gates from intake to retirement, with checklists | Govern, Map, Measure, Manage |
| `AI_INCIDENT_PLAYBOOK.md` | How to recognize, contain and learn from AI incidents | Manage (and CSF Respond/Recover) |
| `ROLES_RACI.md` | Who decides, who does the work, who is consulted | Govern |

## How it fits together

1. **Inventory** every AI use case (Govern). Unknown AI is the first risk.
2. **Tier** each use case (Map). The tier decides how much review and which baseline controls apply.
3. **Gate** it: no production use of customer data without passing Gate 2 (Map, Measure).
4. **Monitor and review** at the interval the tier sets (Measure, Manage).
5. **Respond** with the playbook when something goes wrong, and **retire** use cases deliberately (Manage, Govern).

## AI RMF coverage of this template

The table shows which AI RMF 1.0 subcategories each part is designed to help with. "Helps with" means the artifact gives you a way to produce the outcome; it does not mean the subcategory is fully met. Identifiers were checked against the NIST AI RMF Playbook data (https://airc.nist.gov/docs/playbook.json) on 2026-11-08.

| Artifact | AI RMF 1.0 subcategories it helps with |
|---|---|
| Use-case inventory | GOVERN 1.6, MAP 1.1, MAP 1.3, MAP 2.1, MAP 3.3, MAP 4.1 |
| Risk tiering | GOVERN 1.3, MAP 1.5, MAP 3.2, MAP 5.1, MANAGE 1.2, MANAGE 1.3 |
| Approval gates | GOVERN 1.4, GOVERN 1.7, MAP 3.5, MAP 4.2, MEASURE 1.1, MEASURE 2.7, MEASURE 2.10, MANAGE 1.1, MANAGE 1.4 |
| Monitoring and periodic review (Gate 3) | GOVERN 1.5, MEASURE 2.4, MEASURE 3.1, MANAGE 3.2, MANAGE 4.1 |
| Incident playbook | GOVERN 4.3, MANAGE 2.3, MANAGE 2.4, MANAGE 4.3, GOVERN 6.2 |
| Roles and RACI | GOVERN 2.1, GOVERN 2.3, GOVERN 3.2 |

Subcategories that this v0.1 template does **not** address in a meaningful way include the workforce diversity outcomes (GOVERN 3.1, MAP 1.2), human-subject evaluation (MEASURE 2.2), fairness and bias evaluation methods (MEASURE 2.11) and environmental impact (MEASURE 2.12). Use the NIST AI RMF Playbook ([AI-RMF-PB]) for those.

## Before you start

- Name one person as **AI governance lead**. In a small provider this is usually the security or IT lead.
- Agree the risk appetite in one paragraph with leadership: which AI uses are welcome, which need review, which are not allowed (see "Prohibited and restricted uses" in `RISK_TIERING.md`).
- Decide where the inventory lives (a shared spreadsheet is fine to start).

References: see `../docs/REFERENCES.md`.
