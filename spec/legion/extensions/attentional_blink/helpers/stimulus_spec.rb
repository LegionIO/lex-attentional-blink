# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionalBlink::Helpers::Stimulus do
  subject(:stimulus) { described_class.new(stimulus_type: :visual, content: 'flash', salience: 0.7) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(stimulus.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets type and content' do
      expect(stimulus.stimulus_type).to eq(:visual)
      expect(stimulus.content).to eq('flash')
    end

    it 'starts unprocessed' do
      expect(stimulus.processed).to be false
      expect(stimulus.processing_quality).to eq(0.0)
    end
  end

  describe '#salient?' do
    it 'returns true when salience >= threshold' do
      expect(stimulus.salient?).to be true
    end

    it 'returns false when below threshold' do
      s = described_class.new(stimulus_type: :visual, content: 'dim', salience: 0.3)
      expect(s.salient?).to be false
    end
  end

  describe '#process!' do
    it 'marks as processed with quality' do
      stimulus.process!(quality: 0.8)
      expect(stimulus.processed).to be true
      expect(stimulus.processing_quality).to eq(0.8)
    end

    it 'clamps quality to 0..1' do
      stimulus.process!(quality: 1.5)
      expect(stimulus.processing_quality).to eq(1.0)
    end
  end

  describe '#processing_label' do
    it 'returns :blinked when unprocessed' do
      expect(stimulus.processing_label).to eq(:blinked)
    end

    it 'returns :fully_available for high quality' do
      stimulus.process!(quality: 0.9)
      expect(stimulus.processing_label).to eq(:fully_available)
    end
  end

  describe '#missed?' do
    it 'returns true when processed with very low quality' do
      stimulus.process!(quality: 0.1)
      expect(stimulus.missed?).to be true
    end

    it 'returns false for adequate quality' do
      stimulus.process!(quality: 0.5)
      expect(stimulus.missed?).to be false
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      h = stimulus.to_h
      expect(h).to include(:id, :stimulus_type, :content, :salience,
                           :processed, :processing_quality, :processing_label,
                           :salient, :missed, :arrival_time, :created_at)
    end
  end
end
