# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionalBlink
      module Helpers
        module Constants
          MAX_STIMULI = 500
          MAX_BLINKS = 200

          DEFAULT_BLINK_DURATION = 3.0
          MIN_BLINK_DURATION = 0.5
          MAX_BLINK_DURATION = 10.0
          RECOVERY_RATE = 0.15
          SALIENCE_THRESHOLD = 0.6
          LAG1_SPARING_THRESHOLD = 0.3

          PROCESSING_LABELS = {
            (0.8..)     => :fully_available,
            (0.6...0.8) => :mostly_available,
            (0.4...0.6) => :partially_suppressed,
            (0.2...0.4) => :mostly_suppressed,
            (..0.2)     => :blinked
          }.freeze

          RECOVERY_LABELS = {
            (0.8..)     => :recovered,
            (0.6...0.8) => :recovering,
            (0.4...0.6) => :refractory,
            (0.2...0.4) => :deep_blink,
            (..0.2)     => :saturated
          }.freeze

          STIMULUS_TYPES = %i[
            visual auditory semantic emotional
            social threat reward novelty
          ].freeze
        end
      end
    end
  end
end
