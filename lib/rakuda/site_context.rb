# frozen_string_literal: true

module Rakuda
  ###
  #
  # ERB テンプレートに渡す site 情報を構築する。
  # Config からテンプレート向けフィールドだけ抜き出した Hash を返す
  #
  # Data ではなく Hash にしているのは、テンプレート側で @site[:title] と
  # @page[:title] を同じ Hash アクセスで書けるようにするため。
  # （今後 Data にするかもしれないが、今は Hash で十分）
  #
  # @param config [Config] サイト設定
  # @return [Hash] テンプレート向けサイト情報
  #
  module SiteContext
    def self.build(config)
      {
        title: config.title,
        base_url: config.base_url,
        language: config.language,
        author: config.author,
        params: config.params
      }
    end
  end
end
