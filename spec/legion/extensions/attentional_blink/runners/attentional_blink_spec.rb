# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionalBlink::Runners::AttentionalBlink do
  subject(:runner) do
    Class.new do
      include Legion::Extensions::AttentionalBlink::Runners::AttentionalBlink

      def engine
        @engine ||= Legion::Extensions::AttentionalBlink::Helpers::BlinkEngine.new
      end
    end.new
  end

  describe '#submit_stimulus' do
    it 'returns success with stimulus data' do
      result = runner.submit_stimulus(stimulus_type: :visual, content: 'flash', salience: 0.7)
      expect(result[:success]).to be true
      expect(result[:stimulus_type]).to eq(:visual)
    end
  end

  describe '#check_blink_status' do
    it 'returns blink status' do
      result = runner.check_blink_status
      expect(result[:success]).to be true
      expect(result[:blink_active]).to be false
    end
  end

  describe '#force_blink' do
    it 'activates blink' do
      result = runner.force_blink(duration: 5.0)
      expect(result[:success]).to be true
      expect(result[:blink_active]).to be true
    end
  end

  describe '#force_recover' do
    it 'deactivates blink' do
      runner.force_blink
      result = runner.force_recover
      expect(result[:success]).to be true
      expect(result[:blink_active]).to be false
    end
  end

  describe '#recent_stimuli_report' do
    it 'returns stimuli list' do
      runner.submit_stimulus(stimulus_type: :visual, content: 'x')
      result = runner.recent_stimuli_report(limit: 5)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#missed_stimuli_report' do
    it 'returns missed stimuli' do
      result = runner.missed_stimuli_report
      expect(result[:success]).to be true
      expect(result[:count]).to eq(0)
    end
  end

  describe '#blink_report' do
    it 'returns comprehensive report' do
      result = runner.blink_report
      expect(result).to include(:total_stimuli, :total_blinks, :miss_rate)
    end
  end

  describe '#attentional_blink_stats' do
    it 'returns engine stats' do
      result = runner.attentional_blink_stats
      expect(result).to include(:total_stimuli, :total_blinks, :miss_rate)
    end
  end
end
