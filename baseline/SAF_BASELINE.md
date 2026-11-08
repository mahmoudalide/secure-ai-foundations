# SAF Baseline v0.1: Security Controls for AI Workloads on Customer-Data Platforms

Status: v0.1 draft, feedback wanted. License: CC BY 4.0 (see `LICENSE-DOCS`).

This baseline lists the controls an AI workload should meet **before it is allowed to read or change customer records**. "AI workload" means anything that sends data to a model or acts on a model's output: a chat assistant for care agents, a summarizer for tickets, a scoring model, a retrieval (RAG) service, or an agent that can call tools.

It continues the control layer from Ali (2026), *Security and Governance in Multi-Cloud Kubernetes Platforms* ([WP]), and applies it to the new things AI adds: model-provider keys, prompts and outputs that carry customer data, retrieval indexes, agents that take actions, and models as supply-chain components. Where the paper already covers a control (for example workload identity or image signing), this baseline points to it and only adds the AI-specific part.

## How to read a control

Each control has:

- **ID and level.** `Essential` = do this before any production AI use of customer data. `Enhanced` = do this as use grows or for Tier 3 (high-risk) use cases (see `governance/RISK_TIERING.md`).
- **Objective** - the outcome, in one or two sentences.
- **Implementation guidance** - practical steps. Pick tools that fit your platform; the controls are tool-neutral.
- **How to verify** - checks a reviewer or auditor can run and keep as evidence.
- **References** - keys resolve to `docs/REFERENCES.md`.
- **Mapped to** - a quick view of NIST mappings. The authoritative list, with relationship types and rationale, is `mappings/saf_mapping.csv`.

## Domains

| Domain | Controls |
|---|---|
| A. Identity and access for AI services and agents | SAF-01 to SAF-04 |
| B. Secrets and model-provider keys | SAF-05, SAF-06 |
| C. Network egress control | SAF-07, SAF-08 |
| D. Kubernetes isolation for model serving | SAF-09 to SAF-11 |
| E. Supply chain for models and containers | SAF-12 to SAF-14 |
| F. Logging and monitoring with privacy | SAF-15 to SAF-17 |
| G. Data protection when connecting AI to CRM and customer data | SAF-18 to SAF-24 |

A machine-readable list is in `baseline/saf_controls.csv`.

---

## A. Identity and access for AI services and agents

### SAF-01 Distinct identity for every AI service and agent
**Level:** Essential

**Objective.** Every AI component that calls a model, reads customer data or takes an action runs under its own non-human identity with a named owner, so its access can be scoped, reviewed and revoked without touching anything else.

**Implementation guidance.**
- Create one service identity per AI use case and per environment (dev, test, prod). Record the owner and the use-case ID from the AI use-case inventory (`governance/ai_use_case_inventory.csv`).
- Do not reuse a human account or a shared "integration user". Older CRM estates often have one powerful integration account used by many interfaces; an AI feature must not be added to it.
- In Kubernetes, give each AI workload its own ServiceAccount and set `automountServiceAccountToken: false` unless the pod needs the Kubernetes API.
- For cloud-hosted models and services, use workload identity federation instead of static keys ([WP] section 3.2 lists the AWS, GCP and OCI mechanisms).

**How to verify.**
- List every identity used by AI workloads. Each maps to exactly one use case and one owner.
- No AI workload authenticates with a human account or a shared integration account.
- Disable one AI identity in a test environment and confirm only that use case stops.

**References.** [WP] s.3.2; [K8S-SA]; [DAI]

**Mapped to.** <!-- MAP:SAF-01 --> CSF 2.0: PR.AA-01, PR.AA-03; SP 800-53r5: AC-2, IA-4, IA-9; AI RMF: GOVERN 1.6, MANAGE 2.4.

### SAF-02 Least-privilege access from AI to customer data
**Level:** Essential

**Objective.** An AI identity can reach only the objects, records and fields its approved use case needs, and is read-only unless write access was explicitly approved.

**Implementation guidance.**
- Write the data scope of each use case as a list of CRM objects and fields (for example "service request: status, category, last 5 notes; customer: first name only"). Store it with the use-case record.
- Enforce the scope in the CRM's own permission model (roles, responsibilities, visibility rules) or in a purpose-built API or view. Do not give AI workloads direct database credentials.
- Use separate identities for read and for write, so write access can be withdrawn without breaking read-only features.
- Make pilot grants time-limited. Review granted against used permissions at a fixed interval and remove the difference ([WP] s.3.3).

