#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Check every NIST identifier used in Secure AI Foundations against official
NIST machine-readable sources.

Sources (downloaded at run time, standard library only):
  - CSF 2.0: NIST CPRT export
      https://csrc.nist.gov/extensions/nudp/services/json/nudp/framework/version/csf_2_0_0/export/json?element=all
  - SP 800-53 Rev. 5: NIST OSCAL catalog (usnistgov/oscal-content)
      https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json
  - AI RMF 1.0: NIST AI RMF Playbook JSON
      https://airc.nist.gov/docs/playbook.json

Usage:  python3 mappings/tools/verify_ids.py            (from the repository root)
Exit code 0 = all identifiers valid; 1 = problems found.
"""
import csv
import json
import pathlib
import re
import sys
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[2]
MAPPING = ROOT / "mappings" / "saf_mapping.csv"

URL_CSF = ("https://csrc.nist.gov/extensions/nudp/services/json/nudp/framework/"
           "version/csf_2_0_0/export/json?element=all")
URL_53 = ("https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/"
          "SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json")
URL_AI = "https://airc.nist.gov/docs/playbook.json"


def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "saf-verify-ids/0.1"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read().decode("utf-8"))


def load_csf():
    els = fetch_json(URL_CSF)["response"]["elements"]["elements"]
    withdrawn = {e["element_identifier"][3:] for e in els
                 if e["element_type"] == "withdraw_reason"}
    return {e["element_identifier"]: e["text"].strip() for e in els
            if e["element_type"] == "subcategory"
            and e["element_identifier"] not in withdrawn}


def load_80053():
    cat = fetch_json(URL_53)["catalog"]
    out = {}

    def walk(ctrl):
        props = ctrl.get("props", [])
        label = next((p["value"] for p in props
                      if p["name"] == "label" and p.get("class") != "zero-padded"),
                     ctrl["id"])
        status = next((p["value"] for p in props if p["name"] == "status"), "")
        out[label] = (ctrl["title"].strip(), status)
        for sub in ctrl.get("controls", []):
            walk(sub)

    for group in cat["groups"]:
        for ctrl in group.get("controls", []):
            walk(ctrl)
    return out, cat["metadata"].get("version", "?")


def load_airmf():
    return {x["title"].strip(): x["description"].strip() for x in fetch_json(URL_AI)}


def main():
    csf = load_csf()
    sp, sp_version = load_80053()
    ai = load_airmf()
    print(f"Loaded CSF 2.0: {len(csf)} subcategories; SP 800-53 release {sp_version}: "
          f"{len(sp)} controls/enhancements; AI RMF 1.0: {len(ai)} subcategories")

    problems = []

    # 1. The mapping file: identifiers and descriptions.
    with open(MAPPING, newline="", encoding="utf-8") as f:
        for n, row in enumerate(csv.DictReader(f), start=2):
            doc, eid, desc = row["focal_document"], row["focal_element_id"], row["focal_element_description"]
            if doc.startswith("NIST CSF 2.0"):
                ok, official = eid in csf, csf.get(eid)
            elif doc.startswith("NIST SP 800-53"):
                ok = eid in sp and sp[eid][1] != "withdrawn"
                official = sp.get(eid, ("", ""))[0]
            elif doc.startswith("NIST AI RMF"):
                ok, official = eid in ai, ai.get(eid)
            else:
                problems.append(f"saf_mapping.csv line {n}: unknown focal document {doc!r}")
                continue
            if not ok:
                problems.append(f"saf_mapping.csv line {n}: {eid} not found (or withdrawn) in {doc}")
            elif desc.strip() != official:
                problems.append(f"saf_mapping.csv line {n}: description of {eid} differs from official text")
            if row["relationship"] not in {"subset of", "intersects with", "equal",
                                           "superset of", "not related to"}:
                problems.append(f"saf_mapping.csv line {n}: invalid relationship {row['relationship']!r}")
            if row["rationale"] not in {"syntactic", "semantic", "functional"}:
                problems.append(f"saf_mapping.csv line {n}: invalid rationale {row['rationale']!r}")

    # 2. Every identifier mentioned anywhere in the toolkit's text files.
    pat_csf = re.compile(r"\b(?:GV|ID|PR|DE|RS|RC)\.[A-Z]{2}-\d{2}\b")
    pat_ai = re.compile(r"\b(?:GOVERN|MAP|MEASURE|MANAGE) \d+\.\d+\b")
    pat_53 = re.compile(r"(?<![.\w])(?:AC|AT|AU|CA|CM|CP|IA|IR|MA|MP|PE|PL|PM|PS|PT|RA|SA|SC|SI|SR)-\d+(?:\(\d+\))?(?![\d(])")
    for path in sorted(ROOT.rglob("*")):
        if path.suffix not in {".md", ".csv"} or path.name.startswith("LICENSE"):
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(ROOT)
        for m in pat_csf.findall(text):
            if m not in csf:
                problems.append(f"{rel}: CSF id {m} not found")
        for m in pat_ai.findall(text):
            if m not in ai:
                problems.append(f"{rel}: AI RMF id {m} not found")
        for m in pat_53.findall(text):
            if m not in sp or sp[m][1] == "withdrawn":
                problems.append(f"{rel}: SP 800-53 id {m} not found or withdrawn")

    if problems:
        print("\n".join(sorted(set(problems))))
        print(f"\n{len(set(problems))} problem(s) found.")
        return 1
    print("All identifiers valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
