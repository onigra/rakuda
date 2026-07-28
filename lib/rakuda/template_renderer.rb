# frozen_string_literal: true

require "erb"

module Rakuda
  class TemplateRenderer
    def initialize(layouts_dir)
      @layouts_dir = layouts_dir
    end

    ###
    #
    # @param template_name [String] テンプレートファイル名
    # @param assigns [Hash] テンプレートに渡す要素
    #
    def render(template_name, assigns)
      path = File.join(@layouts_dir, "#{template_name}.erb")
      template = ERB.new(File.read(path))
      ctx = AssignContext.new(assigns, self)
      template.result(ctx.get_binding)
    end

    ###
    #
    # assigns の各キーを ERB の binding から参照できるように、インスタンス変数として定義する
    # 例: { site: {...}, page: {...} } → ERB 内で @site / @page が使える
    #
    class AssignContext
      def initialize(assigns, renderer)
        @assigns = assigns
        @renderer = renderer
        assigns.each { |k, v| instance_variable_set("@#{k}", v) }
      end

      def render_partial(name, extra = {})
        @renderer.render("_partials/#{name}", @assigns.merge(extra))
      end

      def get_binding = binding
    end
  end
end
