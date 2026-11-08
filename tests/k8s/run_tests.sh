#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Live-cluster test of the SAF Kubernetes examples in baseline/examples/.
#
# Usage:  tests/k8s/run_tests.sh <kube-context>
#         KEEP=1 tests/k8s/run_tests.sh <kube-context>   # skip cleanup
#
# Creates and afterwards deletes ONLY these namespaces: ai-ticket-summarizer,
# saf-test-client and ai-gateway (stand-in AI gateway). It refuses to run if any of
# them already exists, and cleanup only deletes namespaces labelled saf-test=true.
# Needs a CNI that enforces NetworkPolicy and pods that can pull images from Docker Hub.
# Positive controls (C*) run before the policies are applied, so a "blocked"
# result means the policy blocked it, not that the path never worked.

set -uo pipefail

CTX="${1:?usage: $0 <kube-context>}"
K=(kubectl --context "$CTX")
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 2          # repo-relative paths keep the log free of local paths
EX=baseline/examples
M=tests/k8s/manifests
LOG="${LOG:-tests/k8s/last-run.log}"
NS_AI=ai-ticket-summarizer
NS_CL=saf-test-client
NS_GW=ai-gateway
CT=5   # curl connect timeout (s)
: > "$LOG"

ROWS=()
FAILS=0

log() { printf '%s\n' "$*" | tee -a "$LOG"; }

# run CMD...: print the command and its trimmed output, return its exit code.
run() {
  log "\$ $*"
  local out rc
  out=$("$@" 2>&1); rc=$?
  printf '%s\n' "$out" | head -n 12 | sed 's/^/    /' | tee -a "$LOG"
  log "    (exit $rc)"
  LAST_OUT=$out
  return $rc
}

record() {  # id, description, expected, result
  ROWS+=("| $1 | $2 | $3 | $4 |")
  [[ $4 == FAIL ]] && FAILS=$((FAILS + 1))
  log "    => $1 $4"
  log ""
}

# check ID DESC ok|blocked CMD...: expect exit 0 (ok) or non-zero (blocked/rejected)
check() {
  local id=$1 desc=$2 want=$3; shift 3
  if run "$@"; then got=ok; else got=blocked; fi
  [[ $got == "$want" ]] && record "$id" "$desc" "$want" PASS || record "$id" "$desc" "$want" FAIL
}

# reject ID DESC FILE: expect apply to be refused by Pod Security Admission
reject() {
  local id=$1 desc=$2 f=$3
  if run "${K[@]}" apply -f "$f"; then
    record "$id" "$desc" "rejected" FAIL
  elif grep -q 'violates PodSecurity "restricted' <<<"$LAST_OUT"; then
    record "$id" "$desc" "rejected" PASS
  else
    record "$id" "$desc" "rejected" FAIL
  fi
}

ex() { local ns=$1 pod=$2; shift 2; "${K[@]}" exec -n "$ns" "$pod" -- "$@"; }
curl_ai() { ex "$NS_AI" saf-test-client curl -sS -o /dev/null -w '%{http_code}\n' --connect-timeout $CT --max-time 10 "$@"; }
curl_cl() { ex "$NS_CL" curl curl -sS -o /dev/null -w '%{http_code}\n' --connect-timeout $CT --max-time 10 "$@"; }

cleanup() {
  [[ ${KEEP:-0} == 1 ]] && { log "KEEP=1: leaving test namespaces in place"; return; }
  log "== Cleanup"
  for ns in "$NS_AI" "$NS_CL" "$NS_GW"; do
    if [[ $("${K[@]}" get ns "$ns" -o jsonpath='{.metadata.labels.saf-test}' 2>/dev/null) == "true" ]]; then
      run "${K[@]}" delete ns "$ns" --wait=true --timeout=180s
    fi
  done
}

# ---------------------------------------------------------------- pre-checks
log "== Pre-checks (context: $CTX)"
run "${K[@]}" version || { log "cannot reach cluster"; exit 2; }
run "${K[@]}" get nodes --no-headers
run "${K[@]}" get ds -n kube-system -o name
for ns in "$NS_AI" "$NS_CL" "$NS_GW"; do
  if "${K[@]}" get ns "$ns" >/dev/null 2>&1; then
    log "ABORT: namespace $ns already exists; not touching it."; exit 2
  fi
done
trap cleanup EXIT

# ---------------------------------------------------------------- step 2
log "== Step 2: server-side dry run"
# The one-shot command fails on a fresh cluster: a dry-run namespace is not persisted,
# so the namespaced objects get NotFound. Recorded as a known documentation issue.
if run "${K[@]}" apply --dry-run=server -f "$EX/"; then
  record S2.1 "One-shot dry run of whole directory on a fresh cluster" ok PASS
else
  ROWS+=("| S2.1 | One-shot dry run of whole directory on a fresh cluster | ok | FAIL (known: namespace not persisted in dry run; docs issue, not counted) |")
  log "    => S2.1 FAIL (known, not counted)"; log ""
fi
check S2.2 "Dry run: namespace" ok "${K[@]}" apply --dry-run=server -f "$EX/namespace-ai-restricted.yaml"

# ---------------------------------------------------------------- step 3 (part 1)
log "== Step 3: apply namespace and ServiceAccount"
check S3.1 "Apply namespace-ai-restricted.yaml" ok "${K[@]}" apply -f "$EX/namespace-ai-restricted.yaml"
"${K[@]}" label ns "$NS_AI" saf-test=true --overwrite >/dev/null
check S2.3 "Dry run: SA + both policies (namespace exists)" ok "${K[@]}" apply --dry-run=server \
  -f "$EX/serviceaccount-ai-workload.yaml" -f "$EX/networkpolicy-default-deny.yaml" -f "$EX/networkpolicy-allow-egress-gateway.yaml"
