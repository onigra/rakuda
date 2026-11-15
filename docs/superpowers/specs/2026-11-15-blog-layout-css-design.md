# ブログレイアウト CSS 方針（rakuda 側）

**Status:** Approved (brainstorming 2026-11-15)

## 概要

onigra.github.io のデザイン刷新に伴い、rakuda リポジトリで更新するドキュメントと minimal fixture の方針を定める。デザインの正本は blog リポジトリの spec である。

**Canonical spec:**  
`onigra.github.io/docs/superpowers/specs/2026-11-15-ua-default-blog-design.md`

## rakuda 設計書の更新

[2026-07-25-rakuda-design.md](./2026-07-25-rakuda-design.md) のブログ側アセット記述を修正する:

- ~~`static/css/style.css`（Sass ビルド済み）~~ → **`static/css/layout.css`（色・フォント非指定のレイアウトのみ）**
- 外部: highlight.js（github テーマ）、Font Awesome（任意）

## minimal fixture

`test/fixtures/minimal/layouts/` を「装飾なし・class 最小」の哲学に合わせる:

- 不要な装飾 class を削る。**class 名を変える場合は** `test/generators/*_test.rb` の `assert_include` を必ず同じ PR で更新する
- テスト安定性を優先するなら `prev` / `next` / `year` / `summary` / `read-more` はそのまま残してよい
- fixture に CSS は必須としない（HTML のみのデモのまま）

## 検証

```bash
rake test
```

## 非スコープ（本変更）

rakuda コアの Pipeline / Renderer の挙動変更は不要。テンプレートとドキュメントのみ。