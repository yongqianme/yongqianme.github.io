# Cloudflare site deployment

The site remains a Jekyll application. GitHub Actions builds it and deploys the generated `_site` directory through Cloudflare Workers Static Assets. No application-framework rewrite is required.

The staging Worker serves `demo.qianyong.me`. The production `qianyong.me` and `www.qianyong.me` DNS records remain untouched. The confidential inquiry form remains a separate Worker at `inquiry.omniedge.io`.

## One-time setup

1. Add `qianyong.me` as an active Cloudflare zone and point the registrar nameservers to Cloudflare.
2. Create a scoped API token allowed to deploy Workers and manage the `qianyong.me` custom-domain routes.
3. Add `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as GitHub Actions repository secrets.
4. Run the **Deploy site to Cloudflare** workflow manually.
5. Verify `https://demo.qianyong.me`, redirects, `/robots.txt`, `/sitemap.xml`, `/feed.xml`, `/llms.txt`, and both language trees before planning a separate production traffic migration.

## Local validation

```sh
LC_ALL=C.UTF-8 LANG=C.UTF-8 bundle exec jekyll build --trace --config _config.yml,_config.cloudflare.yml
cp cloudflare-site/headers _site/_headers
cd cloudflare-submission-form && npx wrangler deploy --dry-run --config ../wrangler.jsonc
```
