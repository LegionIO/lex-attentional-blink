# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionalBlink
      module Runners
        module AttentionalBlink
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def submit_stimulus(stimulus_type:, content:, salience: 0.5, **)
            stimulus = engine.submit_stimulus(
              stimulus_type: stimulus_type,
              content:       content,
              salience:      salience
            )
            { success: true }.merge(stimulus.to_h)
          end

          def check_blink_status(**)
            {
              success:        true,
              blink_active:   engine.blink_active?,
              recovery_level: engine.recovery_level,
              recovery_label: engine.recovery_label
            }
          end

          def force_blink(duration: nil, **)
            d = duration || Helpers::Constants::DEFAULT_BLINK_DURATION
            result = engine.force_blink!(duration: d)
            { success: true }.merge(result)
          end

          def force_recover(**)
            result = engine.force_recover!
            { success: true }.merge(result)
          end

          def adjust_blink_duration(duration:, **)
            engine.adjust_blink_duration(duration: duration)
            { success: true, blink_duration: duration }
          end

          def recent_stimuli_report(limit: 10, **)
            stimuli = engine.recent_stimuli(limit: limit)
            { success: true, count: stimuli.size, stimuli: stimuli.map(&:to_h) }
          end

          def missed_stimuli_report(**)
            missed = engine.missed_stimuli
            { success: true, count: missed.size, stimuli: missed.map(&:to_h) }
          end

          def stimuli_by_type_report(stimulus_type:, **)
            stimuli = engine.stimuli_by_type(stimulus_type: stimulus_type)
            { success: true, stimulus_type: stimulus_type.to_sym, count: stimuli.size,
              stimuli: stimuli.map(&:to_h) }
          end

          def blink_report(**)
            engine.blink_report
          end

          def attentional_blink_stats(**)
            engine.to_h
          end
        end
      end
    end
  end
end
