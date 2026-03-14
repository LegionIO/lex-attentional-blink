# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionalBlink::Helpers::Constants do
  let(:klass) { Class.new { include Legion::Extensions::AttentionalBlink::Helpers::Constants } }

  it 'defines MAX_STIMULI' do
    expect(klass::MAX_STIMULI).to eq(500)
  end

  it 'defines DEFAULT_BLINK_DURATION' do
    expect(klass::DEFAULT_BLINK_DURATION).to eq(3.0)
  end

  it 'defines PROCESSING_LABELS as frozen hash' do
    expect(klass::PROCESSING_LABELS).to be_frozen
    expect(klass::PROCESSING_LABELS.size).to eq(5)
  end

  it 'defines RECOVERY_LABELS as frozen hash' do
    expect(klass::RECOVERY_LABELS).to be_frozen
  end

  it 'defines STIMULUS_TYPES as frozen array' do
    expect(klass::STIMULUS_TYPES).to be_frozen
    expect(klass::STIMULUS_TYPES).to include(:visual, :auditory, :threat)
  end
end
