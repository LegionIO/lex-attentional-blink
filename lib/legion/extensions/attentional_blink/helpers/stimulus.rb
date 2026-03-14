# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module AttentionalBlink
      module Helpers
        class Stimulus
          include Constants

          attr_reader :id, :stimulus_type, :content, :salience, :processed,
                      :processing_quality, :arrival_time, :created_at

          def initialize(stimulus_type:, content:, salience: 0.5, arrival_time: nil)
            @id                 = SecureRandom.uuid
            @stimulus_type      = stimulus_type.to_sym
            @content            = content
            @salience           = salience.to_f.clamp(0.0, 1.0)
            @processed          = false
            @processing_quality = 0.0
            @arrival_time       = arrival_time || Time.now.utc.to_f
            @created_at         = Time.now.utc
          end

          def process!(quality:)
            @processed = true
            @processing_quality = quality.to_f.clamp(0.0, 1.0)
            self
          end

          def salient?
            @salience >= SALIENCE_THRESHOLD
          end

          def processing_label
            match = PROCESSING_LABELS.find { |range, _| range.cover?(@processing_quality) }
            match ? match.last : :blinked
          end

          def missed?
            @processed && @processing_quality < 0.2
          end

          def to_h
            {
              id:                 @id,
              stimulus_type:      @stimulus_type,
              content:            @content,
              salience:           @salience,
              processed:          @processed,
              processing_quality: @processing_quality,
              processing_label:   processing_label,
              salient:            salient?,
              missed:             missed?,
              arrival_time:       @arrival_time,
              created_at:         @created_at
            }
          end
        end
      end
    end
  end
end
