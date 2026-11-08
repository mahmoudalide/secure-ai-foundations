# Mapping method

`saf_mapping.csv` maps each SAF baseline control (SAF-01 to SAF-24) to elements of three NIST documents:

| Focal document | Element level used | Official source used to verify identifiers and text |
|---|---|---|
| NIST Cybersecurity Framework (CSF) 2.0 (CSWP 29, Feb 2024) | Subcategory (for example `PR.AA-05`) | NIST CPRT export of CSF 2.0 (https://csrc.nist.gov/extensions/nudp/services/json/nudp/framework/version/csf_2_0_0/export/json?element=all), with withdrawn CSF 1.1 subcategories removed; cross-checked against the 106 subcategories in Appendix A of https://doi.org/10.6028/NIST.CSWP.29 |
| NIST SP 800-53 Rev. 5 | Control or control enhancement (for example `SC-7(5)`) | NIST OSCAL catalog, release 5.2.0 (https://github.com/usnistgov/oscal-content, file `nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json`); cross-checked against the control catalog spreadsheet on csrc.nist.gov (https://csrc.nist.gov/CSRC/media/Publications/sp/800-53/rev-5/final/documents/sp800-53r5-control-catalog.xlsx). No withdrawn control is used. |
| NIST AI RMF 1.0 (NIST AI 100-1, Jan 2023) | Subcategory (for example `MEASURE 2.10`) | NIST AI RMF Playbook data (https://airc.nist.gov/docs/playbook.json), cross-checked against Tables 1-4 of https://doi.org/10.6028/NIST.AI.100-1 (72 subcategories) |

All identifiers were checked on 2026-11-08. `tools/verify_ids.py` repeats the check against the live NIST sources and also checks every NIST identifier mentioned anywhere in the toolkit's Markdown and CSV files. Run it before every release:

```
python3 mappings/tools/verify_ids.py
```

## Relationship style: OLIR set theory

The file follows the **set theory relationship mapping** style of the NIST National Online Informative References (OLIR) Program, described in NIST IR 8278A Rev. 1, *Submission Guidance for OLIR Developers* (February 2024), https://csrc.nist.gov/pubs/ir/8278/a/r1/final, and NIST IR 8477 (February 2024), https://csrc.nist.gov/pubs/ir/8477/final.

In OLIR terms:
- the NIST document is the **Focal Document**, and each NIST identifier is a **Focal Document Element**;
- Secure AI Foundations is the **Reference Document**, and each SAF control is a **Reference Document Element**.

Each row states:

| Column | Meaning |
|---|---|
| `saf_id`, `saf_control` | Reference Document Element and its name |
| `focal_document`, `focal_element_id` | Focal Document and Focal Document Element |
| `focal_element_description` | The official NIST text (CSF and AI RMF) or control name (SP 800-53), copied from the sources above |
| `rationale` | Why the elements are related. IR 8278A r1 allows `syntactic` (word-for-word), `semantic` (interpretation of meaning) or `functional` (comparison of outcomes). |
| `relationship` | How the SAF control compares with the NIST element. IR 8278A r1 allows `subset of`, `intersects with`, `equal`, `superset of`, `not related to`. |
| `comments` | What the SAF control contributes, or what it adds beyond the NIST element |

### How relationships were chosen

- **`subset of`**: everything the SAF control asks for is within the NIST element, applied to AI workloads. Example: SAF-02 (least-privilege AI access to customer data) is a subset of SP 800-53 AC-6 (Least Privilege).
- **`intersects with`**: the two share content, but the SAF control also contains something the NIST element does not (or the reverse). This is the most common value, because each SAF control combines several practices for one AI scenario. Example: SAF-07 (default-deny egress for AI workloads) intersects with SC-7(5); SAF-07 also covers hostname allowlists, metadata-endpoint access and agent web access.
- **`equal`** and **`superset of`** were not used in v0.1. No SAF control is the same as, or wider than, a whole NIST element.
- `not related to` rows are not listed; a missing pair means "no relationship asserted".

### How rationale was chosen

- **`semantic`** for CSF 2.0 and SP 800-53: the SAF text was compared with the meaning of the NIST element.
- **`functional`** for AI RMF 1.0: AI RMF subcategories describe organizational outcomes (for example "Mechanisms are in place to inventory AI systems"); the assertion is that implementing the SAF control helps produce that outcome.
- **`syntactic`** was not used; SAF does not quote NIST text.

### What the mapping does not claim

- A mapping is not a compliance statement. Implementing a SAF control does not mean the NIST element is fully met.
- The mapping is one author's judgment in v0.1. It has not been reviewed by NIST or anyone else.
- Strength-of-relationship scores (optional in IR 8278A r1) are not included in v0.1.

## Toward an OLIR submission

The OLIR Program accepts third-party mappings to NIST documents (submission page: https://csrc.nist.gov/projects/olir/olir-submissions). The OLIR catalog already lists several AI-related third-party mappings (see `../NOVELTY.md`). To submit SAF mappings, the steps would be:

1. Freeze a SAF version (for example v0.2 after feedback) with a DOI.
2. Download the official OLIR Focal Document Templates for CSF 2.0, SP 800-53 Rev. 5 and AI RMF 1.0 from https://csrc.nist.gov/projects/olir/focal-document-templates. Each focal document is a separate OLIR.
3. Move the rows from `saf_mapping.csv` into each template. Follow the template's identifier format exactly (the IR 8278A r1 examples write SP 800-53 enhancements with a space, as in `SC-7 (5)`; this CSV writes `SC-7(5)`). Add one entry per relationship, as the guidance requires.
4. Decide whether to state "Comprehensive = No" (likely, because SAF does not map every focal element).
5. Complete the General Information sheet and the Participation Agreement (IR 8278A r1, Appendix A), and submit as the OLIR Developer.
6. Respond to NIST review and the public comment period.

Re-check the submission requirements on the NIST page at the time of submission; they may change.

## Updating the mapping

- When NIST publishes the SP 800-53 AI control overlays (COSIS, https://csrc.nist.gov/projects/cosais), the final Cyber AI Profile (NIST IR 8596), or a revised AI RMF, add mappings in a new release and keep the version of each focal document in `focal_document`.
- Changes to `saf_mapping.csv` must pass `tools/verify_ids.py`.
