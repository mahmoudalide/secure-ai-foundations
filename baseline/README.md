# T1 - AI-Workload Security Control Baseline

| File | What it is |
|---|---|
| `SAF_BASELINE.md` | The 24 controls (SAF-01 to SAF-24): objective, implementation guidance, how to verify, references, NIST quick view |
| `saf_controls.csv` | The same controls as a tracking sheet: add status, evidence link and owner per control |
| `examples/` | Kubernetes manifests for SAF-01, SAF-07 and SAF-09 (namespace with restricted pod security, default-deny NetworkPolicy, egress only to an AI gateway, ServiceAccount without auto-mounted token) |

**Start here:** the 18 `Essential` controls are the minimum before an AI workload touches production customer data. The 6 `Enhanced` controls follow as use grows or for Tier 3 use cases.

**Using the examples.** They are starting points, not drop-in policy. Change names and labels, check that your network plugin enforces NetworkPolicy, and test in a non-production cluster first. Validate with `kubectl apply --dry-run=server -f baseline/examples/`.

Detailed NIST mappings: `../mappings/saf_mapping.csv`.