**How to verify.**
- Compare the permissions granted to each AI identity with the approved data scope.
- Using the AI identity in test, try to read a field outside the scope. The platform, not the prompt, must deny it.
- Keep the last access-review record.

**References.** [WP] s.3.3; [DAI]; [OWASP-LLM] LLM02:2026, LLM03:2026

**Mapped to.** <!-- MAP:SAF-02 --> CSF 2.0: PR.AA-05; SP 800-53r5: AC-6, AC-3, AC-6(7); AI RMF: MAP 4.2.

### SAF-03 Agent tools, delegated permissions and human confirmation
**Level:** Essential

**Objective.** An AI agent can call only tools on an approved list, can never do more than the person it acts for is allowed to do, and needs a human to confirm high-impact actions.

**Implementation guidance.**
- Keep an allowlist of tools and actions per agent in configuration under version control. The tool layer enforces it; instructions in a prompt are not a control.
- When an assistant acts for a logged-in employee or customer, pass that user's identity to the back end (delegated or "on-behalf-of" tokens) so the CRM applies that user's visibility, not the agent's.
- Define high-impact actions for your business. For communications providers these usually include changes to contact details or account ownership, SIM changes, number port-out related steps, credits and refunds, bulk exports and deletions. Require explicit human confirmation for them.
- If agents reach tools through the Model Context Protocol (MCP) or a similar tool protocol, connect them only to MCP servers on the approved list. For remote MCP servers, use OAuth tokens issued for that specific server (audience-bound, with RFC 8707 resource indicators), and never forward a user's or the agent's token to another service ("token passthrough"), as the MCP authorization specification requires ([MCP-AUTH]; [MCP-SEC]).
- Treat tool descriptions and tool results as untrusted input (SAF-21). A changed tool description or a new tool on an approved server is a change that needs review.
- Limit how many actions an agent may take per session and per hour, and provide a per-use-case switch that disables actions while leaving read-only help running (see SAF-24).

**How to verify.**
- The tool list in configuration matches the approval record.
- Ask the agent to perform an action that is not allowlisted; the tool layer refuses it and logs the attempt.
- A high-impact action creates a confirmation request instead of executing.
- An agent session for a low-privilege user cannot return records that user cannot see.
- Every MCP server an agent can reach is on the approved list, and a token issued for one server is rejected by another.

**References.** [OWASP-LLM] LLM03:2026; [OWASP-ASI] ASI02, ASI03; [MCP-AUTH]; [MCP-SEC]; [AGENTIC]; [DAI]; [AI-600-1]

**Mapped to.** <!-- MAP:SAF-03 --> CSF 2.0: PR.AA-05; SP 800-53r5: AC-3, AC-3(2), AC-6; AI RMF: GOVERN 3.2, MAP 3.5, MANAGE 2.4.

### SAF-04 Administrative access to AI platforms and AI configuration
**Level:** Essential

**Objective.** Administration of model settings, system prompts, retrieval indexes, the AI gateway and model-serving clusters is limited to named people using single sign-on, multi-factor authentication and short-lived elevation, and every change is reviewed and logged.

**Implementation guidance.**
- Apply the human-access pattern from [WP] s.3.1: SSO, MFA (phishing-resistant for privileged roles), role-based access mapped to directory groups, just-in-time elevation.
- Treat system prompts, tool definitions, model routing and safety settings as production configuration. Change them through version control with review, not in a vendor console without a record.
- Remove local or vendor-default admin accounts from AI tools, or vault and monitor them if they cannot be removed.

**How to verify.**
- List administrators of each AI platform; every one is a named person with MFA enforced.
- Pick the last change to a system prompt or tool definition and show its review record.
- No shared or local admin account is in daily use.

**References.** [WP] s.3.1, s.4; [SP800-63-4]

**Mapped to.** <!-- MAP:SAF-04 --> CSF 2.0: PR.AA-03, PR.AA-05, PR.PS-01; SP 800-53r5: IA-2(1), AC-6(5), CM-3; AI RMF: MANAGE 4.1.

---

## B. Secrets and model-provider keys

### SAF-05 Model-provider credentials stay in a secrets manager
**Level:** Essential