check S3.2 "Apply serviceaccount-ai-workload.yaml" ok "${K[@]}" apply -f "$EX/serviceaccount-ai-workload.yaml"

# ---------------------------------------------------------------- step 4
log "== Step 4: Pod Security 'restricted'"
reject S4.1 "Privileged pod rejected" "$M/10-pod-privileged.yaml"
reject S4.2 "runAsUser 0, no seccompProfile rejected" "$M/11-pod-root-no-seccomp.yaml"
check S4.3 "Compliant client pod admitted" ok "${K[@]}" apply -f "$M/20-pod-compliant-client.yaml"
check S4.4 "Compliant server pod admitted" ok "${K[@]}" apply -f "$M/21-ai-workload-server.yaml"

log "== Test fixtures: client namespace and stand-in gateway"
run "${K[@]}" apply -f "$M/30-client-namespace.yaml"
run "${K[@]}" apply -f "$M/40-gateway-standin.yaml"
for ns in "$NS_AI" "$NS_CL" "$NS_GW"; do
  run "${K[@]}" wait --for=condition=Ready pod --all -n "$ns" --timeout=180s
done
check S4.5 "Compliant pods Running and Ready" ok "${K[@]}" wait --for=condition=Ready pod --all -n "$NS_AI" --timeout=10s

WEB_IP=$("${K[@]}" get svc web -n "$NS_CL" -o jsonpath='{.spec.clusterIP}')

# ---------------------------------------------------------------- step 5
log "== Step 5: ServiceAccount token"
check S5.1 "Pod uses SA uc-0001-summarizer" ok bash -c \
  "[[ \$(${K[*]} get pod saf-test-client -n $NS_AI -o jsonpath='{.spec.serviceAccountName}') == uc-0001-summarizer ]]"
check S5.2 "No token mounted (ls serviceaccount dir fails)" blocked \
  ex "$NS_AI" saf-test-client ls /var/run/secrets/kubernetes.io/serviceaccount

# ---------------------------------------------------------------- controls
log "== Positive controls (no NetworkPolicy yet)"
check C1 "Control: DNS works" ok ex "$NS_AI" saf-test-client nslookup example.com
check C2 "Control: internet https://example.com reachable" ok curl_ai https://example.com
check C3 "Control: internet https://1.1.1.1 reachable" ok curl_ai https://1.1.1.1
check C4 "Control: other-namespace service reachable" ok curl_ai "http://$WEB_IP:8080"
check C5 "Control: ingress from saf-test-client reachable" ok curl_cl "http://saf-test-server.$NS_AI.svc:8080"
check C6 "Control: gateway :8443 reachable" ok curl_ai http://ai-gateway.ai-gateway.svc:8443

# ---------------------------------------------------------------- step 3 (part 2) + step 6
log "== Step 3/6: apply default deny"
check S3.3 "Apply networkpolicy-default-deny.yaml" ok "${K[@]}" apply -f "$EX/networkpolicy-default-deny.yaml"
sleep 5
check S6.1 "Deny: internet https://example.com blocked" blocked curl_ai https://example.com
check S6.2 "Deny: internet by IP https://1.1.1.1 blocked" blocked curl_ai https://1.1.1.1
check S6.3 "Deny: other-namespace service (by IP) blocked" blocked curl_ai "http://$WEB_IP:8080"
check S6.4 "Deny: ingress from saf-test-client blocked" blocked curl_cl "http://saf-test-server.$NS_AI.svc:8080"
check S6.5 "Deny: DNS blocked too (before allow rule)" blocked ex "$NS_AI" saf-test-client nslookup -timeout=3 example.com

# ---------------------------------------------------------------- step 3 (part 3) + step 7
log "== Step 3/7: apply allow rule"
check S3.4 "Apply networkpolicy-allow-egress-gateway.yaml" ok "${K[@]}" apply -f "$EX/networkpolicy-allow-egress-gateway.yaml"
sleep 5
check S7.1 "Allow: DNS via kube-dns works" ok ex "$NS_AI" saf-test-client nslookup example.com
check S7.2 "Allow: gateway ai-gateway/app=ai-gateway TCP 8443 allowed" ok curl_ai http://ai-gateway.ai-gateway.svc:8443
check S7.3 "Still blocked: gateway pod on other port (8080)" blocked curl_ai http://ai-gateway.ai-gateway.svc:8080
check S7.4 "Still blocked: internet https://example.com (DNS resolves)" blocked curl_ai https://example.com
check S7.5 "Still blocked: internet by IP https://1.1.1.1" blocked curl_ai https://1.1.1.1
check S7.6 "Still blocked: other-namespace service (by name)" blocked curl_ai "http://web.$NS_CL.svc:8080"
check S7.7 "Still blocked: ingress from saf-test-client" blocked curl_cl "http://saf-test-server.$NS_AI.svc:8080"
check S7.8 "Still blocked: DNS to external resolver 1.1.1.1" blocked ex "$NS_AI" saf-test-client nslookup -timeout=3 example.com 1.1.1.1

# ---------------------------------------------------------------- summary
log "== Results"
log "| ID | Check | Expected | Result |"
log "|----|-------|----------|--------|"
for r in "${ROWS[@]}"; do log "$r"; done
log ""
log "FAILED checks: $FAILS"
exit $(( FAILS > 0 ))
