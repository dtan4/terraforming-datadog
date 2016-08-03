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

      def tfstate
        resources = monitors.inject({}) do |result, monitor|
          options = options_of(monitor)

          attributes = {
            "id" => monitor["id"].to_s,
            "message" => monitor["message"],
            "name" => monitor["name"],
            "notify_audit" => options["notify_audit"].to_s,
            "notify_no_data" => options["notify_no_data"].to_s,
            "no_data_timeframe" => options["no_data_timeframe"].to_s,
            "query" => monitor["query"],
            "renotify_interval" => options["renotify_interval"].to_s,
            "timeout_h" => options["timeout_h"].to_s,
            "type" => monitor["type"],
          }

          attributes["escalation_message"] = options["escalation_message"] if options["escalation_message"]
          attributes["include_tags"] = options["include_tags"].to_s unless options["include_tags"].nil?

          if options["thresholds"]
            threshold_attributes = {}
            threshold_attributes["thresholds.ok"] = format_number(options["thresholds"]["ok"]).to_s if options["thresholds"]["ok"]
            threshold_attributes["thresholds.critical"] = format_number(options["thresholds"]["critical"]).to_s if options["thresholds"]["critical"]
            threshold_attributes["thresholds.warning"] = format_number(options["thresholds"]["warning"]).to_s if options["thresholds"]["warning"]
            threshold_attributes["thresholds.#"] = threshold_attributes.keys.length.to_s
            attributes.merge!(threshold_attributes)
          else
            attributes["thresholds.#"] = "0"
          end

          if options["silenced"]
            silenced_attributes = {}
            options["silenced"].each { |k, v| silenced_attributes["silenced.#{k}"] = silenced_value(v).to_s }
            silenced_attributes["silenced.#"] = silenced_attributes.keys.length.to_s
            attributes.merge!(silenced_attributes)
          else
            attributes["silenced.#"] = "0"
          end

          result["datadog_monitor.#{resource_name_of(monitor)}"] = {
            "type" => "datadog_monitor",
            "primary" => {
              "id" => monitor["id"].to_s,
              "attributes" => attributes
            }
          }

          result
        end

        generate_tfstate(resources)
      end

      private

      # TODO(dtan4): Use terraform's utility method
      def apply_template(client)
        ERB.new(open(template_path).read, nil, "-").result(binding)
      end

      def format_number(n)
        n.to_i == n ? n.to_i : n
      end

      def generate_tfstate(resources)
        JSON.pretty_generate({
          "version" => 1,
          "serial" => 1,
          "modules" => [
            {
              "path" => [
                "root"
              ],
              "outputs" => {},
              "resources" => resources,
            }
          ]
        })
      end

      def longest_key_length_of(hash)
        return 0 if hash.empty?
        hash.keys.sort_by { |k| k.length }.reverse[0].length
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

      def silenced_value(v)
        v.nil? ? 0 : v
      end

      def template_path
        File.join(File.expand_path(File.join(File.dirname(__FILE__), "..")), "template", "tf", "datadog_monitor.erb")
      end
    end
  end
end