**Objective.** API keys and tokens for model providers, vector databases and AI SaaS tools never appear in source code, container images, notebooks, prompts, client-side code or CRM configuration tables; workloads fetch them at runtime with their own identity.

**Implementation guidance.**
- Keep all AI-related credentials in a central secrets manager ([WP] s.6). Prefer keyless access through workload identity where the model provider supports it.
- Never place a provider key in a browser or mobile app. Client apps call your back end or AI gateway, which holds the key (SAF-08).
- Run secret scanning on commits and on existing repositories, including notebooks and infrastructure code. Block commits that contain keys.
- Enable encryption at rest for Kubernetes Secrets; base64 encoding is not encryption ([WP] s.6; [K8S-ENC]).
- Do not paste keys or passwords into prompts, system prompts or tickets that AI tools can read.

**How to verify.**
- A secret-scanning report across repositories and images shows no live AI credentials.
- Front-end bundles and mobile builds contain no provider keys.
- The Kubernetes API server has an encryption configuration for Secrets.

**References.** [WP] s.6; [K8S-SECRETS]; [K8S-ENC]; [OWASP-LLM] LLM02:2026, LLM08:2026

**Mapped to.** <!-- MAP:SAF-05 --> CSF 2.0: PR.AA-01, PR.DS-01; SP 800-53r5: IA-5, IA-5(7), SC-28.

### SAF-06 Key scoping, usage limits, rotation and revocation
**Level:** Essential

**Objective.** Each provider credential belongs to one use case and one environment, has usage and spending limits, is rotated on a defined schedule, and can be revoked and replaced quickly.

**Implementation guidance.**
- Issue separate keys or projects per use case and environment, so a leak or a cost spike can be traced and stopped without affecting other services.
- Set provider-side usage or spending limits and alerts where the provider offers them.
- Rotate on an organization-defined schedule, after staff with access leave, and immediately on suspected exposure.
- Write and test a revocation runbook: who can revoke, where, and how the replacement key is distributed.

**How to verify.**
- The key inventory matches what the provider console shows; there are no unowned keys.
- Usage or spend alerts are configured for each production key.
- A tabletop or test shows a key can be revoked and replaced; record how long it took.

**References.** [WP] s.6; [OWASP-LLM] LLM06:2026; [TOKENS]

**Mapped to.** <!-- MAP:SAF-06 --> CSF 2.0: PR.AA-01, DE.CM-06; SP 800-53r5: IA-5; AI RMF: MANAGE 3.1.

---

## C. Network egress control

### SAF-07 Default-deny egress for AI workloads
**Level:** Essential

**Objective.** AI workloads can reach only approved destinations (named model endpoints and the internal services they need); all other outbound traffic is blocked.

**Implementation guidance.**
- In Kubernetes, apply a default-deny egress NetworkPolicy in every AI namespace, then allow DNS and the egress proxy or gateway only (see `baseline/examples/`).
- Kubernetes NetworkPolicy works on IP addresses. To allow by hostname (for example a provider API), use an egress proxy, an egress gateway, or a network plugin that supports hostname rules.
- Confirm that your network plugin enforces NetworkPolicy; a policy that is written but not enforced gives false assurance ([WP] s.5.1).
- Restrict access to the cloud instance metadata endpoint to what the workload identity mechanism needs.
- Agent tools that fetch web pages or files need their own sandboxed egress path, separate from the path to customer data.

**How to verify.**
- From a pod in an AI namespace, a request to an unapproved host fails and a request to an approved endpoint succeeds.
- Every AI namespace has a default-deny egress policy.
- The network plugin is documented as enforcing egress policy.

**References.** [WP] s.5; [K8S-NP]; [SP800-207]

**Mapped to.** <!-- MAP:SAF-07 --> CSF 2.0: PR.IR-01; SP 800-53r5: SC-7, SC-7(5), SC-7(8), AC-4.

### SAF-08 Central AI gateway and detection of unapproved AI services
**Level:** Enhanced

**Objective.** Production calls to external models pass through one controlled path (AI gateway, API gateway or forward proxy) that authenticates callers, applies data rules, limits rates and logs; use of AI services that are not in the inventory is detected.

