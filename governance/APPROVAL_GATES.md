# Approval gates

Five gates take an AI use case from idea to retirement. Each gate has an owner, a checklist and a record. Keep the record (a ticket, a signed form or a pull request) and link it in the inventory.

| Gate | When | Decision | Owner |
|---|---|---|---|
| Gate 0 Intake | Someone wants to use AI for a task, or an AI feature appears in a product you use | Register, assign tier, decide whether to continue | AI governance lead |
| Gate 1 Design review | Before any real customer data is used | Approve data scope, vendor, design and test plan | Approvers for the tier |
| Gate 2 Pre-production | Before production use or before customer-facing launch | Go / no-go | Approvers for the tier |
| Gate 3 Periodic and change review | At the tier interval, and on any significant change | Continue / change / pause / retire | Use-case owner + AI governance lead |
| Gate 4 Retirement | When the use case ends or is replaced | Confirm safe shutdown and data removal | Use-case owner |

## Gate 0 - Intake

- [ ] Inventory row created with ID, owner, purpose and expected value (MAP 1.3, MAP 1.4)
- [ ] First tier assigned with reasons (`RISK_TIERING.md`)
- [ ] Checked against prohibited and restricted uses
- [ ] Decision recorded: continue to Gate 1, stop, or keep as idea

## Gate 1 - Design review

- [ ] Data map: objects and fields, with classes (SAF-18) and the field allowlist (SAF-02, SAF-19)
- [ ] CPNI or call detail involved? If yes, counsel has reviewed use, disclosure and customer authentication requirements ([CPNI] s.64.2007, s.64.2010)
- [ ] Vendor due diligence done and terms acceptable (SAF-14)
- [ ] Actions the AI may take are listed; high-impact actions need human confirmation (SAF-03, SAF-22)
- [ ] Human oversight described: who reviews what, and when (MAP 3.5, GOVERN 3.2)
- [ ] Known limits of the model for this task written down for users (MAP 2.2)
- [ ] Evaluation plan: success measures, evaluation set, injection and sensitive-data tests (MEASURE 1.1, SAF-17, SAF-21)
- [ ] Test data approach: synthetic or masked, or approved real data (SAF-11)
- [ ] Readiness checklist sections that apply are complete (`../readiness/AI_READINESS_CHECKLIST.md`)

## Gate 2 - Pre-production (go / no-go)

- [ ] Essential baseline controls for this use case are done, or each gap has an owner, a date and an accepted-risk sign-off (see `../baseline/saf_controls.csv`)
- [ ] Tier 3: Enhanced controls done as well
- [ ] Evaluation results meet the success measures; injection tests passed; results stored (MEASURE 2.3, MEASURE 2.7)
- [ ] Privacy review completed (MEASURE 2.10)
- [ ] Logging works and contains no clear-text Restricted data (SAF-15)
- [ ] Monitoring and alerts are live and reach a person (SAF-16, SAF-17)
- [ ] Kill switch and manual fallback tested (SAF-24)
- [ ] Users trained on what the tool does and does not do (GOVERN 2.2)
- [ ] Residual risks written down and accepted by the right approver (MANAGE 1.4)
- [ ] Decision recorded: go, go with conditions, or no-go (MANAGE 1.1)

## Gate 3 - Periodic and change review

Run at the tier interval and also when: the model or version changes, the system prompt or tools change, the data scope grows, the audience changes, or an incident occurs.

- [ ] Inventory row is still accurate
- [ ] Evaluation set re-run on the current version; results compared with the last run (MEASURE 2.4, SAF-17)
- [ ] Overrides, complaints and incidents since last review are reviewed (MEASURE 3.1, MEASURE 3.3)
- [ ] Vendor terms unchanged, or re-reviewed (MANAGE 3.1)
- [ ] Pinned model still supported; deprecation dates known (MANAGE 3.2)
- [ ] Access review of AI identities done (SAF-02)
- [ ] Tier still correct
- [ ] Decision recorded: continue, change, pause or retire

## Gate 4 - Retirement

- [ ] Feature switched off and the manual or replacement process is in place (GOVERN 1.7)
- [ ] AI identities and keys revoked (SAF-01, SAF-06)
- [ ] AI copies of data deleted or kept only as the retention schedule requires (SAF-23); vendor deletion requested where needed
- [ ] Inventory row set to `retired` with the date
