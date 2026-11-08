# Roadmap

Planned, not promised. Order and timing depend on feedback and pilot results. Each release is versioned, dated and listed in `CHANGELOG.md`.

## v0.1 (this draft)
Baseline (24 controls), governance template, readiness checklist, OLIR-style NIST mappings, comparison with existing resources. Goal: collect feedback.

## v0.2 - after first feedback
- Rework controls and questions based on issues and reviewer comments.
- Cross-reference SAF controls to OWASP AISVS requirement IDs, so users can go deeper where AISVS is more detailed.
- Add an "evidence pack" list per control: what to save for an auditor.
- Add Terraform examples for key scoping, egress rules and secrets-manager access (SAF-05 to SAF-07).
- Archive the release with a DOI.

## v0.3 - pilot lessons and OLIR
- Lessons from pilots with a small number of organizations, with all organization details removed.
- Prepare OLIR submissions for CSF 2.0, SP 800-53 Rev. 5 and AI RMF 1.0 following `mappings/METHOD.md`.
- Short guides: "First week with SAF" and "Running Gate 2 in an afternoon".
- Example policy-as-code rules (Kyverno or Gatekeeper) for SAF-10.

## v1.0 - complete first edition
- All three parts revised after pilots and at least one independent review.
- Workshop material (slides and exercises) based on the incident tabletops and the readiness checklist.

## Tracking NIST and CISA work
Update mappings and content when these are published or revised:
- SP 800-53 control overlays for AI/SI systems (COSIS), https://csrc.nist.gov/projects/cosais
- CSF 2.0 Cyber AI Profile (NIST IR 8596), https://csrc.nist.gov/pubs/ir/8596/iprd
- AI RMF revision and the AI RMF profile on trustworthy AI in critical infrastructure, https://www.nist.gov/itl/ai-risk-management-framework
- CISA and partner guidance on the CISA topic page, https://www.cisa.gov/topics/cybersecurity-best-practices/super-intelligence

## Not planned
- Certification or a compliance seal.
- A commercial edition of the toolkit content. The toolkit stays openly licensed.
