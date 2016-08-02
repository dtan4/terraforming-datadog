require "spec_helper"

module Terraforming
  module Resource
    describe DatadogMonitor do
      let(:api_key) do
        "api_key"
      end

      let(:app_key) do
        "app_key"
      end

      let(:client) do
        Dogapi::Client.new(api_key, app_key)
      end

      let(:get_all_monitors_response) do
        [
          "200",
          [
            {
              "tags" => [],
              "deleted" => nil,
              "query" => "avg(last_1h):avg:system.load.15{*} by {host,name} > 5",
              "message" =>
                "@slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
              "matching_downtimes" => [],
              "id" => 123456,
              "multi" => true,
              "name" => "High Load Average {{host.name}} {{name.name}}",
              "created" => "2016-07-27T05:16:40.525472+00:00",
              "created_at" => 1469596600000,
              "creator" => {
                "id" => 999999, "handle" => "user@example.com", "name" => "User Example", "email" => "user@example.com"
              },
              "org_id" => 99999,
              "modified" => "2016-07-27T22:05:52.273579+00:00",
              "overall_state" => "OK",
              "type" => "metric alert",
              "options" => {
                "notify_audit" => false,
                "locked" => false,
                "timeout_h" => 0,
                "silenced" => {},
                "thresholds" => { "critical" => 3.0, "warning" => 2.0 },
                "require_full_window" => true,
                "notify_no_data" => false,
                "renotify_interval" => 0,
                "no_data_timeframe" => 120
              }
            },
            {
              "tags" => [],
              "deleted" => nil,
              "query" => "\"aws.status\".over(\"region:ap-northeast-1\",\"service:vpc\").by(\"region\",\"service\").last(2).count_by_status()",
              "message" =>
                "@slack-engineering @slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
              "matching_downtimes" => [],
              "id" => 789012,
              "multi" => true,
              "name" => "[Critical][VPC]AWS Service Status",
              "created" => "2015-11-09T02:21:52.013033+00:00",
              "created_at" => 1447035712000,
              "creator" => {
                "id" => 999999, "handle" => "user@example.com", "name" => "User Example", "email" => "user@example.com"
              },
              "org_id" => 99999,
              "modified" => "2016-07-26T02:23:15.446264+00:00",
              "overall_state" => "OK",
              "type" => "service check",
              "options" => {
                "notify_audit" => true,
                "locked" => false,
                "timeout_h" => 0,
                "silenced" => {},
                "notify_no_data" => false,
                "renotify_interval" => 0,
                "no_data_timeframe" => 2
              }
            },
          ]
        ]
      end

      before do
        allow(client).to receive(:get_all_monitors).and_return(get_all_monitors_response)
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client)).to eq <<-'EOS'
resource "datadog_monitor" "High-Load-Average-hostname-namename" {
    name              = "High Load Average {{host.name}} {{name.name}}"
    type              = "metric alert"
    message           = <<EOT
@slack-infrastructure
{{#is_alert}}  @pagerduty-Datadog    #{{/is_alert}}
{{#is_recovery}} @pagerduty-resolve  #{{/is_recovery}}
EOT
    query             = "avg(last_1h):avg:system.load.15{*} by {host,name} > 5"
    notify_no_data    = false
    renotify_interval = 0
    notify_audit      = false
    timeout_h         = 0

    thresholds {

        warning  = 2.0
        critical = 3.0
    }
}

resource "datadog_monitor" "CriticalVPCAWS-Service-Status" {
    name              = "[Critical][VPC]AWS Service Status"
    type              = "service check"
    message           = <<EOT
@slack-engineering @slack-infrastructure
{{#is_alert}}  @pagerduty-Datadog    #{{/is_alert}}
{{#is_recovery}} @pagerduty-resolve  #{{/is_recovery}}
EOT
    query             = "\"aws.status\".over(\"region:ap-northeast-1\",\"service:vpc\").by(\"region\",\"service\").last(2).count_by_status()"
    notify_no_data    = false
    renotify_interval = 0
    notify_audit      = true
    timeout_h         = 0

    thresholds {
    }
}

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client)).to eq JSON.pretty_generate({
            "version" => 1,
            "serial" => 1,
            "modules" => [
              {
                "path" => [
                  "root"
                ],
                "outputs" => {},
                "resources" => {
                  "datadog_monitor.High-Load-Average-hostname-namename" => {
                    "type" => "datadog_monitor",
                    "primary" => {
                      "id" => "123456",
                      "attributes" => {
                        "id" => "123456",
                        "message" => "@slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
                        "name" => "High Load Average {{host.name}} {{name.name}}",
                        "notify_audit" => "false",
                        "notify_no_data" => "false",
                        "query" => "avg(last_1h):avg:system.load.15{*} by {host,name} > 5",
                        "renotify_interval" => "0",
                        "timeout_h" => "0",
                        "type" => "metric alert",
                        "thresholds.critical" => "3.0",
                        "thresholds.warning" => "2.0",
                        "thresholds.#" => "2",
                      }
                    }
                  },
                  "datadog_monitor.CriticalVPCAWS-Service-Status" => {
                    "type" => "datadog_monitor",
                    "primary" => {
                      "id" => "789012",
                      "attributes" => {
                        "id" => "789012",
                        "message" => "@slack-engineering @slack-infrastructure\n{{#is_alert}}  @pagerduty-Datadog    \#{{/is_alert}}\n{{#is_recovery}} @pagerduty-resolve  \#{{/is_recovery}}",
                        "name" => "[Critical][VPC]AWS Service Status",
                        "notify_audit" => "true",
                        "notify_no_data" => "false",
                        "query" => "\"aws.status\".over(\"region:ap-northeast-1\",\"service:vpc\").by(\"region\",\"service\").last(2).count_by_status()",
                        "renotify_interval" => "0",
                        "timeout_h" => "0",
                        "type" => "service check",
                        "thresholds.#" => "0",
                      }
                    }
                  }
                }
              }
            ]
          })
        end
      end
    end
  end
end
