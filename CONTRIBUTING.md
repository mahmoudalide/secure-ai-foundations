# Contributing

Thank you for helping. Secure AI Foundations is useful only if people who run real platforms tell us what works and what does not.

## Ways to help

1. **Report your experience.** Open an issue titled `SAF-xx: <short summary>` (or `R3.2: ...` for a readiness item). Say what you tried, on what kind of platform (no names needed), and what happened.
2. **Suggest a control, question or template change.** Explain the risk it addresses and give a public source if you have one.
3. **Correct a mapping.** Name the row in `mappings/saf_mapping.csv` and the NIST element, and say which relationship (`subset of`, `intersects with`, `equal`, `superset of`, `not related to`) you think is right and why.
4. **Point out overlap.** If a public resource already covers something, tell us so `NOVELTY.md` can say so.

## Rules for content

- **No confidential information.** Do not include employer, client or customer names, configurations, incidents or internal documents in issues or pull requests. Describe situations generically.
- **No invented facts.** Statistics, quotes and claims need a public source with a URL.
- **Plain language.** Write for a security or IT lead at a small provider. Short sentences; explain abbreviations once.
- **Tool-neutral.** Name tools only as examples.
- **Identifiers must verify.** Any pull request that changes NIST identifiers must pass:

  ```
  python3 mappings/tools/verify_ids.py
  ```

## Pull requests

- One topic per pull request.
- Update `CHANGELOG.md` under "Unreleased".
- Keep control IDs stable. Do not renumber existing controls; retire an ID and add a new one instead.

## Licensing of contributions

By contributing you agree that your contribution is licensed under the same terms as the file you change: CC BY 4.0 for documentation (Markdown), Apache License 2.0 for code, configuration and data files. For Apache-2.0 files, section 5 of the license applies to contributions.

## Conduct

Be respectful and specific. Critique the content, not the person.
