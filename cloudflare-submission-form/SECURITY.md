# Security model

This Worker accepts confidential project briefs without exposing a public read API.

## Controls

- Requests are accepted only as bounded JSON from the exact deployment origin.
- Cloudflare Turnstile is verified server-side. Production tokens must match the `physical_ai_inquiry` action and the request hostname.
- The public `workers.dev` and preview hostnames are disabled; production traffic uses `inquiry.omniedge.io`.
- All database writes use D1 prepared statements. Responses and logs exclude submitted personal data.
- Browser responses deny framing, sniffing, indexing, referrer leakage, and unnecessary browser capabilities through security headers and a restrictive Content Security Policy.
- A honeypot reduces simple bot traffic without revealing detection.
- Stored submissions expire after 365 days. A daily scheduled handler removes expired rows.
- There is no administrative or submission-listing route in this Worker.

## Production checklist

1. Create a dedicated D1 database and replace the placeholder database ID in `wrangler.jsonc`.
2. Create a Turnstile widget restricted to `inquiry.omniedge.io`.
3. Store `TURNSTILE_SECRET_KEY` and `TURNSTILE_SITE_KEY` with `wrangler secret put`; do not commit them.
4. Apply remote D1 migrations before deployment.
5. Add a Cloudflare rate-limit rule for `POST /api/submissions`, starting conservatively and tuning it from observed legitimate traffic.
6. Grant Cloudflare account access only to operators who need to review submissions, and enable strong account authentication.

## Incident response

Rotate the Turnstile keys if they are exposed. If submitted data may have been accessed, preserve relevant Cloudflare audit records, determine the affected rows and time window, and follow applicable notification requirements.