**Implementation guidance.**
- Route model traffic through a gateway that holds the provider keys (SAF-05). Applications receive gateway credentials scoped to their use case.
- Apply data filtering (SAF-19), rate limits and per-use-case quotas at the gateway.
- Allow outbound access to model-provider endpoints only from the gateway.
- Review DNS and proxy logs for traffic to AI services not in the use-case inventory. Add or block what you find; do not ignore it.

**How to verify.**
- Firewall or egress rules show that only the gateway can reach model-provider endpoints.
- A dated report of AI-service domains seen in DNS or proxy logs is reconciled against the inventory.

**References.** [DAI]; [OWASP-LLM] LLM06:2026

**Mapped to.** <!-- MAP:SAF-08 --> CSF 2.0: PR.IR-01, DE.CM-01, ID.AM-02; SP 800-53r5: SC-7(8), AC-4, SI-4; AI RMF: GOVERN 1.6.

---

## D. Kubernetes isolation for model serving

### SAF-09 Isolated namespaces and hardened pods for AI workloads
**Level:** Essential

**Objective.** Model serving, retrieval and agent workloads run in dedicated namespaces (or clusters) with restricted pod security, so a compromised AI component cannot reach other workloads or the node.

**Implementation guidance.**
- Use a separate namespace per AI use case or risk tier. Put Tier 3 use cases, or workloads that hold large copies of customer data, on separate node pools or clusters ([WP] s.5.1).
- Enforce the Pod Security Standards `restricted` profile with Pod Security Admission (label the namespace `pod-security.kubernetes.io/enforce: restricted`). Run as non-root, read-only root file system, no privilege escalation, drop all capabilities.
- GPU serving often needs device plugins or drivers that conflict with the restricted profile. Document each exception, limit it to the namespace that needs it and review it.
- Apply default-deny ingress NetworkPolicies so only the gateway or calling service can reach model endpoints.

**How to verify.**
- `kubectl get ns --show-labels` shows the enforce label on every AI namespace.
- Deploying a privileged test pod into an AI namespace is rejected.
- The list of documented exceptions matches what is running.

**References.** [WP] s.5, s.7; [K8S-PSS]; [K8S-PSA]; [K8S-HARDEN]; [SP800-190]

**Mapped to.** <!-- MAP:SAF-09 --> CSF 2.0: PR.PS-01, PR.IR-01; SP 800-53r5: SC-7(21), CM-6, CM-7, SC-39.

### SAF-10 Admission policy, labels and resource limits for AI workloads
**Level:** Enhanced

**Objective.** Policies enforced at admission ensure AI workloads come from approved registries, are signed, declare resource limits (including GPUs), and carry labels that link them to the governance inventory.

**Implementation guidance.**
- Use a policy engine such as Kyverno or OPA Gatekeeper ([WP] s.4) to require: approved registry, verified signature (SAF-13), CPU, memory and GPU requests and limits, and labels for `use-case-id`, `owner` and `data-classification`.
- Set ResourceQuotas per AI namespace so one model cannot exhaust shared capacity.
- Limit request rate and size at the inference endpoint to reduce unbounded consumption and denial-of-service risk.

**How to verify.**
- Deploying an unlabelled or unsigned image into an AI namespace is rejected.
- Every running AI workload carries a `use-case-id` that exists in the inventory.
- ResourceQuotas exist for each AI namespace.

**References.** [WP] s.4, s.9; [KYVERNO]; [GATEKEEPER]; [K8S-QUOTA]; [OWASP-LLM] LLM06:2026

**Mapped to.** <!-- MAP:SAF-10 --> CSF 2.0: PR.PS-01, PR.PS-05, PR.IR-04; SP 800-53r5: CM-7(5), CM-6, SC-6, CM-8.

### SAF-11 Separate environments and no unapproved production data in AI testing
**Level:** Essential

**Objective.** Experiments, prompt development and evaluations do not use production customer data unless that use is approved, minimized and protected to production standard.

**Implementation guidance.**
- Keep AI development and testing in separate accounts, projects or clusters from production.
- Use synthetic or masked data for prompt development and evaluation sets. If real records are needed to evaluate quality, get approval at the design gate (`governance/APPROVAL_GATES.md`), apply the same controls as production, and delete the data afterwards.
- Notebooks, sandboxes and personal AI tool accounts are in scope.

**How to verify.**
- An inventory of data held in non-production AI environments, with masking status.
- A sample check of non-production stores finds no unmasked customer extracts without an approval record.

**References.** [AIDS]; [SP800-188]

