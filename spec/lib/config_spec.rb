require 'spec_helper'

module ZipkinTracer
  RSpec.describe Config do
    before do
      allow(Application).to receive(:logger).and_return(Logger.new(nil))
    end
    [:service_name, :service_port, :json_api_host,
      :zookeeper, :sample_rate, :log_tracing,
      :annotate_plugin, :filter_plugin, :whitelist_plugin].each do |method|
      it "can set and read configuration values for #{method}" do
        value = rand(100)
        config = Config.new(nil, { method => value })
        expect(config.send(method)).to eq(value)
      end
    end

    it 'sets defaults' do
      config = Config.new(nil, {})
      [:sample_rate, :service_port, :sampled_as_boolean].each do |key|
        expect(config.send(key)).to_not eq(nil)
      end
    end

    describe 'logger' do
      it 'uses the application logger' do
        config = Config.new(nil, {})
        expect(config.logger).to eq(Application.logger)
      end
    end

    describe '#adapter' do
      it 'returns nil if no adapter has been set' do
        config = Config.new(nil, {})
        expect(config.adapter).to be_nil
      end

      context 'json' do
        it 'returns :json if the json api endpoint has been set' do
          config = Config.new(nil, json_api_host: 'http://server.yes.net')
          expect(config.adapter).to eq(:json)
        end
      end

      context 'log_tracing' do
        it 'returns :logger if log_tracing has been set to true' do
          config = Config.new(nil, log_tracing: true)
          expect(config.adapter).to eq(:logger)
        end
      end

      context 'kafka' do
        before { stub_const('RUBY_PLATFORM', 'java') }

        it 'does not return :kafka if zookeeper has not been set' do
          config = Config.new(nil, {})
          stub_const('Hermann', 'CoolGem')
          expect(config.adapter).to be_nil
        end

        it 'returns :kafka if zookeeper and Hermann are used in java' do
          stub_const('Hermann', 'CoolGem')
          config = Config.new(nil, zookeeper: 'http://server.yes.net')
          expect(config.adapter).to eq(:kafka)
        end
      end
    end
  end
end
