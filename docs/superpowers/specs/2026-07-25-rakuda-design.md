# rakuda 設計書

## 概要

Hugo でビルドしている onigra.github.io ブログを、Ruby gem **rakuda** に移行する。URL 互換性を最優先とし、コンテンツ・レイアウトは一度書き換える。

## 命名

| 項目 | 値 |
|------|-----|
| GitHub リポジトリ | `onigra/rakuda` |
| gem 名 | `rakuda` |
| Ruby モジュール | `Rakuda` |
| CLI コマンド | `rkd` |
| gemspec | `rakuda.gemspec` |
| 実行ファイル | `exe/rkd` |

## 要件（合意済み）

| 項目 | 決定 |
|------|------|
| URL 互換 | 全ページ完全一致（見た目の差異は許容） |
| コンテンツ | 一度書き換えてよい（shortcode 削除、frontmatter 簡略化） |
| SSG の置き場 | 別リポジトリの gem |
| ブログ repo | Gemfile は置かない（CI で gem を参照） |
| 開発 | 組み込み `serve`（rebuild は手動） |
| アーキテクチャ | ミニマル・パイプライン型（アプローチ 1） |
| 移行スクリプト | ブログ repo の `script/migrate.rb`（一回限り、~80 行） |
| テスト | test/unit（stdlib） |
| CLI | optparse（stdlib） |

## 現状分析（Hugo）

- 記事 91 本 + `about.md`
- Permalink: `/blog/:year/:month/:day/:slug/`
- カスタムレイアウト 5 ファイル + hucore テーマ（CI で clone）
- Shortcode: `figure` 1 箇所、`twitter` 5 箇所（1 記事）
- tags タクソノミ: 未使用
- categories: frontmatter に記載あり
- Disqus / GA: プレースホルダ（未使用）
- 出力: `public/` → GitHub Pages

### 維持する URL 一覧

| 種別 | URL パターン |
|------|-------------|
| Post | `/blog/YYYY/MM/DD/slug/` |
| Home | `/`, `/page/N/` |
| Section | `/post/` |
| Page | `/about/` |
| Category | `/categories/name/` |
| RSS | `/index.xml` |
| Robots | `/robots.txt` |

## アーキテクチャ

```
┌─────────────────────────────────────┐
│  onigra.github.io（ブログリポジトリ）   │
│  ├── site.yml                       │
│  ├── content/                       │
│  ├── layouts/          # ERB        │
│  ├── static/                        │
│  └── script/migrate.rb # 移行後削除可  │
└──────────────┬──────────────────────┘
               │ gem "rakuda"（別 repo）
               ▼
┌─────────────────────────────────────┐
│  rakuda gem                       │
│  CLI: rkd build / rkd serve       │
│  Pipeline: Load → Parse → Render → Emit │
└─────────────────────────────────────┘
               │
               ▼
           public/  → GitHub Pages
```

### 責務分担

**gem:**
- 設定・コンテンツ読み込み
- Markdown レンダリング
- ERB テンプレート適用
- 全ページ種別の生成
- `public/` への書き出し
- Rack による preview server

**ブログ repo:**
- 記事・設定・テンプレート・静的資産
- 移行スクリプト（一回限り）
- CI で gem を参照してビルド

## ビルドパイプライン

5 ステージを直列実行する。

```
1. LoadConfig     site.yml を読み込み
2. LoadContent    content/ をスキャン、Post/Page 生成
3. RenderPages    全ページ種別を ERB + Markdown でレンダリング
4. Emit           public/ に HTML/XML/txt を書き出し
5. CopyStatic     static/ → public/ を再帰コピー
```

### Stage 1: LoadConfig

`site.yml`（旧 `config.toml` から変換）:

```yaml
base_url: "https://onigra.github.io"
title: "onigra.github.io"
language: "ja"
author: "Yudai Suzuki"
paginate: 10

permalinks:
  post: "/blog/:year/:month/:day/:slug/"

taxonomies:
  category: "categories"

params:
  menu:
    - url: "/about/"
      title: "About"
    - url: "/post/"
      title: "Archives"
  social: [...]
  copyright: "..."
  highlight:
    style: "github"
    languages: ["go", "dockerfile"]
```

### Stage 2: LoadContent

| 入力 | 処理 |
|------|------|
| `content/post/*.md` | front_matter_parser で frontmatter 解析 → Post |
| `content/about.md` | Page（`url: /about/` を尊重） |

Post 属性:
- `title`, `slug`, `date`, `categories`, `draft`
- `body`（Markdown 本文）
- 算出: `url`, `summary`（`<!--more-->` または先頭 N 文字）

並び順: 日付降順。

### Stage 3: RenderPages

| 種別 | URL | レイアウト |
|------|-----|-----------|
| Post | `/blog/YYYY/MM/DD/slug/` | `layouts/single.erb` |
| Home | `/`, `/page/N/` | `layouts/list.erb` |
| Section | `/post/` | `layouts/section.erb` |
| Page | `/about/` | `layouts/single.erb` |
| Category | `/categories/<slug>/` | `layouts/list.erb` |

カテゴリ slug は Hugo 互換: 小文字化、スペース → ハイフン（例: `gh-actions` → `/categories/gh-actions/`）。

| RSS | `/index.xml` | `layouts/rss.erb` |
| Robots | `/robots.txt` | `layouts/robots.txt.erb` または固定文字列 |

Markdown: Kramdown + kramdown-parser-gfm。

ERB コンテキスト:

```ruby
{
  site: { title:, base_url:, params: },
  page: { title:, date:, content:, url:, categories:, summary:, ... },
  pages: [...],
  paginator: { pages:, current:, total:, prev:, next: },
  grouped_by_year: { "2026" => [...], ... }
}
```