**Mapped to.** <!-- MAP:SAF-11 --> CSF 2.0: PR.IR-01; SP 800-53r5: SA-3(2), CM-4(1), SI-19.

---

## E. Supply chain for models and containers

### SAF-12 Model inventory, approved sources and integrity
**Level:** Essential

**Objective.** Every model in use (hosted API model, open-weight model, fine-tuned model, embedding model) is recorded with source, version, license, owner and integrity information, and comes from an approved source.

**Implementation guidance.**
- Keep a list of approved model sources. Record each model in the use-case inventory with provider, exact version identifier, license and where it runs.
- For hosted models, pin a specific version where the provider offers dated or versioned identifiers, and track the provider's deprecation dates. A silent model change is a change to your system (see SAF-17).
- For downloaded weights, verify checksums or signatures, prefer formats that do not execute code when loaded (for example safetensors instead of pickle-based files), and store approved copies in an internal registry. Do not pull models from public hubs at runtime.
- Optionally describe models in a machine-readable bill of materials (for example CycloneDX ML-BOM).

**How to verify.**
- Inventory entries match what actually runs (gateway logs, model registry, images).
- The hash of a deployed model file matches the approved record.
- No workload downloads models from the internet at start-up.

**References.** [OWASP-LLM] LLM04:2026, LLM05:2026; [SAFETENSORS]; [MLBOM]; [SP800-218A]; [AIDS]

**Mapped to.** <!-- MAP:SAF-12 --> CSF 2.0: ID.AM-02, ID.RA-09; SP 800-53r5: CM-8, SR-4, SR-11, SI-7; AI RMF: GOVERN 1.6, GOVERN 6.1, MAP 4.1, MANAGE 3.2.

### SAF-13 Container images and AI dependencies are scanned, signed and verified
**Level:** Essential

**Objective.** Images and libraries for AI workloads are built from trusted bases, pinned, scanned, signed in the pipeline and verified at admission, with a software bill of materials (SBOM) for each image.

**Implementation guidance.**
- Apply [WP] s.7.1 and the pipeline in [WP] Figure 3 to AI images. AI images are often large and pull many packages (GPU runtimes, Python libraries); pin versions and use lock files with hashes.
- Scan continuously, not only at build time. Generate an SBOM per image.
- Sign images (for example with Sigstore Cosign) and verify signatures at admission (SAF-10).
- Treat agent tool servers (for example MCP servers), plugins and agent frameworks as supply-chain components: install them only from approved sources, pin their versions, review them before each upgrade, and run local tool servers with the least privileges and network access they need.

**How to verify.**
- Each deployed AI image has an SBOM and a current scan with no unaccepted critical findings.
- An unsigned image is rejected at admission.
- Each MCP server, plugin or agent framework in use has an approved, pinned version.

**References.** [WP] s.7.1; [SIGSTORE]; [SLSA]; [SP800-190]; [SP800-218A]; [OWASP-LLM] LLM04:2026; [OWASP-ASI] ASI04

**Mapped to.** <!-- MAP:SAF-13 --> CSF 2.0: ID.RA-01, ID.RA-09, PR.PS-02, PR.PS-06; SP 800-53r5: RA-5, SI-7(15), SR-4.

### SAF-14 Due diligence and contract terms for external AI services
**Level:** Essential

**Objective.** Before customer data is sent to an external AI service, the provider's terms on data use, training, retention, location, sub-processors and security are reviewed and recorded, and acceptable terms are in the contract.

**Implementation guidance.**
- Ask and record at least: Are inputs or outputs used to train models? How long are prompts and outputs kept, including for abuse monitoring? Where is data processed? Which sub-processors? How are breaches notified? Which independent security reports are available? Can data be deleted on request?
- Consumer or free tiers of AI tools usually have different terms from enterprise tiers. Approve the specific tier and account type.
- Communications providers: ask counsel whether sending customer proprietary network information (CPNI) to an AI vendor is a use or disclosure that needs customer approval under 47 CFR Part 64, Subpart U (see s.64.2007), and what safeguards s.64.2010 requires.
- Link the review to the vendor entry in the use-case inventory and repeat it when terms change.

**How to verify.**
- Each external AI service in the inventory has a dated due-diligence record and a contract reference.
- The approved tier and account match what is in use.

**References.** [CPNI]; [AIDS]; [DAI]

