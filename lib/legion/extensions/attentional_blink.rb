# frozen_string_literal: true

require_relative 'attentional_blink/version'
require_relative 'attentional_blink/helpers/constants'
require_relative 'attentional_blink/helpers/stimulus'
require_relative 'attentional_blink/helpers/blink_engine'
require_relative 'attentional_blink/runners/attentional_blink'
require_relative 'attentional_blink/client'

module Legion
  module Extensions
    module AttentionalBlink
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
