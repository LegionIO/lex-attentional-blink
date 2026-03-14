# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionalBlink
      module Helpers
        class BlinkEngine
          include Constants

          def initialize
            @stimuli       = {}
            @blink_active  = false
            @blink_start   = nil
            @blink_duration = DEFAULT_BLINK_DURATION
            @recovery      = 1.0
            @total_blinks  = 0
            @total_misses  = 0
          end

          def submit_stimulus(stimulus_type:, content:, salience: 0.5)
            prune_stimuli_if_needed
            stimulus = Stimulus.new(
              stimulus_type: stimulus_type,
              content:       content,
              salience:      salience
            )

            quality = compute_processing_quality(stimulus)
            stimulus.process!(quality: quality)

            trigger_blink!(stimulus) if stimulus.salient? && !@blink_active
            @total_misses += 1 if stimulus.missed?

            @stimuli[stimulus.id] = stimulus
            stimulus
          end

          def blink_active?
            return false unless @blink_active

            elapsed = Time.now.utc.to_f - @blink_start
            if elapsed >= @blink_duration
              @blink_active = false
              @recovery = 1.0
              return false
            end

            true
          end

          def recovery_level
            return 1.0 unless @blink_active

            elapsed = Time.now.utc.to_f - @blink_start
            progress = (elapsed / @blink_duration).clamp(0.0, 1.0)
            (progress**0.5).round(10)
          end

          def recovery_label
            match = RECOVERY_LABELS.find { |range, _| range.cover?(recovery_level) }
            match ? match.last : :saturated
          end

          def force_blink!(duration: DEFAULT_BLINK_DURATION)
            @blink_active = true
            @blink_start = Time.now.utc.to_f
            @blink_duration = duration.to_f.clamp(MIN_BLINK_DURATION, MAX_BLINK_DURATION)
            @recovery = 0.0
            @total_blinks += 1
            { blink_active: true, duration: @blink_duration, total_blinks: @total_blinks }
          end

          def force_recover!
            @blink_active = false
            @recovery = 1.0
            @blink_start = nil
            { blink_active: false, recovery: 1.0 }
          end

          def adjust_blink_duration(duration:)
            @blink_duration = duration.to_f.clamp(MIN_BLINK_DURATION, MAX_BLINK_DURATION)
          end

          def miss_rate
            return 0.0 if @stimuli.empty?

            (@total_misses.to_f / @stimuli.size).round(10)
          end

          def recent_stimuli(limit: 10)
            @stimuli.values.sort_by { |s| -s.arrival_time }.first(limit)
          end

          def missed_stimuli
            @stimuli.values.select(&:missed?)
          end

          def stimuli_by_type(stimulus_type:)
            st = stimulus_type.to_sym
            @stimuli.values.select { |s| s.stimulus_type == st }
          end

          def processing_quality_average
            return 0.0 if @stimuli.empty?

            qualities = @stimuli.values.map(&:processing_quality)
            (qualities.sum / qualities.size).round(10)
          end

          def blink_report
            {
              total_stimuli:  @stimuli.size,
              total_blinks:   @total_blinks,
              total_misses:   @total_misses,
              miss_rate:      miss_rate,
              blink_active:   blink_active?,
              recovery_level: recovery_level,
              recovery_label: recovery_label,
              blink_duration: @blink_duration,
              avg_quality:    processing_quality_average,
              recent_missed:  missed_stimuli.last(5).map(&:to_h)
            }
          end

          def to_h
            {
              total_stimuli: @stimuli.size,
              total_blinks:  @total_blinks,
              miss_rate:     miss_rate,
              blink_active:  blink_active?,
              avg_quality:   processing_quality_average
            }
          end

          private

          def compute_processing_quality(stimulus)
            if blink_active?
              lag1_sparing = stimulus.salience >= (1.0 - LAG1_SPARING_THRESHOLD) ? 0.3 : 0.0
              base = (recovery_level * 0.5) + lag1_sparing
              [base, stimulus.salience * 0.3].max.clamp(0.0, 1.0).round(10)
            else
              base = 0.6 + (stimulus.salience * 0.4)
              base.clamp(0.0, 1.0).round(10)
            end
          end

          def trigger_blink!(stimulus)
            @blink_active = true
            @blink_start = Time.now.utc.to_f
            scaled_duration = @blink_duration * (0.5 + (stimulus.salience * 0.5))
            @blink_duration = scaled_duration.clamp(MIN_BLINK_DURATION, MAX_BLINK_DURATION)
            @recovery = 0.0
            @total_blinks += 1
          end

          def prune_stimuli_if_needed
            return if @stimuli.size < MAX_STIMULI

            oldest = @stimuli.values.min_by(&:arrival_time)
            @stimuli.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
