# accio <secret> [namespace]: print a Kubernetes secret decoded. acc: pick the secret with fzf first.

accio() {
  local secret=$1
  local namespace=${2:-$(kubectl config view --minify -o jsonpath='{..namespace}')}
  kubectl get secret "$secret" -n "${namespace:-default}" -o json | jq -r '.data | map_values(@base64d)'
}

# fzf over secrets in a namespace, then accio the chosen one
# usage: acc [namespace]   (defaults to current namespace, else picks one)
acc() {
  local ns=${1:-$(kubectl config view --minify -o jsonpath='{..namespace}')}
  if [[ -z "$ns" ]]; then
    ns=$(oc projects -q | fzf --prompt="Namespace: ") || return
  fi
  local secret
  secret=$(kubectl get secrets -n "$ns" --no-headers -o custom-columns='NAME:.metadata.name,TYPE:.type' \
    | fzf --prompt="Secret [$ns]: " | awk '{print $1}')
  [[ -n "$secret" ]] && accio "$secret" "$ns"
}
