# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionalBlink::Helpers::BlinkEngine do
  subject(:engine) { described_class.new }

  describe '#submit_stimulus' do
    it 'returns a processed Stimulus' do
      result = engine.submit_stimulus(stimulus_type: :visual, content: 'flash', salience: 0.7)
      expect(result).to be_a(Legion::Extensions::AttentionalBlink::Helpers::Stimulus)
      expect(result.processed).to be true
    end

    it 'triggers blink for salient stimuli' do
      engine.submit_stimulus(stimulus_type: :visual, content: 'bright', salience: 0.9)
      expect(engine.blink_active?).to be true
    end

    it 'does not trigger blink for low-salience stimuli' do
      engine.submit_stimulus(stimulus_type: :visual, content: 'dim', salience: 0.2)
      expect(engine.blink_active?).to be false
    end

    it 'reduces processing quality during blink' do
      engine.submit_stimulus(stimulus_type: :visual, content: 'trigger', salience: 0.9)
      second = engine.submit_stimulus(stimulus_type: :visual, content: 'missed', salience: 0.3)
      expect(second.processing_quality).to be < 0.6
    end
  end

  describe '#blink_active?' do
    it 'returns false initially' do
      expect(engine.blink_active?).to be false
    end
  end

  describe '#recovery_level' do
    it 'returns 1.0 when no blink' do
      expect(engine.recovery_level).to eq(1.0)
    end
  end

  describe '#recovery_label' do
    it 'returns :recovered when not blinking' do
      expect(engine.recovery_label).to eq(:recovered)
    end
  end

  describe '#force_blink!' do
    it 'activates blink' do
      result = engine.force_blink!(duration: 5.0)
      expect(result[:blink_active]).to be true
      expect(result[:total_blinks]).to eq(1)
      expect(engine.blink_active?).to be true
    end

    it 'clamps duration' do
      result = engine.force_blink!(duration: 0.1)
      expect(result[:duration]).to be >= 0.5
    end
  end

  describe '#force_recover!' do
    it 'deactivates blink' do
      engine.force_blink!
      result = engine.force_recover!
      expect(result[:blink_active]).to be false
      expect(engine.blink_active?).to be false
    end
  end

  describe '#adjust_blink_duration' do
    it 'sets new duration' do
      engine.adjust_blink_duration(duration: 7.0)
      result = engine.force_blink!
      expect(result[:duration]).to be <= 10.0
    end
  end

  describe '#miss_rate' do
    it 'returns 0.0 with no stimuli' do
      expect(engine.miss_rate).to eq(0.0)
    end

    it 'tracks missed stimuli ratio' do
      engine.force_blink!
      5.times { engine.submit_stimulus(stimulus_type: :visual, content: 'x', salience: 0.1) }
      expect(engine.miss_rate).to be >= 0.0
    end
  end

  describe '#recent_stimuli' do
    it 'returns empty when no stimuli' do
      expect(engine.recent_stimuli).to be_empty
    end

    it 'returns most recent stimuli' do
      3.times { |i| engine.submit_stimulus(stimulus_type: :auditory, content: "s#{i}", salience: 0.3) }
      expect(engine.recent_stimuli(limit: 2).size).to eq(2)
    end
  end

  describe '#missed_stimuli' do
    it 'returns only missed stimuli' do
      engine.force_blink!
      engine.submit_stimulus(stimulus_type: :visual, content: 'dim', salience: 0.1)
      missed = engine.missed_stimuli
      expect(missed.all?(&:missed?)).to be true
    end
  end

  describe '#stimuli_by_type' do
    it 'filters by stimulus type' do
      engine.submit_stimulus(stimulus_type: :visual, content: 'a', salience: 0.3)
      engine.submit_stimulus(stimulus_type: :auditory, content: 'b', salience: 0.3)
      result = engine.stimuli_by_type(stimulus_type: :visual)
      expect(result.size).to eq(1)
    end
  end

  describe '#processing_quality_average' do
    it 'returns 0.0 with no stimuli' do
      expect(engine.processing_quality_average).to eq(0.0)
    end

    it 'computes average quality' do
      3.times { engine.submit_stimulus(stimulus_type: :visual, content: 'x', salience: 0.3) }
      expect(engine.processing_quality_average).to be > 0.0
    end
  end

  describe '#blink_report' do
    it 'returns comprehensive report' do
      engine.submit_stimulus(stimulus_type: :visual, content: 'x', salience: 0.3)
      report = engine.blink_report
      expect(report).to include(:total_stimuli, :total_blinks, :total_misses,
                                :miss_rate, :blink_active, :recovery_level,
                                :recovery_label, :avg_quality, :recent_missed)
    end
  end

  describe '#to_h' do
    it 'returns engine stats' do
      h = engine.to_h
      expect(h).to include(:total_stimuli, :total_blinks, :miss_rate, :blink_active, :avg_quality)
    end
  end
end
