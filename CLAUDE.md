# lex-attentional-blink

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Models the refractory period after processing a salient stimulus, causing temporary reduced processing quality for subsequent stimuli. The attentional blink is the empirically documented phenomenon where processing a salient T1 stimulus creates a ~500ms window during which a T2 stimulus presented shortly after is less likely to be consciously perceived.

## Gem Info

- **Gem name**: `lex-attentional-blink`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::AttentionalBlink`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/attentional_blink/
  attentional_blink.rb           # Main extension module
  version.rb                     # VERSION = '0.1.0'
  client.rb                      # Client wrapper
  helpers/
    constants.rb                 # Blink duration, recovery rate, thresholds, stimulus types, labels
    stimulus.rb                  # Stimulus value object (type, salience, processing quality)
    blink_engine.rb              # BlinkEngine — blink state, stimulus submission, recovery
  runners/
    attentional_blink.rb         # Runner module with 9 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
MAX_STIMULI            = 500
MAX_BLINKS             = 200
DEFAULT_BLINK_DURATION = 3.0    # seconds
MIN_BLINK_DURATION     = 0.5
MAX_BLINK_DURATION     = 10.0
RECOVERY_RATE          = 0.15   # per recovery tick
SALIENCE_THRESHOLD     = 0.6    # triggers a blink
LAG1_SPARING_THRESHOLD = 0.3    # immediate successor gets spared from full blink
STIMULUS_TYPES = %i[visual auditory semantic emotional social threat reward novelty]
PROCESSING_LABELS = {
  (0.8..) => :fully_available, (0.6...0.8) => :mostly_available,
  (0.4...0.6) => :partially_suppressed, (0.2...0.4) => :mostly_suppressed,
  (..0.2) => :blinked
}
RECOVERY_LABELS = {
  (0.8..) => :recovered, ... (..0.2) => :saturated
}
```

## Runners

### `Runners::AttentionalBlink`

All methods delegate to the engine (accessed directly, not via private method). Uses `include ... if defined?` guard.

- `submit_stimulus(stimulus_type:, content:, salience: 0.5)` — submit a stimulus for processing; if salience >= `SALIENCE_THRESHOLD` and no active blink, triggers a blink; during a blink, processing quality is reduced
- `check_blink_status` — current blink state: active?, recovery_level, recovery_label
- `force_blink(duration: nil)` — manually trigger a blink (for simulation/testing)
- `force_recover` — immediately end any active blink
- `adjust_blink_duration(duration:)` — update the blink duration parameter
- `recent_stimuli_report(limit: 10)` — recent stimulus submissions
- `missed_stimuli_report` — stimuli that were processed during a blink (reduced quality)
- `stimuli_by_type_report(stimulus_type:)` — filter stimuli by type
- `blink_report` — comprehensive blink history and statistics
- `attentional_blink_stats` — full state hash

## Helpers

### `Helpers::BlinkEngine`
Core engine. `submit_stimulus` checks salience and blink state. During blink, processing quality is reduced proportionally to how deep the blink is (recovery_level). Lag-1 sparing: the stimulus immediately following a T1 at high salience gets slightly better processing than full blink suppression. `recovery_level` increases by `RECOVERY_RATE` per recovery tick (called on each non-triggering stimulus).

### `Helpers::Stimulus`
Value object: stimulus_type, content, salience, processing_quality (0–1, 1.0 if no blink), missed (bool if blink reduced quality significantly), submitted_at.

## Integration Points

No actor defined — blink recovery happens via stimulus submission (each new stimulus advances recovery). Integrates with lex-attention: after lex-attention filters signals, pass high-salience signals through the attentional blink model to simulate the temporal dynamics of attention. After a major event, subsequent signals get degraded processing — this models why agents miss things immediately after a surprising event. Connect to lex-tick's sensing phase.

## Development Notes

- Lag-1 sparing: in the real attentional blink, the stimulus immediately following T1 is sometimes spared. This is modeled via `LAG1_SPARING_THRESHOLD`
- Blink duration is configurable (`adjust_blink_duration`) to model individual differences or task states
- Recovery is implicit — each stimulus submission that doesn't trigger a new blink advances recovery by `RECOVERY_RATE`
- `missed?` on a Stimulus is computed from processing quality below a threshold, not from a flag
