# Qianyong submission form

A standalone Cloudflare Worker that serves a bilingual Physical AI inquiry form at `https://inquiry.qianyong.me`, validates Turnstile server-side, and stores submissions in D1. The public API has no read endpoint. A daily scheduled task removes records after 12 months. Public `workers.dev` and preview hostnames are disabled.

## Local development

1. Copy `.dev.vars.example` to `.dev.vars` to use Cloudflare's published test keys.
2. Run `npm install`.
3. Run `npm run db:local`.
4. Run `npm run dev` and open `http://localhost:8787`.

## Production setup

1. Authenticate: `npx wrangler login`.
2. Create D1: `npx wrangler d1 create submission-form-db`.
3. Replace `local-development` in `wrangler.jsonc` with the returned database ID.
4. Create a Turnstile widget restricted to `inquiry.qianyong.me`.
5. Set secrets with `npx wrangler secret put TURNSTILE_SITE_KEY` and `npx wrangler secret put TURNSTILE_SECRET_KEY`.
6. Apply the schema: `npx wrangler d1 migrations apply submission-form-db --remote`.
7. Validate with `npm run check`, then deploy with `npm run deploy`.

Review [SECURITY.md](./SECURITY.md) before production deployment, including the recommended edge rate limit and operator-access controls.

Read submissions through authenticated Wrangler access:

```sh
npx wrangler d1 execute submission-form-db --remote --command "SELECT id, created_at, name, email, company, status FROM submissions ORDER BY created_at DESC LIMIT 50"
```

The Worker returns `503` instead of accepting submissions when Turnstile is not configured. Turnstile validation is bound to the `physical_ai_inquiry` action and deployed hostname. Do not commit `.dev.vars` or production secrets.
