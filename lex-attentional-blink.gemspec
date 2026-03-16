# frozen_string_literal: true

require_relative 'lib/legion/extensions/attentional_blink/version'

Gem::Specification.new do |spec|
  spec.name    = 'lex-attentional-blink'
  spec.version = Legion::Extensions::AttentionalBlink::VERSION
  spec.authors = ['Esity']
  spec.email   = ['matthewdiverson@gmail.com']

  spec.summary     = 'Attentional blink modeling for LegionIO'
  spec.description = 'Models the refractory period after processing a salient stimulus, ' \
                     'causing temporary reduced processing quality for subsequent stimuli.'
  spec.homepage    = 'https://github.com/LegionIO/lex-attentional-blink'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-attentional-blink'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-attentional-blink'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-attentional-blink/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-attentional-blink/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*']
  spec.add_development_dependency 'legion-gaia'
end
