require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compresses CSS input files using
  # the ruby-clean-css.
  #
  # Requires {https://github.com/joseph/ruby-clean-css}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Compress each CSS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::RubyCssFilter
  #   end
  class RubyCssFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to the
    #  ruby-clean-css  when compressing.
    attr_reader :options

    # @param [Hash] options options to pass to the ruby-clean-css.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input|
        if input =~ %r{min.css$}
          input
        else
          input.sub /\.css$/, '.min.css'
        end
      }

      super(&block)
      @options = options
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compresses each input file with
    # the ruby-clean-css.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      compressor = RubyCleanCSS::Compressor.new(options)
      inputs.each do |input|
        if input.path !~ /min\.css/
          output.write compressor.compress(input.read)
        else
          output.write input.read
        end
      end
    end

  private

    def external_dependencies
      [ 'ruby-clean-css' ]
    end
  end
end
