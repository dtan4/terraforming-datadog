require "spec_helper"

module Terraforming
  module Datadog
    describe CLI do
      describe "ddm" do
        context "without --tfstate" do
          it "should export DatadogMonitor tf" do
            expect(Terraforming::Resource::DatadogMonitor).to receive(:tf)
            described_class.new.invoke(:ddm, [], {})
          end
        end
      end
    end
  end
end
