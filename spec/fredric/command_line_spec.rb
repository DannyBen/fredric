require 'spec_helper'

describe CommandLine do
  let(:cli) { Fredric::CommandLine.instance }

  before :all do
    ENV['FREDRIC_KEY'] or raise "Please set FREDRIC_KEY=y0urAP1k3y before running tests"
  end

  before do
    ENV['FREDRIC_CACHE_DIR'] = 'cache'
    ENV['FREDRIC_CACHE_LIFE'] = '86400'
  end

  describe '#initialize' do
    let(:cli) { Fredric::CommandLine.clone.instance }

    context "without environment variables" do
      before do
        ENV['FREDRIC_CACHE_DIR'] = nil
        ENV['FREDRIC_CACHE_LIFE'] = nil
      end

      it "has cache disabled" do
        expect(cli.fredric.cache).not_to be_enabled
      end
    end

    context "with CACHE_DIR" do
      it "enables cache" do
        ENV['FREDRIC_CACHE_DIR'] = 'hello'
        expect(cli.fredric.cache).to be_enabled
        expect(cli.fredric.cache.dir).to eq 'hello'
        ENV.delete 'FREDRIC_CACHE_DIR'
      end
    end

    context "with CACHE_LIFE" do
      it "enables cache" do
        ENV['FREDRIC_CACHE_LIFE'] = '123'
        expect(cli.fredric.cache).to be_enabled
        expect(cli.fredric.cache.life).to eq 123
        ENV.delete 'FREDRIC_CACHE_LIFE'
      end
    end
  end

  describe '#execute' do
    context "without arguments" do
      it "shows usage patterns" do
        expect {cli.execute}.to output(/Usage:/).to_stdout
      end
    end

    context "without FREDRIC_KEY" do
      let(:command) { %w[see series series_id:GNPCA] }

      before do
        @auth = ENV['FREDRIC_KEY']
        ENV.delete 'FREDRIC_KEY'
      end

      after do
        ENV['FREDRIC_KEY'] = @auth
      end

      it "shows a friendly error" do
        expect {cli.execute command}.to output(/Missing Authentication/).to_stdout
      end
    end

    context "with url command" do
      let(:command) { %w[url doesnt really:matter] }

      it "returns a url" do
        expected = /api\.stlouisfed\.org\/fred\/doesnt\?api_key=.*&file_type=json&really=matter/
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

    context "with pretty command", :focus do
      let(:command) { %w[pretty series series_id:GNPCA] }

      it "prints a prettified json output" do
        expected = /\s+"seriess": \[\n.*\}/m
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with see command" do
      let(:command) { %w[see series series_id:GNPCA] }

      it "awesome-prints output" do
        expected = /:seriess.*=>.*\[/
        expect {cli.execute command}.to output(expected).to_stdout
      end
    end

    context "with save command" do
      let(:command) { %W[save tmp.json series/observations series_id:GNPCA observation_start:2007-01-01 observation_end:2015-01-01] }
      let(:filename) { 'tmp.json' }

      it "saves a file" do
        File.unlink filename if File.exist? filename
        expect(File).not_to exist filename
        expected = "Saved #{filename}\n"

        expect {cli.execute command}.to output(expected).to_stdout
        expect(File).to exist filename
        expect(File.read filename).to eq fixture('gnpca.json')

        File.unlink filename
      end
    end

    context "with save --csv command" do
      let(:command) { %W[save --csv tmp.csv series/observations series_id:GNPCA observation_start:2007-01-01 observation_end:2015-01-01] }
      let(:filename) { 'tmp.csv' }

      it "saves a csv file" do
        File.unlink filename if File.exist? filename
        expect(File).not_to exist filename
        expected = "Saved #{filename}\n"

        expect {cli.execute command}.to output(expected).to_stdout
        expect(File).to exist filename
        expect(File.read filename).to eq fixture('gnpca.csv')

        File.unlink filename
      end
    end

    context "with an invalid path" do
      let(:command) { %W[get not_here] }
      
      it "fails with honor" do
        expect {cli.execute command}.to output(/404 Not Found/).to_stdout
      end
    end
  end

end