**Mapped to.** <!-- MAP:SAF-14 --> CSF 2.0: GV.SC-05, GV.SC-06, GV.SC-07, GV.OC-03; SP 800-53r5: SA-9, SA-4, SR-6; AI RMF: GOVERN 1.1, GOVERN 6.1, MAP 4.1, MANAGE 3.1.

---

## F. Logging and monitoring with privacy

### SAF-15 AI interaction audit logging with data minimization
**Level:** Essential

**Objective.** For every AI request the organization can reconstruct who or what asked, which model and version answered, which data and tools were used, and what action followed, without turning logs into a second, uncontrolled copy of customer data.

**Implementation guidance.**
- Always log metadata: calling identity, end user, use-case ID, model and version, tool calls, record IDs accessed (not their content), actions taken, policy blocks, token counts and errors.
- Log full prompt and output text only where there is a stated need (for example investigation of a high-risk use case). Redact sensitive fields first, restrict access, and keep it for a shorter period.
- Protect AI logs like the data they describe: access control, integrity protection, defined retention, and the same deletion rules as the source records (SAF-23).
- Send AI logs to the central log or SIEM platform ([WP] s.8).

**How to verify.**
- Reconstruct one sample AI transaction end to end from the logs.
- Search the logs for a synthetic test value (for example a fake account number); it does not appear in clear text.
- Retention settings match the documented policy.

**References.** [WP] s.8; [AI-600-1]; [SP800-122]

**Mapped to.** <!-- MAP:SAF-15 --> CSF 2.0: PR.PS-04; SP 800-53r5: AU-2, AU-3, AU-9, AU-11, AU-12, SI-12; AI RMF: MEASURE 2.8, MEASURE 2.10.

### SAF-16 Security monitoring for AI misuse
**Level:** Enhanced

**Objective.** Alerts fire on signs that an AI component is being abused or is misbehaving, and they reach the incident process.

**Implementation guidance.**
- Start with detections that fit your use cases: repeated policy blocks or injection patterns, unusual volume of customer records retrieved, tool calls outside normal patterns, use of a key from a new location, spending spikes, a sudden change in refusal or error rates.
- Baseline normal activity per use case before setting thresholds.
- Use MITRE ATLAS as a reference list of attack techniques against AI systems when deciding what to detect.
- Route alerts into the AI incident playbook (`governance/AI_INCIDENT_PLAYBOOK.md`).

**How to verify.**
- Trigger each detection with a simulated event in test; the alert reaches the on-call person.
- The detection list is reviewed when a new use case is approved.

**References.** [ATLAS]; [OWASP-LLM]; [DAI]

**Mapped to.** <!-- MAP:SAF-16 --> CSF 2.0: DE.CM-03, DE.CM-09, DE.AE-02, DE.AE-03; SP 800-53r5: SI-4, AU-6; AI RMF: MEASURE 2.7, MEASURE 3.1.

### SAF-17 Signals for quality and behavior change
**Level:** Enhanced

**Objective.** The platform records the signals the governance process needs to see when an AI system's behavior changes: model version changes, results of repeat evaluations, user corrections and overrides, and complaints linked to AI output.

**Implementation guidance.**
- Keep a fixed evaluation set per use case (including injection and sensitive-data tests from SAF-21) and run it before release, after every model or prompt change, and on a schedule.
- Capture whether staff accepted, edited or rejected AI suggestions, and tag customer complaints that involve AI output.
- Alert the use-case owner when results move outside the limits set at the approval gate.

**How to verify.**
- Evaluation results exist for the current model version and the last change.
- Override and complaint data are available to the owner and reviewed at the periodic gate.

**References.** [AI-RMF]; [AI-600-1]

**Mapped to.** <!-- MAP:SAF-17 --> CSF 2.0: DE.CM-09; SP 800-53r5: CA-7; AI RMF: MEASURE 2.4, MEASURE 3.1, MEASURE 3.3, MANAGE 3.2, MANAGE 4.1.

---

## G. Data protection when connecting AI to CRM and customer data

### SAF-18 Classify customer data before AI gets access
**Level:** Essential

**Objective.** Every object and field an AI use case wants is classified, and each class has a written rule for which kind of AI service may receive it.

