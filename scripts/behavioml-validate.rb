#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'set'

model_root = ARGV[0]
if model_root.nil? || model_root.strip.empty?
  warn 'usage: behavioml-validate <model-root>'
  exit 2
end

unless Dir.exist?(model_root)
  warn "model root not found: #{model_root}"
  exit 2
end

FORBIDDEN_TOP_LEVEL_KEYS = %w[id ids uuid uuids].freeze
RELATIVE_REF = %r{(^\.{1,2}/|/\.{1,2}(/|$))}
SCOPES = %w[workflows roles capabilities interfaces components modules events entities state-machines decisions].freeze
TYPED_SCOPE_DIRS = SCOPES.to_h { |scope| [scope, scope] }

errors = []
warnings = []
parsed = {}
identities = Hash.new { |hash, key| hash[key] = Set.new }

source_files = Dir.glob(File.join(model_root, '**', '*.{yaml,yml,md}')).reject do |path|
  path.split(File::SEPARATOR).include?('generated')
end.sort

yaml_files = source_files.select { |path| path.end_with?('.yaml', '.yml') }

def identity_for(model_root, path)
  relative = path.delete_prefix(model_root).delete_prefix(File::SEPARATOR)
  scope, rest = relative.split(File::SEPARATOR, 2)
  return [nil, nil] if rest.nil?

  id = rest.sub(/\.(yaml|yml|md)\z/, '')
  [scope, id]
end

source_files.each do |path|
  scope, identity = identity_for(model_root, path)
  next unless SCOPES.include?(scope)

  identities[scope].add(identity)
end

yaml_files.each do |path|
  begin
    parsed[path] = YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}
  rescue StandardError => e
    errors << "#{path}: YAML parse error: #{e.message}"
    next
  end

  unless parsed[path].is_a?(Hash)
    errors << "#{path}: top-level YAML value must be a mapping"
    next
  end

  forbidden = parsed[path].keys.map(&:to_s) & FORBIDDEN_TOP_LEVEL_KEYS
  errors << "#{path}: forbidden top-level identity keys: #{forbidden.join(', ')}" unless forbidden.empty?
end

def each_ref(value)
  case value
  when Array
    value.each { |item| yield item }
  when String
    yield value
  end
end

def check_ref(errors, identities, path, field, target_scope, value)
  each_ref(value) do |ref|
    unless ref.is_a?(String)
      errors << "#{path}: #{field} reference must be a string"
      next
    end
    errors << "#{path}: #{field} uses relative reference #{ref.inspect}" if ref.match?(RELATIVE_REF)
    next if identities[target_scope].include?(ref)

    errors << "#{path}: #{field} references missing #{target_scope}/#{ref}"
  end
end

parsed.each do |path, data|
  next unless data.is_a?(Hash)

  scope, = identity_for(model_root, path)

  case scope
  when 'workflows'
    roles = data['roles'] || {}
    if roles.is_a?(Hash)
      check_ref(errors, identities, path, 'roles.primary', 'roles', roles['primary']) if roles.key?('primary')
      check_ref(errors, identities, path, 'roles.participants', 'roles', roles['participants']) if roles.key?('participants')
    else
      errors << "#{path}: roles must be a mapping when present"
    end
    check_ref(errors, identities, path, 'steps', 'capabilities', data['steps']) if data.key?('steps')
    check_ref(errors, identities, path, 'triggered_by', 'events', data['triggered_by']) if data.key?('triggered_by')
    if data.key?('components')
      errors << "#{path}: workflows must not reference components directly"
    end
  when 'capabilities'
    check_ref(errors, identities, path, 'uses', 'capabilities', data['uses']) if data.key?('uses')
    check_ref(errors, identities, path, 'requires', 'interfaces', data['requires']) if data.key?('requires')
    check_ref(errors, identities, path, 'events', 'events', data['events']) if data.key?('events')
  when 'components'
    implements = data['implements'] || {}
    if implements.is_a?(Hash)
      check_ref(errors, identities, path, 'implements.capabilities', 'capabilities', implements['capabilities']) if implements.key?('capabilities')
      check_ref(errors, identities, path, 'implements.interfaces', 'interfaces', implements['interfaces']) if implements.key?('interfaces')
    else
      errors << "#{path}: implements must be a mapping when present"
    end
    check_ref(errors, identities, path, 'belongs_to', 'modules', data['belongs_to']) if data.key?('belongs_to')
  when 'state-machines'
    check_ref(errors, identities, path, 'entity', 'entities', data['entity']) if data.key?('entity')
    states = data['states'] || []
    state_set = states.is_a?(Array) ? states.to_set : Set.new
    transitions = data['transitions'] || []
    if transitions.is_a?(Array)
      inbound = Hash.new(0)
      transitions.each_with_index do |transition, index|
        unless transition.is_a?(Hash)
          errors << "#{path}: transitions[#{index}] must be a mapping"
          next
        end
        from = transition['from']
        to = transition['to']
        if from.is_a?(Array)
          errors << "#{path}: transitions[#{index}].from must not be an empty array" if from.empty?
          from.each { |state| errors << "#{path}: transitions[#{index}].from references unknown state #{state.inspect}" unless state_set.include?(state) }
        elsif from.is_a?(String)
          errors << "#{path}: transitions[#{index}].from references unknown state #{from.inspect}" unless state_set.include?(from)
        else
          errors << "#{path}: transitions[#{index}].from must be a string or non-empty array of strings"
        end
        unless to.is_a?(String)
          errors << "#{path}: transitions[#{index}].to must be a string"
        else
          errors << "#{path}: transitions[#{index}].to references unknown state #{to.inspect}" unless state_set.include?(to)
          inbound[to] += 1
        end
        check_ref(errors, identities, path, "transitions[#{index}].on", 'events', transition['on']) if transition.key?('on')
      end
      states.each do |state|
        next if inbound[state].positive?
        warnings << "#{path}: coverage: state #{state.inspect} has no inbound transition"
      end if states.is_a?(Array)
    else
      errors << "#{path}: transitions must be an array when present"
    end
  when 'decisions'
    if data.key?('affects')
      affects = data['affects']
      if affects.is_a?(Array)
        affects.each_with_index do |ref, index|
          unless ref.is_a?(String) && ref.include?(':')
            errors << "#{path}: affects[#{index}] must use typed reference syntax <scope>:<identity>"
            next
          end
          typed_scope, identity = ref.split(':', 2)
          unless TYPED_SCOPE_DIRS.key?(typed_scope)
            errors << "#{path}: affects[#{index}] uses unknown scope #{typed_scope.inspect}"
            next
          end
          if ref.match?(RELATIVE_REF)
            errors << "#{path}: affects[#{index}] uses relative reference #{ref.inspect}"
          end
          unless identities[TYPED_SCOPE_DIRS[typed_scope]].include?(identity)
            errors << "#{path}: affects[#{index}] references missing #{typed_scope}/#{identity}"
          end
        end
      else
        errors << "#{path}: affects must be an array when present"
      end
    end
  end
end

if errors.empty?
  puts "BehavioML validation passed: #{model_root}"
  puts "  files checked: #{yaml_files.length} YAML, #{source_files.length - yaml_files.length} Markdown"
  if warnings.empty?
    puts '  coverage findings: none'
  else
    puts "  coverage findings: #{warnings.length}"
    warnings.each { |warning| puts "  - #{warning}" }
  end
  exit 0
end

warn "BehavioML validation failed: #{model_root}"
errors.each { |error| warn "  - #{error}" }
exit 1
