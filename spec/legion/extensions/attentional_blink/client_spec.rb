# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionalBlink::Client do
  subject(:client) { described_class.new }

  it 'includes the runner module' do
    expect(client).to respond_to(:submit_stimulus)
  end

  it 'provides an engine' do
    expect(client.engine).to be_a(Legion::Extensions::AttentionalBlink::Helpers::BlinkEngine)
  end

  it 'submits and processes stimuli' do
    result = client.submit_stimulus(stimulus_type: :auditory, content: 'beep')
    expect(result[:success]).to be true
  end
end
