# Cloudflare site deployment

The Jekyll site is built by GitHub Actions and published as a Cloudflare Worker with static assets. The production Worker serves `qianyong.me` and `www.qianyong.me`; the inquiry form remains a separate Worker at `inquiry.qianyong.me`.

## One-time Cloudflare setup

1. Add `qianyong.me` as an active zone in the target Cloudflare account and point the registrar nameservers to the assigned Cloudflare nameservers.
2. Create a scoped Cloudflare API token that can deploy Workers and manage the `qianyong.me` zone routes. Avoid using the global API key.
3. Add `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as GitHub Actions repository secrets.
4. Run the **Deploy site to Cloudflare** workflow manually from the default branch, or merge this branch into `main` to trigger it.
5. Verify the `qianyong.me`, `www.qianyong.me`, and `inquiry.qianyong.me` hostnames before disabling GitHub Pages in the repository settings.

## Local validation

```sh
LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 bundle exec jekyll build --config _config.yml,_config.cloudflare.yml
cp cloudflare-site/headers _site/_headers
./cloudflare-submission-form/node_modules/.bin/wrangler deploy --dry-run
```

The Worker does not expose a `workers.dev` or preview hostname. Cloudflare creates the custom-domain DNS records and certificates when the authenticated deployment succeeds.
