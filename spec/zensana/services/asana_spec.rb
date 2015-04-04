require 'spec_helper'

describe "Zensana::Asana" do
  let(:asana) { Zensana::Asana.new("user", "pword") }

  context "#request" do
    let(:response) { asana.request(:get, "/path") }

    it "it returns a valid response object" do
      pending "Needs a mock"
      expect(response).to be_a(Zensana::Asana::Response)
    end
  end
end
