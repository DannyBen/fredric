require 'spec_helper'

describe API do
  before :all do
    ENV['FREDRIC_KEY'] or raise "Please set FREDRIC_KEY=y0urAP1k3y before running tests"
  end

  let(:fredric) { API.new ENV['FREDRIC_KEY'], use_cache: true }

  describe '#new' do
    it "initializes with api key" do
      fredric = API.new 'my-api-key'
      expect(fredric.api_key).to eq 'my-api-key'
    end

    it "starts with cache disabled" do
      fredric = API.new 'my-api-key'
      expect(fredric.cache).not_to be_enabled
    end

    it "initializes with options" do
      fredric = API.new 'my-api-key',
        use_cache: true,
        cache_dir: 'custom',
        cache_life: 1337

      expect(fredric.cache.dir).to eq 'custom'
      expect(fredric.cache.life).to eq 1337
      expect(fredric.cache).to be_enabled
    end
  end

  describe '#get_csv' do
    context "with a request that contains at least one array" do
      it "returns a csv string" do
        result = fredric.get_csv 'series/observations', series_id: 'GNPCA', 
          observation_start: '2007-01-01', observation_end: '2015-01-01'

        expect(result).to eq fixture('gnpca.csv')
      end
    end

    context "with a response that does not contain any array" do
      it "returns a csv string" do
        result = fredric.get_csv 'series', series_id: 'GNPCA'
        expect(result).to eq fixture('gnpca-meta.csv')
      end
    end

    context "with a non hash response" do
      it "raises an error" do
        expect{fredric.get_csv :bogus_endpoint}.to raise_error(BadResponse)
      end
    end
  end

  describe '#save_csv' do
    let(:filename) { 'tmp.csv' }

    it "saves output to a file" do
      File.delete filename if File.exist? filename
      expect(File).not_to exist(filename)

      fredric.save_csv filename, 'series/observations', series_id: 'GNPCA',
        observation_start: '2007-01-01', observation_end: '2015-01-01'
      
      expect(File).to exist(filename)
      expect(File.read filename).to eq fixture('gnpca.csv')
      
      File.delete filename
    end
  end
end
