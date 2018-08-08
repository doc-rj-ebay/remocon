# frozen_string_literal: true

module Remocon
  module Command
    class Validate
      include Remocon::InterpreterHelper

      attr_reader :config, :cmd_opts

      def initialize(opts)
        @config = Remocon::Config.new(opts)
        @cmd_opts = { validate_only: true }
      end

      def require_parameters_file_path
        config.parameters_file_path
      end

      def require_conditions_file_path
        config.conditions_file_path
      end

      def run
        validate_options

        errors = parameter_errors + condition_errors

        if errors.empty?
          STDOUT.puts "No error was found."
        else
          errors.each do |e|
            STDERR.puts "#{e.class} #{e.message}"
            STDERR.puts e.backtrace.join("\n")
          end
        end

        errors.empty?
      end

      private

      def validate_options
        raise ValidationError, "A condition file must exist" unless File.exist?(config.conditions_file_path)
        raise ValidationError, "A parameter file must exist" unless File.exist?(config.parameters_file_path)
      end
    end
  end
end