### Stage 4: Emit

- HTML ページ: `public/<path>/index.html`（ディレクトリ型 URL、Hugo 互換）
- `public/index.xml`, `public/robots.txt`

### Stage 5: CopyStatic

`static/` → `public/` を再帰コピー（HTML より後に実行し、衝突時は static を優先しない — HTML が先）。

## 依存関係

### runtime（gemspec）

| gem | 用途 |
|-----|------|
| `kramdown` | Markdown → HTML |
| `kramdown-parser-gfm` | GFM 拡張（fenced code 等） |
| `front_matter_parser` | frontmatter 解析 |
| `rack` | preview server |

### stdlib（追加 gem なし）

| 機能 | 使用 |
|------|------|
| CLI | optparse |
| テスト | test/unit |
| 設定出力 | Psych（YAML） |
| テンプレート | ERB |

### 意図的に使わないもの

- `thor`（optparse で代替）
- `rspec`（test/unit で代替）
- Hugo / hucore theme clone / Dart Sass

## CLI

```bash
rkd build --source PATH --destination public
rkd serve  --source PATH --port 4000
```

- `build`: パイプライン全ステージ実行
- `serve`: 最新の `public/` を Rack で配信（rebuild は手動）

optparse で `build` / `serve` を `ARGV.shift` 分岐。

## コンテンツ移行

### 設定

- `config.toml` → `site.yml`
- `theme`, `disqusShortname`, `googleAnalytics` を削除

### frontmatter

| フィールド | 扱い |
|-----------|------|
| `title`, `slug`, `date` | 維持 |
| `categories` | スペース区切り → YAML 配列 |
| `comments` | 削除 |
| `categories: null` | `[]` |
| `url` | about のみ維持 |

### shortcode 置換（6 箇所）

| Before | After |
|--------|-------|
| `{{< figure src="/images/yapc_lt.jpg" >}}` | `![YAPC LT](/images/yapc_lt.jpg)` |
| `{{< twitter user="..." id="..." >}}` | 静的 blockquote HTML（テンプレート埋め込み） |

### レイアウト

Hugo Go template → ERB に手動変換。hucore の partials（header, footer, tags, pager）を vendoring。

### 静的資産

hucore から vendoring:
- `static/css/style.css`（Sass ビルド済み）
- `static/wave.ico`
- Font Awesome / highlight.js は CDN 参照（header.erb）

### 移行スクリプト

ブログ repo に `script/migrate.rb`（~80 行、gem 依存なし）:
1. `config.toml` → `site.yml`（正規表現 + Psych）
2. frontmatter 正規化
3. shortcode 置換
4. `--dry-run` オプション

移行完了後、スクリプトは削除またはアーカイブ。

## gem 構成

```
rakuda/
├── lib/
│   ├── rakuda.rb
│   └── rakuda/
│       ├── cli.rb              # optparse
│       ├── pipeline.rb
│       ├── config.rb
│       ├── content_loader.rb
│       ├── post.rb
│       ├── page.rb
│       ├── renderer.rb         # ERB + Kramdown
│       ├── paginator.rb
│       ├── url_generator.rb
│       ├── generators/
│       │   ├── post.rb
│       │   ├── home.rb
│       │   ├── section.rb
│       │   ├── taxonomy.rb
│       │   ├── rss.rb
│       │   └── robots.rb
│       ├── server.rb           # Rack
│       └── version.rb
├── exe/rkd
├── test/
│   ├── test_helper.rb
│   ├── url_generator_test.rb
│   ├── frontmatter_test.rb
│   ├── paginator_test.rb
│   └── pipeline_test.rb
├── test/fixtures/              # 最小 site
├── rakuda.gemspec
└── Rakefile                    # task :test
```

gem 本体見積: 800〜1,200 行（テスト除く）。

## テスト戦略

### gem 側（test/unit）

- URL 生成（permalink パターン）
- ページネーション（91 記事 ÷ 10 = 10 ページ）
- カテゴリ URL 生成
- frontmatter 解析
- summary 分割（`<!--more-->`）
- RSS XML 形式

フィクスチャ: `test/fixtures/` に最小 site.yml + 記事 2〜3 本。

### 移行検証（最重要）

Hugo ビルドと Ruby SSG ビルドの URL 一覧 diff:

```bash
find public -name 'index.html' | sort > urls.txt
diff hugo-urls.txt ruby-urls.txt
```

成功条件: diff が空。`/index.xml`, `/robots.txt` も確認。

## CI / デプロイ

### Before

Hugo CLI + Dart Sass + hucore clone → `hugo --minify`

### After

```yaml
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.3'
- run: gem specific_install -l https://github.com/onigra/rakuda.git
- run: rkd build --source . --destination public
- uses: actions/upload-pages-artifact@v3
  with:
    path: ./public
```

gem 公開後は `gem install rakuda` に切り替え。

ブログ repo に Gemfile は置かない。

## 実装順序

1. gem 骨格 + optparse CLI + `build`（Post のみ）
2. URL 生成 + 全ページ種別 generator
3. ERB レイアウト移植 + static vendoring
4. `script/migrate.rb` 実行
5. URL diff 検証（Hugo vs Ruby SSG）
6. `serve` コマンド（Rack）
7. CI 切り替え、Hugo 関連削除

## スコープ外

- Disqus / Google Analytics 統合
- tags タクソノミページ（未使用）
- sitemap（Hugo でも `--disableKinds=["sitemap"]` で無効）
- ライブリロード
- gem の `migrate` サブコマンド
- ブログ repo の Gemfile
