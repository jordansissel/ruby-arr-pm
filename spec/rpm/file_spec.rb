# encoding: utf-8

require "arr-pm/file"

describe ::RPM::File do
  context "with a known good rpm" do
    let(:path) { File.join(File.dirname(__FILE__), "../fixtures/pagure-mirror-5.13.2-5.fc35.noarch.rpm") }
    subject { described_class.new(path) }

    context "#files" do
      let(:files) { [
        "/usr/lib/systemd/system/pagure_mirror.service",
        "/usr/share/licenses/pagure-mirror",
        "/usr/share/licenses/pagure-mirror/LICENSE"
      ]}

      it "should have the correct list of files" do
        expect(subject.files).to eq(files)
      end
    end
  end
end
