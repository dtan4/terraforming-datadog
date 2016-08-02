module Terraforming
  module Resource
    class DatadogMonitor
      def self.tf(client = nil)
        self.new(client).tf
      end

      def self.tfstate(client = nil)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client)
      end

      private

      # TODO(dtan4): Use terraform's utility method
      def apply_template(client)
        ERB.new(open(template_path).read, nil, "-").result(binding)
      end

      def monitors
        @client.get_all_monitors[1]
      end

      def options_of(monitor)
        monitor["options"]
      end

      def resource_name_of(monitor)
        monitor["name"].gsub(/[^a-zA-Z0-9 ]/, "").gsub(" ", "-")
      end

      def template_path
        File.join(File.expand_path(File.join(File.dirname(__FILE__), "..")), "template", "tf", "datadog_monitor.erb")
      end
    end
  end
end
