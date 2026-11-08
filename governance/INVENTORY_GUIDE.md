# How to fill in the AI use-case inventory

File: `ai_use_case_inventory.csv`. One row per AI use case. The two `EXAMPLE` rows are fictional; delete them when you start.

**What counts as a use case.** Any place where an AI model receives your data or influences a decision or action. Include:
- features you built (assistants, summarizers, scoring models, agents);
- AI features switched on inside products you already use (CRM, contact-center, ticketing, office and e-mail tools). These are easy to miss and often send data to a vendor model;
- tools staff use on their own, once you find them (SAF-08 helps with discovery).

**Columns.**

| Column | How to fill it |
|---|---|
| `use_case_id` | `UC-0001`, `UC-0002`, ... Never reuse an ID. Use it as a Kubernetes label and in key names (SAF-01, SAF-10). |
| `status` | `idea`, `pilot`, `production`, `paused`, `retired` |
| `ai_type` | `generative assistant`, `agent with tools`, `predictive or scoring model`, `classification`, `embedded vendor feature`, `other` |
| `hosting` | `vendor SaaS feature`, `vendor API via AI gateway`, `self-hosted model`, `other` |
| `customer_facing` | `yes` if customers see output or talk to it directly |
| `data_classes_used` | Classes from SAF-18 (Public, Internal, Confidential, Restricted) |
| `cpni_or_call_detail_used` | `yes`, `no`, `unknown`. "Unknown" blocks Gate 2. |
| `crm_objects_and_fields` | The approved data scope (SAF-02). Be specific. |
| `actions_allowed` | `none (read only)`, `suggest only`, `write with human confirmation`, `autonomous write` |
| `human_oversight` | Who checks what, and when |
| `risk_tier` | 1, 2 or 3 from `RISK_TIERING.md` |
| `gate_status` | Last gate passed (Gate 0 to Gate 4, see `APPROVAL_GATES.md`) |
| `baseline_essential_controls_status` | Count done / 18, and which are open |
| `data_copies_in_ai_systems` | Logs, caches, indexes, histories, provider storage (SAF-23) |
| `kill_switch_owner` | Person who can turn it off (SAF-24) |

**Review.** The AI governance lead reviews the whole inventory at least quarterly and whenever a vendor announces new AI features in a product you use.

AI RMF 1.0: supports GOVERN 1.6 (inventory of AI systems), MAP 1.1 and MAP 1.3 (context and goals), MAP 2.1 (task definition), MAP 3.3 (application scope) and MAP 4.1 (third-party components).
