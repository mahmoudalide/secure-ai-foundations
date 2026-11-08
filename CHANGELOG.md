# Changelog

All notable changes to Secure AI Foundations are recorded here. Versions follow [Semantic Versioning](https://semver.org/): while the major version is 0, any release may change control IDs, levels or mappings.

## [0.1.0] - 2026-11-08 (draft for feedback)

### Added
- T1 baseline: 24 controls (SAF-01 to SAF-24) in seven domains, 18 Essential and 6 Enhanced, with objective, implementation guidance, verification steps and references (`baseline/SAF_BASELINE.md`); tracking sheet `baseline/saf_controls.csv`; Kubernetes examples for SAF-01, SAF-07 and SAF-09.
- T2 governance template mapped to NIST AI RMF 1.0: use-case inventory and guide, risk-tiering method, approval gates, AI incident playbook, roles and RACI.
- T3 AI-readiness checklist for CRM and customer-data platforms (43 questions, readiness decision, phased secure-modernization pattern) with CSV worksheets and an integration inventory template.
- `mappings/saf_mapping.csv`: 163 OLIR-style set-theory relationships to NIST CSF 2.0 (51), SP 800-53 Rev. 5 release 5.2.0 (76) and AI RMF 1.0 (36); `mappings/METHOD.md`; `mappings/tools/verify_ids.py`.
- Agent and tool-protocol guidance (MCP servers, audience-bound tokens, no token passthrough, agent memory) in SAF-03, SAF-13 and SAF-20; references aligned with the OWASP Top 10 for LLM Applications 2026 and the OWASP Top 10 for Agentic Applications for 2026.
- `NOVELTY.md`, `docs/REFERENCES.md`, `docs/ROADMAP.md`, `CONTRIBUTING.md`, `CITATION.cff`, licenses (Apache-2.0 for code and data, CC BY 4.0 for documentation).

### Known limitations
- Not yet piloted or independently reviewed.
- Mappings reflect one author's judgment.
- No Terraform examples; no cross-reference to OWASP AISVS requirement IDs yet.
