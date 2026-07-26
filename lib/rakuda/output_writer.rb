# frozen_string_literal: true

require "fileutils"

module Rakuda
  class OutputWriter
    ###
    #
    # @param destination_dir [String] 出力先ディレクトリ
    #
    def initialize(destination_dir)
      @dest = destination_dir
      FileUtils.mkdir_p(@dest)
    end

    ###
    #
    # HTMLページ（index.html） をファイルを public/ 直下（または指定した相対パス）に書き出す
    # `ディレクトリ + index.html` の形式で出力する
    # （例: /blog/2026/01/01/hello/ → public/blog/2026/01/01/hello/index.html）
    #
    # @param url [String] ページの URL
    # @param content [String] ページの内容
    #
    def write_page(url, content)
      dir = url_to_dir(url)
      FileUtils.mkdir_p(dir)
      File.write(File.join(dir, "index.html"), content)
    end

    ###
    #
    # HTMLページではないファイルを public/ 直下（または指定した相対パス）に書き出す
    # index.xml, robots.txt 等を想定
    # （例: /images/logo.png → public/images/logo.png）
    #
    # @param relative_path [String] ファイルの相対パス
    # @param content [String] ファイルの内容
    #
    def write_file(relative_path, content)
      path = File.join(@dest, relative_path)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end

    ###
    #
    # 静的ファイルを public/ 直下（または指定した相対パス）にコピーする
    # （例: public/images/ → public/images/logo.png）
    #
    # @param source_dir [String] コピー元ディレクトリ
    #
    def copy_static(source_dir)
      return unless Dir.exist?(source_dir)

      Dir.glob(File.join(source_dir, "**/*"), File::FNM_DOTMATCH).each do |src|
        next if File.directory?(src)

        rel = src.sub("#{source_dir}/", "")
        dest = File.join(@dest, rel)
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(src, dest)
      end
    end

    private

    ###
    #
    # URL をディレクトリに変換する
    # （例: /blog/2026/01/01/hello/ → public/blog/2026/01/01/hello/）
    #
    # @param url [String] URL
    # @return [String] ディレクトリ
    #
    def url_to_dir(url)
      path = url.sub(%r{/\z}, "")
      path.empty? ? @dest : File.join(@dest, path.sub(%r{\A/}, ""))
    end
  end
end
