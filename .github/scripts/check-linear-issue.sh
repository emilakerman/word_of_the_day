#!/usr/bin/env bash
# Usage: check-linear-issue.sh <issue_identifier> <linear_api_key>
# Exits 0 if the issue exists and its state is "Done" or "Canceled"; 1 otherwise.
# Issue identifier: e.g. WORD-123 (from PR title, body, or branch).
# Linear API: https://developers.linear.app/docs/graphql/working-with-the-graphql-api

set -e
IDENTIFIER="$1"
LINEAR_API_KEY="${2:-$LINEAR_API_KEY}"

if [ -z "$IDENTIFIER" ] || [ -z "$LINEAR_API_KEY" ]; then
  echo "Usage: $0 <issue_identifier> [linear_api_key]"
  echo "  Or set LINEAR_API_KEY in the environment."
  exit 1
fi

# Query by identifier (teamKey-number). Some Linear backends use id for UUID only; then use issues(filter: ...).
QUERY=$(printf '%s' "query { issue(id: \"$IDENTIFIER\") { identifier state { name } } }" | jq -Rs '{ query: . }')
RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$QUERY")

# Parse state name (simple grep; requires jq for robustness - we'll use grep for portability)
if echo "$RESPONSE" | grep -q '"state":null'; then
  echo "Linear issue not found or not accessible: $IDENTIFIER"
  exit 1
fi

STATE=$(echo "$RESPONSE" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
if [ -z "$STATE" ]; then
  # Try with jq if available for more reliable parsing
  if command -v jq >/dev/null 2>&1; then
    STATE=$(echo "$RESPONSE" | jq -r '.data.issue.state.name // empty')
  fi
fi

case "$STATE" in
  Done|Canceled)
    echo "Linear issue $IDENTIFIER is $STATE — proceeding."
    exit 0
    ;;
  *)
    echo "Linear issue $IDENTIFIER is not completed (state: $STATE). Skipping run."
    exit 1
    ;;
esac
