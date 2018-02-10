require 'spec_helper'

describe CommandLine do
  let(:cli) { Fredric::CommandLine }

  before :all do
    ENV['FRED_KEY'] or raise "Please set FRED_KEY=y0urAP1k3y before running tests"
  end

  before do
    ENV['FRED_CACHE_DIR'] = 'cache'
    ENV['FRED_CACHE_LIFE'] = '86400'
  end

  describe '#initialize' do
    let(:cli) { Fredric::CommandLine.clone.instance }

    context "without environment variables" do
      before do
        ENV['FRED_CACHE_DIR'] = nil
        ENV['FRED_CACHE_LIFE'] = nil
      end

      it "has cache disabled" do
        expect(cli.fredric.cache).not_to be_enabled
      end
    end

    context "with CACHE_DIR" do
      it "enables cache" do
        ENV['FRED_CACHE_DIR'] = 'hello'
        expect(cli.fredric.cache).to be_enabled
        expect(cli.fredric.cache.dir).to eq 'hello'
        ENV.delete 'FRED_CACHE_DIR'
      end
    end

    context "with CACHE_LIFE" do
      it "enables cache" do
        ENV['FRED_CACHE_LIFE'] = '123'
        expect(cli.fredric.cache).to be_enabled
        expect(cli.fredric.cache.life).to eq 123
        ENV.delete 'FRED_CACHE_LIFE'
      end
    end
  end

  describe '#execute' do
    context "without arguments" do
      it "shows usage patterns" do
        expect {cli.execute}.to output(/Usage:/).to_stdout
      end
    end

    context "without FRED_KEY" do
      let(:command) { %w[see series series_id:GNPCA] }

      before do
        @auth = ENV['FRED_KEY']
        ENV.delete 'FRED_KEY'
      end

      after do
        ENV['FRED_KEY'] = @auth
      end

      it "raises a MissingAuth error" do
        expect {cli.execute command}.to raise_error(Fredric::MissingAuth)
      end
    end

    context "with url command" do
      let(:command) { %w[url series series_id:GNPCA] }

      it "returns a url" do
        expected = /api\.stlouisfed\.org\/fred\/series\?api_key=.*&file_type=json&series_id=GNPCA/
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with get command" do
      let(:command) { %w[get series series_id:GNPCA] }

      it "prints json output" do
        expected = /\{"realtime_start":.*\}/
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with get --csv command" do
      let(:command) { %w[get --csv series/observations series_id:GNPCA] }

      it "prints csv output" do
        expected = /realtime_start,realtime_end,date,value/
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with pretty command" do
      let(:command) { %w[pretty series series_id:GNPCA] }

      it "prints a prettified json output" do
        expected = /\s+"seriess": \[\n.*\}/m
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with see command" do
      let(:command) { %w[see series series_id:GNPCA] }

      it "awesome-prints output" do
        expected = /"seriess".*=>.*\[/
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with save command" do
      let(:command) { %W[save tmp.json category/children category_id:0] }
      let(:filename) { 'tmp.json' }

      it "saves a file" do
        File.unlink filename if File.exist? filename
        expect(File).not_to exist filename
        expected = "Saved #{filename}\n"

        expect {cli.execute command}.to output(expected).to_stdout
        expect(File).to exist filename
        expect(File.read filename).to match_fixture('categories.json')

        File.unlink filename
      end
    end

    context "with save --csv command" do
      let(:command) { %W[save --csv tmp.csv category/children category_id:0] }
      let(:filename) { 'tmp.csv' }

      it "saves a csv file" do
        File.unlink filename if File.exist? filename
        expect(File).not_to exist filename
        expected = "Saved #{filename}\n"

        expect {cli.execute command}.to output(expected).to_stdout
        expect(File).to exist filename
        expect(File.read filename).to match_fixture('categories.csv')

        File.unlink filename
      end
    end

    context "with an invalid path" do
      let(:command) { %W[get not_here] }
      
      it "fails with honor" do
        expected = %Q[{"error_code":404,"error_message":"Not Found"}\n]
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end
  end

end