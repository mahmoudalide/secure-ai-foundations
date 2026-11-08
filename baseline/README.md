# T1 - AI-Workload Security Control Baseline

| File | What it is |
|---|---|
| `SAF_BASELINE.md` | The 24 controls (SAF-01 to SAF-24): objective, implementation guidance, how to verify, references, NIST quick view |
| `saf_controls.csv` | The same controls as a tracking sheet: add status, evidence link and owner per control |
| `examples/` | Kubernetes manifests for SAF-01, SAF-07 and SAF-09 (namespace with restricted pod security, default-deny NetworkPolicy, egress only to an AI gateway, ServiceAccount without auto-mounted token) |

**Start here:** the 18 `Essential` controls are the minimum before an AI workload touches production customer data. The 6 `Enhanced` controls follow as use grows or for Tier 3 use cases.

**Using the examples.** They are starting points, not drop-in policy. Change names and labels, check that your network plugin enforces NetworkPolicy, and test in a non-production cluster first. Validate in two steps, because a server-side dry run does not create the namespace: run `kubectl apply --dry-run=server -f baseline/examples/namespace-ai-restricted.yaml`, create the namespace with `kubectl apply -f baseline/examples/namespace-ai-restricted.yaml`, then dry-run the other three files.

**Tested.** On 2026-11-08 the examples were tested on Kubernetes v1.36.4 with the kindnet network plugin (with its built-in `kube-network-policies` controller), on a single node. Tested: Pod Security `restricted` enforcement, no ServiceAccount token, default deny, and egress limited to DNS and the AI gateway. All 32 checks passed. See `../tests/k8s/RESULTS_2026-11-08.md`; re-run with `tests/k8s/run_tests.sh <kube-context>` in a non-production cluster. Other network plugins, multi-node clusters and IPv6 are not yet tested.

Detailed NIST mappings: `../mappings/saf_mapping.csv`.
