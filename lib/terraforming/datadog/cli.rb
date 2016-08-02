module Terraforming
  module Datadog
    class CLI < Thor
      def self.cli_options
        option :tfstate, type: :boolean
        option :api_key, type: :string
        option :app_key, type: :string
      end

      desc "ddm", "Datadog Monitor"
      cli_options
      def ddm
        execute(Terraforming::Resource::DatadogMonitor, options)
      end

      private

      def execute(klass, options)
        api_key = options[:api_key] || ENV["DATADOG_API_KEY"]
        app_key = options[:app_key] || ENV["DATADOG_APP_KEY"]
        client = Dogapi::Client.new(api_key, app_key)
        puts options[:tfstate] ? klass.tfstate(client) : klass.tf(client)
      end
    end
  end
end
