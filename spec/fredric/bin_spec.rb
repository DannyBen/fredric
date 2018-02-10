require 'spec_helper'

describe 'bin/fred' do
  it "shows usage patterns" do
    expect(`bin/fred`).to match /Usage:/
  end

  it "shows help" do
    expect(`bin/fred --help`).to match /Commands:/
  end

  it "shows version" do
    expect(`bin/fred --version`).to eq "#{VERSION}\n"
  end

  context "with bad response" do
    it "exits with honor" do
      command = 'bin/fred get --csv series/observations 2>&1'
      expect(`#{command}`).to eq "APICake::BadResponse - 400 Bad Request\n"
    end
  end

  context "without FRED_KEY" do
    before do
      @auth = ENV['FRED_KEY']
      ENV.delete 'FRED_KEY'
    end

    after do
      ENV['FRED_KEY'] = @auth
    end

    it "shows a friendly error" do
      command = 'bin/fred see series series_id:GNPCA 2>&1'
      expect(`#{command}`).to eq "Missing Authentication\nPlease set FRED_KEY=y0urAP1k3y\n"
    end
  end
end