**Implementation guidance.**
- Use a small number of classes, for example: Public, Internal, Confidential (customer personal data), Restricted (CPNI and call detail information, payment data, government ID numbers, authentication secrets and security questions).
- Write a rule matrix, for example: Restricted data is never sent to external models and is masked or tokenized before any AI processing; Confidential data goes only to approved services with no-training and agreed retention terms (SAF-14); Internal and Public data follow normal approvals.
- Record classification as metadata in the data map of each use case. The readiness checklist (`readiness/AI_READINESS_CHECKLIST.md`, section R3) helps find where these fields live.

**How to verify.**
- Each AI use case has a data map with a class for every field it uses.
- The rule matrix is approved and dated.

**References.** [CPNI]; [AIDS]; [SP800-122]; [PRIVACY-FW]

**Mapped to.** <!-- MAP:SAF-18 --> CSF 2.0: ID.AM-07, ID.AM-05, GV.OC-03; SP 800-53r5: RA-2, PM-5(1), CM-12; AI RMF: GOVERN 1.1, MAP 1.1, MEASURE 2.10.

### SAF-19 Minimize, mask and filter data going to and coming from models
**Level:** Essential

**Objective.** A model receives only the data the task needs; sensitive values are masked, tokenized or removed before they reach a model or index, and outputs are filtered before they are shown or stored.

**Implementation guidance.**
- Build requests from an allowlist of fields. Do not send "the whole customer record".
- Replace identifiers with tokens on the platform side and re-insert real values only after the response, where needed.
- Be careful with free-text notes and call transcripts. They often contain card numbers, passwords or health details that staff typed in; filter them or leave them out.
- Apply input and output filtering for sensitive patterns at the gateway (SAF-08) or in the integration.

**How to verify.**
- Inspect a sample of requests at the gateway; only allowlisted fields are present.
- Send a test record containing synthetic sensitive values; they are masked before the model call and do not appear in the output.

**References.** [AIDS]; [OWASP-LLM] LLM02:2026; [SP800-122]; [SP800-188]

**Mapped to.** <!-- MAP:SAF-19 --> CSF 2.0: PR.DS-02, PR.DS-10; SP 800-53r5: SA-8(33), SI-12(1), SI-19, SI-15, AC-4; AI RMF: MEASURE 2.10.

### SAF-20 Permission-aware retrieval and protected AI data stores
**Level:** Essential

**Objective.** Retrieval indexes, vector stores, caches, conversation histories and fine-tuning sets built from customer data enforce the same access rules as the source system, are encrypted, and are listed as customer-data stores.

**Implementation guidance.**
- Enforce record-level access at query time using the end user's identity, or split indexes by audience. One index for everyone, holding data that only some users may see, breaks the CRM's access model.
- Treat embeddings and other derived data as having the same class as their source; they can reveal information about the source text.
- Encrypt these stores at rest, isolate them on the network (SAF-07, SAF-09) and add them to the asset and data inventory. They are easy to forget because they are not "the CRM".
- Agent memory (long-term memory, saved notes, conversation summaries) is an AI data store too. Write to it only from trusted steps, keep it separate per user and per customer, set expiry, and let the use-case owner inspect and clear it. Poisoned memory can steer later sessions.

**How to verify.**
- Two test users with different CRM visibility ask the same question; each receives only what they may see.
- Encryption at rest is enabled for each AI data store.
- Each store appears in the data inventory with an owner and retention rule.
- Memory written in one customer's session is not visible in another customer's session.

**References.** [OWASP-LLM] LLM09:2026; [OWASP-ASI] ASI06; [AIDS]

**Mapped to.** <!-- MAP:SAF-20 --> CSF 2.0: PR.AA-05, PR.DS-01, ID.AM-07; SP 800-53r5: AC-3, SC-28, CM-12; AI RMF: MEASURE 2.10.

### SAF-21 Customer and external content is untrusted input
**Level:** Essential

**Objective.** Text that comes from customers or outside parties (emails, chats, tickets, web forms, documents, call transcripts) is handled as untrusted when an AI system reads it, and model output is validated before it triggers an action, is written to a record or is rendered in a user interface.

**Implementation guidance.**
- Keep instructions and data separate in how prompts are built, and never let retrieved content change permissions. Permissions are enforced in code (SAF-02, SAF-03).
- Validate output against an expected structure and allowed values before use. Encode output before rendering it in web pages or agent consoles.
- Include prompt-injection test cases (for example instructions hidden in a customer email) in the evaluation set (SAF-17), and run them before release and after model changes.

