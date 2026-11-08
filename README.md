# Secure AI Foundations (SAF)

**An open toolkit for connecting AI to customer-data platforms securely.**

Status: **v0.1 draft - feedback wanted.** Not yet piloted or independently reviewed. Do not treat it as a standard.

Author: Mahmoud Ali, Senior Security & Cloud Engineer, [mahmoudali.de](https://mahmoudali.de) (ORCID [0009-0004-9059-5737](https://orcid.org/0009-0004-9059-5737)). Version 0.1.0.

---

## Purpose

Organizations that run critical customer-data platforms (CRM, billing, service management) are adding AI: assistants for care agents, ticket summaries, scoring models, retrieval over customer records, and agents that can take actions. Each of these needs access to customer data. If the platform's identities, secrets, data flows and monitoring are weak, AI makes those weaknesses faster and larger.

SAF gives a security or IT lead a practical starting point: what controls to put in place, how to govern AI use cases, and how to check whether the platform is ready, all mapped to NIST frameworks so the work counts toward programs the organization may already run.

SAF extends the author's earlier open framework, *Security and Governance in Multi-Cloud Kubernetes Platforms: Lessons from Enterprise Deployments* (Zenodo, 2026, https://doi.org/10.5281/zenodo.20538172). That paper set out identity, policy-as-code, network, secrets, container and monitoring controls for cloud platforms, and noted that automation "built on a weak foundation simply makes mistakes faster." SAF applies the same control layer to AI workloads that touch customer records, and adds governance and readiness.

## Audience

Written first for **small and mid-size U.S. communications providers** (broadband, voice and mobile operators) and the people who run their customer-data platforms: the security lead, IT or platform lead, CRM administrator, and the managers who approve AI use. The same material may help other organizations that run sensitive customer-data platforms; the communications focus shows mainly in the CPNI-related guidance.

## What is in it

| Part | Folder | Contents |
|---|---|---|
| **T1** AI-workload security control baseline | `baseline/` | 24 controls (SAF-01 to SAF-24) in seven domains: identity and access for AI services and agents; secrets and model-provider keys; network egress; Kubernetes isolation for model serving; supply chain for models and containers; logging and monitoring with privacy; data protection when connecting AI to CRM and customer data. Each with objective, guidance, how to verify, references. Tracking sheet (CSV) and Kubernetes examples. |
| **T2** AI governance template | `governance/` | AI use-case inventory (CSV) and guide, risk-tiering method, approval gates, AI incident playbook, roles and RACI; mapped to the NIST AI RMF 1.0 functions Govern, Map, Measure, Manage. |
| **T3** AI-readiness checklist | `readiness/` | 43 questions on platform ownership, data quality, sensitivity and consent (including CPNI), access paths, integrations, legacy constraints, identity and audit, operations; a readiness decision; a phased secure-modernization pattern; worksheets (CSV). |
| Mappings | `mappings/` | `saf_mapping.csv`: 163 relationships from SAF controls to NIST CSF 2.0, SP 800-53 Rev. 5 and AI RMF 1.0, in the OLIR set-theory style. `METHOD.md` explains the method. `tools/verify_ids.py` checks every identifier against NIST's own data. |
| Context | root, `docs/` | `NOVELTY.md` (comparison with existing resources), `docs/REFERENCES.md`, `docs/ROADMAP.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `CITATION.cff` |

## How to use it

**In 1 day**
1. Read this page and `baseline/SAF_BASELINE.md` domains A, B and G.
2. List every AI use case you know of in `governance/ai_use_case_inventory.csv`, including AI features switched on in products you already use.
3. For the riskiest one, check the 18 Essential controls in `baseline/saf_controls.csv`. Mark each done, partial or not started.
4. Fix the quick wins: move any model-provider key out of code (SAF-05), set usage limits on keys (SAF-06), make sure the AI does not use a shared or admin account (SAF-01).

**In 1 week**
1. Tier every inventoried use case with `governance/RISK_TIERING.md`.
2. Run the readiness checklist (`readiness/AI_READINESS_CHECKLIST.md`) for your main CRM platform. Start the integration inventory.
3. Agree roles with `governance/ROLES_RACI.md` and name a kill-switch owner per use case.
4. Run Gate 2 (`governance/APPROVAL_GATES.md`) on anything already in production with customer data. Record the gaps with owners and dates.

**In 1 month**
1. Close the Essential-control gaps for Tier 2 and Tier 3 use cases; apply default-deny egress and restricted pod security (see `baseline/examples/`).
2. Put production model traffic through one gateway or proxy (SAF-08) and start the misuse detections (SAF-16).
3. Build an evaluation set per use case, including prompt-injection tests (SAF-17, SAF-21).
4. Run one tabletop from `governance/AI_INCIDENT_PLAYBOOK.md`.
5. Use `mappings/saf_mapping.csv` to show how this work supports your CSF 2.0 or SP 800-53 program.

## Scope and non-goals

In scope: organizations that **deploy and connect** AI (vendor APIs, vendor AI features, self-hosted open-weight models, retrieval and agents) to customer-data platforms.

Not in scope (v0.1):
- training or fine-tuning large models, or securing model development (see NIST SP 800-218A);
- AI used for cyber defense, and defense against AI-enabled attacks;
- fairness and bias evaluation methods, and AI ethics policy beyond what the governance gates ask for;
- legal advice. Where SAF mentions CPNI rules or notification duties, it tells you to ask counsel;
- certification. SAF is not a standard and mapping to NIST does not mean compliance with NIST;
- product recommendations. Tools are named only as examples.

## Status

**v0.1 draft - feedback wanted.** This is a first public draft by one author. It has not been piloted with an organization or reviewed by an independent expert. Expect changes to control wording, levels and mappings. See `docs/ROADMAP.md` for what comes next.

## Feedback and contributions

Feedback is the main goal of this release. Especially useful:
- "We tried control SAF-xx and it did not work because ..."
- missing controls or readiness questions for your platform;
- corrections to any NIST mapping;
- overlaps with resources we missed (`NOVELTY.md`).

How: open an issue in this repository (https://github.com/mahmoudalide/secure-ai-foundations/issues), see `CONTRIBUTING.md`, or e-mail mail@mahmoudali.de.

## License

- Documentation (all Markdown files): **Creative Commons Attribution 4.0 International (CC BY 4.0)**, full text in `LICENSE-DOCS`.
- Code, configuration and data files (`*.py`, `*.yaml`, `*.csv`): **Apache License 2.0**, full text in `LICENSE`.

NIST identifiers and the short NIST element descriptions in `mappings/saf_mapping.csv` come from NIST publications; NIST publications are generally not subject to copyright in the United States. OWASP, CISA and other cited works keep their own licenses.

## How to cite

See `CITATION.cff`. Suggested: Ali, M. (2026). *Secure AI Foundations* (Version 0.1.0) [Computer software and documentation].

## Disclaimer

Provided "as is", without warranty. Test every control in your own environment before relying on it. Nothing here is legal advice.
