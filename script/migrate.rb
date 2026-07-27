#!/usr/bin/env ruby
# frozen_string_literal: true

###
# Hugo (config.toml + content/) から rakuda 形式 (site.yml + content/) へ移行を行うスクリプト
# ブログリポジトリのルートディレクトリで実行することを想定している
#
# 使い方:
#   ruby script/migrate.rb           # 実際に書き込む
#   ruby script/migrate.rb --dry-run # 変更対象ファイルのみ表示
#

require "date"
require "fileutils"
require "time"
require "yaml"

# script/ の親ディレクトリ（ブログ repo ルート）に移動
ROOT = File.expand_path("..", __dir__)
Dir.chdir(ROOT)

# --dry-run 指定時はファイルを書き込まず、対象パスだけ表示する
DRY = ARGV.include?("--dry-run")

# DRY モードに応じてファイル書き込みまたは dry-run ログを出す
def write(path, content)
  if DRY
    puts "[dry-run] would write #{path}"
  else
    File.write(path, content)
    puts "wrote #{path}"
  end
end

# config.toml を読み、rakuda の Config ローダーが期待する site.yml を生成する。
# TOML パーサー gem は使わず、正規表現と YAML.safe_load で必要最小限を抽出する。
def convert_config
  toml = File.read("config.toml")

  # [[params.menu]] / [[params.social]] は繰り返しブロックなので scan で列挙
  menu = toml.scan(/\[\[params\.menu\]\]\s*\n(?:[^\[]+\n?)*/).map do |block|
    {"url" => block[/url = "(.*?)"/, 1], "title" => block[/title = "(.*?)"/, 1]}
  end

  social = toml.scan(/\[\[params\.social\]\]\s*\n(?:[^\[]+\n?)*/).map do |block|
    {"url" => block[/url = "(.*?)"/, 1], "fa_icon" => block[/fa_icon = "(.*?)"/, 1]}
  end

  # keywords / languages は TOML の配列リテラルを YAML として解釈
  keywords = toml[/keywords = (\[.*?\])/, 1]
  languages = toml[/languages = (\[.*?\])/, 1]

  data = {
    "base_url" => toml[/baseurl = "(.*?)"/, 1],
    "title" => toml[/^title = "(.*?)"/, 1],
    "language" => toml[/languageCode = "(.*?)"/, 1] || "ja",
    "author" => toml[/^\s*author = "(.*?)"/, 1] || "",
    "paginate" => 10, # Hugo config.toml には無いので rakuda のデフォルト値
    "permalinks" => {"post" => toml[/post= "(.*?)"/, 1]},
    "taxonomies" => {"category" => toml[/category = "(.*?)"/, 1] || "categories"},
    "params" => {
      "description" => toml[/description = "(.*?)"/, 1],
      "keywords" => keywords ? YAML.safe_load(keywords) : [],
      "sharingicons" => toml[/sharingicons = (true|false)/, 1] == "true",
      "highlight" => {
        "style" => toml[/style = "(.*?)"/, 1],
        "languages" => languages ? YAML.safe_load(languages) : []
      },
      "copyright" => extract_toml_string(toml, "copyright"),
      "menu" => menu,
      "social" => social
    }
  }

  write("site.yml", data.to_yaml)
end

# TOML の "..." 文字列値を取り出す。
# copyright のように HTML 属性内に \" が含まれる場合、
# 単純な正規表現 `(.*?)` では途中で切れてしまうため手動パースする。
def extract_toml_string(toml, key)
  marker = "#{key} = \""
  start = toml.index(marker)
  return nil unless start

  i = start + marker.length
  result = +""
  while i < toml.length
    char = toml[i]
    if char == "\\" && i + 1 < toml.length
      result << toml[i + 1]
      i += 2
    elsif char == "\""
      break
    else
      result << char
      i += 1
    end
  end
  result
end

# categories を rakuda が扱える配列形式に正規化する。
# Hugo では `categories: laravel php` のように空白区切り文字列もあるが、
# これは 1 つのカテゴリ名（slug 化時にハイフンに変換）として扱われる。
# 空白で split せず、文字列 1 件を配列の 1 要素として保持する。
def normalize_categories(value)
  return [] if value.nil?

  Array(value).map(&:to_s).reject(&:empty?)
end

# frontmatter 出力用に日付を ISO8601 文字列へ統一
def format_date(value)
  value.is_a?(Time) ? value.iso8601 : value.to_s
end

# Hugo 固有の frontmatter キーを除去し、rakuda が読むキーだけ残す。
# 削除対象: comments, categories: null など
def normalize_frontmatter(front)
  normalized = {}
  normalized["title"] = front["title"] if front["title"]
  # slug は必ず String に。2011-03-11 のような値は YAML が Date と解釈するため
  normalized["slug"] = front["slug"].to_s if front["slug"]
  if front.key?("categories") && !front["categories"].nil?
    normalized["categories"] = normalize_categories(front["categories"])
  end
  normalized["date"] = format_date(front["date"]) if front["date"]
  normalized["url"] = front["url"].to_s if front["url"]
  normalized["draft"] = true if front["draft"] == true
  normalized
end

# 正規化済み frontmatter Hash を YAML 断片（--- 除く）としてシリアライズ
def dump_frontmatter(data)
  data.map { |key, value| format_frontmatter_line(key, value) }.join("\n")
end

# キーごとに出力形式を制御する。
# slug / date / url は inspect でクォートし、
# 2011-03-11 等が YAML 再読込時に Date 型になるのを防ぐ。
def format_frontmatter_line(key, value)
  case key
  when "categories"
    "categories:\n" + value.map { |item| "- #{item}" }.join("\n")
  when "slug", "date", "url"
    "#{key}: #{value.to_s.inspect}"
  when "draft"
    "draft: true"
  else
    "#{key}: #{value.to_s.inspect}"
  end
end

# Hugo shortcode を rakuda / kramdown が処理できる形式へ置換
def replace_shortcodes(body)
  # {{< figure src="..." >}} → Markdown 画像
  body = body.gsub(/\{\{<\s*figure src="([^"]+)"\s*>\}\}/, '![\1](\1)')

  # {{< twitter user="..." id="..." >}} → 埋め込み用 blockquote
  body.gsub(/\{\{<\s*twitter user="([^"]+)" id="([^"]+)"\s*>\}\}/) do
    user = Regexp.last_match(1)
    id = Regexp.last_match(2)
    <<~HTML.strip
      <blockquote class="twitter-tweet"><a href="https://twitter.com/#{user}/status/#{id}"></a></blockquote>
    HTML
  end
end

# 1 つの Markdown ファイルの frontmatter を正規化し、本文の shortcode も置換
def normalize_markdown(path)
  text = File.read(path)
  parts = text.split(/^---\s*$/, 3)
  return unless parts.length == 3

  front = YAML.safe_load(parts[1], permitted_classes: [Time, Date], aliases: true) || {}
  body = parts[2]
  body = replace_shortcodes(body)
  new_front = normalize_frontmatter(front)
  fm_yaml = dump_frontmatter(new_front)
  write(path, "---\n#{fm_yaml}\n---\n#{body}")
end

# main処理

# 1. config.toml site.yml 生成
convert_config

# 2. content/ 配下の全 Markdown の frontmatter 正規化 + shortcode 置換
Dir.glob("content/**/*.md").sort.each { |path| normalize_markdown(path) }
