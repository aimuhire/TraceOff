#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

url="$1"

echo "=== Redirect Chain Analysis ==="
echo "Input URL: $url"
echo ""

echo "Redirect chain:"
curl -sS -L -D - -o /dev/null -A 'Mozilla/5.0' "$url" |
awk 'BEGIN{IGNORECASE=1} /^location:/{gsub(/\r/,""); print "  -> " $2}'

echo ""
echo -n "Final URL: "
curl -sS -L -o /dev/null -w '%{url_effective}\n' -A 'Mozilla/5.0' "$url"

echo ""
echo "=== Testing with our API ==="
echo "POST /api/clean with URL: $url"
echo ""

# Test with our API
response=$(curl -sS -X POST http://localhost:3000/api/clean \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$url\"}")

echo "API Response:"
echo "$response" | jq '.' 2>/dev/null || echo "$response"

echo ""
echo "=== Analysis ==="
final_url=$(echo "$response" | jq -r '.data.primary.url // empty' 2>/dev/null)
if [[ -n "$final_url" ]]; then
  echo "Our API cleaned URL: $final_url"
  echo "Curl final URL: $(curl -sS -L -o /dev/null -w '%{url_effective}' -A 'Mozilla/5.0' "$url")"
  
  if [[ "$final_url" == "$(curl -sS -L -o /dev/null -w '%{url_effective}' -A 'Mozilla/5.0' "$url")" ]]; then
    echo "✅ URLs match - processing worked correctly"
  else
    echo "❌ URLs differ - check strategy rules"
  fi
else
  echo "❌ Failed to get cleaned URL from API"
fi
