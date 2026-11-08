# AI incident response playbook

Use this alongside your existing incident response plan, not instead of it. It adds what is specific to AI. The phases follow the CSF 2.0 Detect, Respond and Recover functions, as SP 800-61 Rev. 3 does ([SP800-61r3]).

AI RMF 1.0: GOVERN 4.3 (incident identification and information sharing), MANAGE 2.3 (responding to previously unknown risks), MANAGE 2.4 (disengage or deactivate), MANAGE 4.3 (incidents communicated, tracked and followed up). CSF 2.0: DE.AE-08, RS.MA-01, RS.MA-03, RS.AN-03, RS.MI-01, RS.CO-02, RC.RP-01.

## 1. What counts as an AI incident

Declare an AI incident when an AI use case causes or could cause harm to customers, data or operations. Typical cases:

| Type | Examples |
|---|---|
| Data exposure | AI output shows one customer's data to another person; prompts with customer data sent to an unapproved service; logs or indexes with clear-text Restricted data found |
| Manipulated behavior | Prompt injection in a customer e-mail or chat makes the AI take an action or reveal data |
| Wrong actions at scale | AI writes incorrect values to many customer records; agent applies credits or changes that were not intended |
| Credential or cost event | Model-provider key leaked; sudden usage or spending spike |
| Harmful or misleading output to customers | Customer-facing assistant gives wrong account or legal information |
| Vendor event | AI vendor reports a breach, changes data terms, or changes the model behind a pinned name |
| Silent behavior change | Evaluation results or override rates move sharply without a planned change |

## 2. Severity

| Severity | Use when |
|---|---|
| SEV-1 | Restricted data (including CPNI) exposed or likely exposed; unauthorized changes to customer accounts; ongoing exploitation |
| SEV-2 | Confidential data exposed to a limited internal audience; incorrect writes contained to a known set; leaked key without evidence of misuse |
| SEV-3 | Quality or behavior problem without data exposure or wrong actions |

## 3. Steps

**Detect and declare**
1. Alert from SAF-16 or SAF-17, a staff report, a customer complaint or a vendor notice reaches the on-call person.
2. Open an incident record. Note the `use_case_id`, model and version, and the time window.
3. Set severity. SEV-1 and SEV-2 notify the incident lead, the AI governance lead, and Privacy/Legal at once.

**Contain** (choose what fits; record the time of each action)
4. Turn the use case off or to read-only with the kill switch (SAF-24). Staff switch to the manual path.
5. Revoke or rotate affected keys (SAF-06). Disable the AI identity if misuse is suspected (SAF-01).
6. Block the source at the gateway (SAF-08): a user, a channel, a pattern, or the whole provider.
7. Stop scheduled jobs that write to customer records.

**Preserve evidence**
8. Keep gateway and platform logs, the system prompt and tool configuration as deployed, model version, evaluation results and relevant CRM audit trail entries. Do not delete AI data stores until the scope is understood.

**Analyze**
9. Establish what happened and why: which input, which data, which action, which control failed.
10. Find every affected record and customer (record IDs from SAF-15 logs; AI-changed markers from SAF-22).

**Notify**
11. Privacy/Legal decides on notification duties. For carriers this includes the CPNI rules in 47 CFR Part 64, Subpart U ([CPNI]), plus state breach laws and contracts. Do not decide this in the technical team.
12. Inform the vendor if their service is involved, and ask for their logs and retention details.

**Recover**
13. Roll back wrong changes using before/after values (SAF-22). Verify with the business owner.
14. Fix the cause. Add the incident's input to the evaluation set (SAF-17, SAF-21).
15. Re-enable only after a Gate 3 review (`APPROVAL_GATES.md`) for the use case.

**Learn**
16. Within two weeks, hold a short review. Update the inventory, the tier, the baseline status and this playbook if needed. Share lessons with other use-case owners.

## 4. Tabletop scenarios (run at least one per year)

1. A customer sends an e-mail with hidden text telling the support assistant to send the account's call history to an outside address.
2. A developer finds a model-provider key in a public code repository; the provider bill has doubled this week.
3. The vendor updates the model behind your pinned name; agents report that summaries now miss refund requests.
4. A retrieval index used by an internal assistant turns out to include records from a restricted business-customer segment.

For each: who is called, which switch is used, how long containment takes, what evidence exists, who decides on notification.
