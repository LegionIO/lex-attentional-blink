# lex-attentional-blink

Attentional blink modeling for LegionIO — refractory period after processing a salient stimulus causes temporary reduced processing quality.

## What It Does

Models the attentional blink: after processing a high-salience stimulus, the agent enters a refractory period during which subsequent stimuli receive reduced processing quality. This is the cognitive basis for "missing" information that arrives immediately after something surprising. The blink duration and recovery rate are configurable. Includes lag-1 sparing: the stimulus immediately following a triggering event gets slightly better processing than full suppression.

## Core Concept: Blink and Recovery

```
Submit salient stimulus (salience >= 0.6) → triggers blink
  → subsequent stimuli during blink get reduced processing_quality
  → each non-triggering stimulus advances recovery by 0.15
  → blink ends when recovery_level reaches 1.0
```

## Usage

```ruby
client = Legion::Extensions::AttentionalBlink::Client.new

# Submit a high-salience event (triggers blink)
client.submit_stimulus(stimulus_type: :threat, content: 'security alert', salience: 0.9)
# => { blink_active: true, processing_quality: 1.0 }  # the T1 itself is fully processed

# Subsequent stimulus arrives during blink
client.submit_stimulus(stimulus_type: :semantic, content: 'config change', salience: 0.5)
# => { blink_active: true, processing_quality: 0.3 }  # reduced quality

# Check recovery
client.check_blink_status
# => { blink_active: true, recovery_level: 0.15, recovery_label: :saturated }

# What was missed?
client.missed_stimuli_report
# => { count: 1, stimuli: [{ content: 'config change', processing_quality: 0.3 }] }
```

## Integration

Place after lex-attention's signal filtering in the sensing phase. High-salience signals trigger blinks that degrade subsequent signal processing — modeling why agents miss context immediately after major events.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
