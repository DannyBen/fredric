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
      expect(`#{command}`).to eq "Fredric::BadResponse - API said '400 Bad Request'\n"
    end
  end
end
