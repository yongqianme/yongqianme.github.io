My homepage.

## WeChat article sync

The `Sync WeChat posts` GitHub Action imports published articles from a
full-content RSS or JSON feed for the `yongqian_insight` official account and
lists them at `/zh/writing/`.

This avoids WeChat AppID/AppSecret credentials:

1. Use [Wechat2RSS](https://wechat2rss.xlab.app/) or another full-content feed
   provider.
2. Add any shared `mp.weixin.qq.com` article URL from `yongqian_insight`.
3. Copy the generated `.json` or `.xml` feed URL.
4. Configure this GitHub Actions repository variable:

- `WECHAT_FEED_URL` — the generated `.json` or `.xml` feed URL

No WeChat AppID or AppSecret is required. If a self-hosted feed URL contains an
access token, store `WECHAT_FEED_URL` as a repository secret instead; the
workflow accepts either form. The importer also supports standard JSON Feed and
RSS 2.0 sources from other providers.
