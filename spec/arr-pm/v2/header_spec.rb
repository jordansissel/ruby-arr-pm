# encoding: utf-8

require "flores/random"

require "arr-pm/v2/header"
require "arr-pm/v2/type"
require "arr-pm/v2/architecture"

describe ArrPM::V2::Header do
  context "with a known good rpm" do
    let(:path) { File.join(File.dirname(__FILE__), "../../fixtures/example-1.0-1.x86_64.rpm") }
    let(:file) { File.new(path) }

    before do
      lead = ArrPM::V2::Lead.new
      lead.load(file)
      subject.load(file)
    end

    it "should have expected values" do
    end
  end
end
