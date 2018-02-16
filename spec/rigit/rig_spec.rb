require 'spec_helper'

describe Rig do
  subject { described_class.new 'minimal'}

  describe '::home' do
    context 'when RIG_HOME is not set' do
      it 'returns ~/.rigs' do
        without_env 'RIG_HOME' do
          expect(Rig.home).to eq "#{Dir.home}/.rigs"
        end
      end
    end

    context 'when RIG_HOME is set' do
      it 'returns RIG_HOME' do
        with_env 'RIG_HOME', 'some/path' do
          expect(Rig.home).to eq "some/path"
        end
      end
    end
  end

  describe '::home=' do
    it 'sets Rig.home' do
      without_env 'RIG_HOME' do
        Rig.home = 'some/new/path'
        expect(Rig.home).to eq 'some/new/path'
      end      
    end
  end

  describe '#scaffold' do
    let(:workdir) { 'spec/tmp' }
    before { reset_workdir }

    context 'with minimal example and no config' do
      it 'copies all files and folders' do
        Dir.chdir workdir do
          subject.scaffold
          expect(ls).to match_fixture 'ls/minimal'
        end
      end
    end

    context 'with full example' do
      let(:arguments) {{ name: 'myapp', license: 'MIT', spec: 'y', console: 'irb' }}
      subject { described_class.new 'full' }

      it 'copies all files and folders' do
        Dir.chdir workdir do
          subject.scaffold arguments: arguments
          expect(ls).to match_fixture 'ls/full'
        end
      end

      it 'replaces string tokens in all files' do
        Dir.chdir workdir do
          subject.scaffold arguments: arguments
          files = Dir['**/*.*']
          expect(files.count).to eq 6
          
          files.each do |file|
            fixture_name = "content/#{File.basename(file)}"
            expect(File.read file).to match_fixture(fixture_name)
          end
        end
      end
    end
  end

  describe '#path' do
    it 'returns full rig path' do
      expect(subject.path).to eq "#{Rig.home}/#{subject.name}"
    end
  end

  describe '#exist?' do
    context 'when the rig path exists' do
      it 'returns true' do
        expect(subject).to exist
      end
    end

    context 'when the rig path does not exist' do
      subject { Rig.new 'no-such-rig'}

      it 'returns false' do
        expect(subject).not_to exist
      end
    end
  end

  describe '#config_file' do
    it 'returns path to config file' do
      expect(subject.config_file).to eq "#{subject.path}/config.yml"
    end
  end

  describe '#config' do
    subject { described_class.new 'full' }

    it 'returns the config object' do
      expect(subject.config.intro).to eq 'If you rig it, they will come'
    end
  end
end