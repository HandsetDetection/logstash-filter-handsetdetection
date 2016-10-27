# encoding: utf-8
require 'spec_helper'
require "logstash/filters/handsetdetection"

describe LogStash::Filters::Example do
  describe "Simple detection" do
    let(:config) do <<-CONFIG
      filter {
        handsetdetection {
        }
      }
    CONFIG
    end

    sample("agent" => "Nokia6085/2.0 (06.00) Profile/MIDP-2.0 Configuration/CLDC-1.1 nokia6085/UC Browser7.9.0.102/69/352 UNTRUSTED/1.0",) do
      expect(subject).to include("handset_specs")
      expect(subject["handset_specs"]["general_vendor"]).to eq("Nokia")
    end
  end
end
