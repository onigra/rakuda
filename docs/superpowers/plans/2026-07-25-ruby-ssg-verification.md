# Ruby SSG URL Verification (Task 14)

**Date:** 2026-07-28  
**Blog repo:** `onigra.github.io`  
**Gem repo:** `rakuda` @ `386091f` (main)

## Method

### Hugo baseline

| Item | Value |
|------|-------|
| Branch | `master` (pre-migration, `4eb1555`) |
| Hugo version | v0.119.0 extended (CI と同じ; ローカル v0.164 ではテーマ解決エラー) |
| Theme | `git clone --depth 1 https://github.com/mojoaar/hucore ./themes/hucore` |
| Command | `hugo --minify --disableKinds sitemap --baseURL https://onigra.github.io/` |
| URL list | `find public -type f \| sed 's\|public\|\|' \| sort > /tmp/hugo-urls.txt` |

### Ruby SSG (rakuda)

| Item | Value |
|------|-------|
| Branch | `migrate-to-rakuda` (`133edb8`) |
| Ruby | 4.0.6 (mise) |
| Install | `gem build rakuda.gemspec && gem install ./rakuda-0.1.0.gem` |
| Command | `rkd build --source . --destination public` |
| URL list | `find public -type f \| sed 's\|public\|\|' \| sort > /tmp/ruby-urls.txt` |

## Summary

| Metric | Hugo | rakuda |
|--------|------|--------|
| Total files | 343 | 207 |
| Intersection | 205 | 205 |
| Post pages (`/blog/...`) | 91 | 91 |
| `/robots.txt` | ✓ | ✓ (同一パス) |

**Result: PASS with known gaps** — コアコンテンツ（記事・トップページネーション・アーカイブ・固定ページ）は一致。差分は主に Hugo 付随機能とカテゴリ slug 2 件。

> **2026-07-28 追記:** カテゴリ slug 不一致の原因は `UrlGenerator` ではなく、Markdown frontmatter の `categories` が配列形式になっていなかったこと。プログラム側の修正は不要（revert 済み）。コンテンツ側で `- Item` 形式に正規化する。

## Core content (matched)

以下は両ビルドで完全一致:

- 全 91 記事 (`/blog/YYYY/MM/DD/slug/index.html`)
- トップ `/index.html` および `/page/2/` … `/page/10/`（Hugo の `/page/1/` エイリアス除く）
- `/about/index.html`, `/post/index.html`
- カテゴリ HTML（slug 不一致 2 件を除く 57 カテゴリ）
- `/index.xml`, `/robots.txt`, `/wave.ico`, static assets

## Differences

### 1. Intentional / out of scope (Hugo only)

| Pattern | Count | Notes |
|---------|-------|-------|
| `/tags/**` | 3 | プランでスコープ外 |
| `**/index.xml` (category, post, tags) | 59 | rakuda はサイト RSS (`/index.xml`) のみ |
| `/404.html` | 1 | rakuda 未生成（serve 時 404 のみ） |
| `/page/1/index.html` | 1 | Hugo エイリアス; rakuda は `/` のみ |
| `**/page/1/index.html` | 58 | Hugo カテゴリ/タグの page/1 エイリアス |
| `/.DS_Store` | 1 | Hugo ビルド時の macOS 副産物 |

### 2. Missing feature (Hugo only, in scope candidate)

| URL | Notes |
|-----|-------|
| `/categories/index.html` | カテゴリ一覧トップ |
| `/categories/page/2/` … `/page/7/` | カテゴリ一覧ページネーション |

プランの Global Constraints には `/categories/<slug>/` のみ明記。一覧ページは Hugo 互換として要検討。

### 3. Category slug mismatch (content issue)

| Frontmatter | Hugo slug | rakuda slug |
|-------------|-----------|-------------|
| `Music, Bass` | `/categories/music-bass/` | `/categories/music,-bass/` |
| `MySQL, MySQLCasualTalk` | `/categories/mysql-mysqlcasualtalk/` | `/categories/mysql,-mysqlcasualtalk/` |

**原因:** Markdown の `categories` が YAML 配列（`- Item` 形式）ではなく、カンマ入り文字列として 1 要素に入っていた。rakuda は配列の各要素を 1 カテゴリとして slug 化するため、Hugo の taxonomy 解釈とずれる。

**対応:** コンテンツ（または `script/migrate.rb`）で `categories` を配列形式に正規化する。`UrlGenerator` の変更は不要。

## Diff command output (excerpt)

```bash
$ diff /tmp/hugo-urls.txt /tmp/ruby-urls.txt
# 136 lines of differences (see categories/music-bass vs music,-bass above)
```

HTML のみ、tags/404/page/1 エイリアス除外後の Hugo 固有:

```
/categories/index.html
/categories/music-bass/index.html
/categories/page/2/index.html … /page/7/index.html
```

rakuda 固有:

```
/categories/music,-bass/index.html
/categories/mysql,-mysqlcasualtalk/index.html
```

## Conclusion

| Area | Status |
|------|--------|
| Posts, home pagination, section, pages | ✅ Match |
| Site RSS, robots.txt | ✅ Match |
| Category individual pages | ⚠️ 2 slug mismatches (content) |
| Category index + pagination | ❌ Not generated |
| Tags, per-category RSS, 404 | ⏭ Out of scope / Hugo extras |

**Next steps (Task 15 前):**

1. Markdown `categories` を YAML 配列形式（`- Item`）に正規化
2. （任意）`/categories/` 一覧 + ページネーション generator 追加