**How to verify.**
- The injection test suite was run on the current version and the results were reviewed at the approval gate.
- A test message containing an instruction to export data or change an account does not lead to that action.

**References.** [OWASP-LLM] LLM01:2026, LLM10:2026; [OWASP-ASI] ASI01; [ATLAS]; [AI-600-1]

**Mapped to.** <!-- MAP:SAF-21 --> CSF 2.0: PR.PS-06; SP 800-53r5: SI-10, SI-15, SA-11, CA-8; AI RMF: MEASURE 2.7.

### SAF-22 Controlled write-back to customer records
**Level:** Essential

**Objective.** Changes an AI system makes to customer records are attributable to the AI identity and use case, validated, limited in volume, and reversible.

**Implementation guidance.**
- Write through the CRM's business layer or APIs so validation rules, workflows and the audit trail apply. No direct SQL updates from AI services.
- Mark records or fields changed by AI (for example a source or "changed by" value tied to the AI identity).
- Set volume limits per hour and per run; disallow bulk updates by default.
- Keep before and after values so changes can be rolled back. Require human approval for high-impact fields (SAF-03).

**How to verify.**
- The audit trail shows the AI identity on a sample of AI changes.
- A rollback test restores a set of AI-changed records.
- An attempted bulk update above the limit is blocked.

**References.** [OWASP-LLM] LLM10:2026, LLM03:2026

**Mapped to.** <!-- MAP:SAF-22 --> CSF 2.0: PR.DS-01, PR.AA-05; SP 800-53r5: AC-3(2), SI-10, AU-12; AI RMF: MAP 3.5.

### SAF-23 Retention and deletion across AI copies of data
**Level:** Enhanced

**Objective.** Copies of customer data inside AI systems (logs, caches, indexes, conversation histories, evaluation sets and provider-side storage) follow the retention schedule of the source data, and deletion requests reach them.

**Implementation guidance.**
- List the AI copies of data for each use case in the inventory.
- Set expiry times on caches, histories and logs. Run deletion jobs keyed by customer ID across AI stores.
- Check provider-side retention against the contract (SAF-14).

**How to verify.**
- For a deleted test customer, search all AI stores; no copies remain beyond the retention rule.
- Expiry settings match the documented schedule.

**References.** [AIDS]; [SP800-122]

**Mapped to.** <!-- MAP:SAF-23 --> CSF 2.0: ID.AM-08; SP 800-53r5: SI-12, SI-12(3); AI RMF: MEASURE 2.10.

### SAF-24 Safe fallback and a tested kill switch
**Level:** Enhanced

**Objective.** The business process keeps working when an AI service fails, is rate-limited or is switched off on purpose, and the switch that turns each AI use case off is tested.

**Implementation guidance.**
- Put each AI use case behind a feature flag or gateway rule that the owner and the incident lead can switch off.
- Define the manual path staff follow when AI is off, and set timeouts so a slow model does not block customer service.
- Include provider outages and forced shut-off in the incident playbook and in tabletop exercises.

**How to verify.**
- A test turns the use case off and on; the manual path works and the time taken is recorded.
- The switch owner is named in the RACI (`governance/ROLES_RACI.md`).

**References.** [AI-RMF]; [DAI]

**Mapped to.** <!-- MAP:SAF-24 --> CSF 2.0: PR.IR-03, RS.MI-01; SP 800-53r5: CP-2, SI-17, IR-4; AI RMF: MANAGE 2.4, GOVERN 6.2.

---

## Relation to the whitepaper maturity model

[WP] section 11 describes four maturity levels (Initial, Managed, Defined, Optimized). As a rough guide: an organization should reach at least "Managed" for identity and monitoring before it implements the Essential controls here, because most of them build on SSO, central logging and a secrets platform. The Enhanced controls generally assume "Defined" (workload identity, policy as code in CI, unified SIEM).

## Known gaps in v0.1

- No controls yet for organizations that train or fine-tune their own large models; the focus is on deployers.
- No ready-made detection rules; SAF-16 lists what to detect, not vendor-specific queries.
- Examples cover Kubernetes only; Terraform examples are planned (`docs/ROADMAP.md`).
- Mappings will need an update when NIST publishes the SP 800-53 AI control overlays (COSIS) and the CSF Cyber AI Profile.
