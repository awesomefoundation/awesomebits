# frozen_string_literal: true

require "digest"
require "json"
require "fileutils"

# File-based passthrough cache for Anthropic API responses.
# Cache key = SHA256(model + system_prompt + tool_schema + user_message)
#
# Usage:
#   cache = AnthropicCache.new(".scratch/cache/anthropic")
#   response = cache.fetch(request_params) { call_anthropic(request_params) }
#
class AnthropicCache
  attr_reader :cache_dir, :stats

  def initialize(cache_dir = nil)
    @cache_dir = cache_dir || File.expand_path("../../.scratch/cache/anthropic", __dir__)
    FileUtils.mkdir_p(@cache_dir)
    @stats = { hits: 0, misses: 0 }
  end

  # Fetch a cached response or execute the block and cache the result.
  def fetch(request_params)
    key = cache_key(request_params)
    path = cache_path(key)

    if File.exist?(path)
      @stats[:hits] += 1
      JSON.parse(File.read(path))
    else
      response = yield
      File.write(path, JSON.pretty_generate(response))
      @stats[:misses] += 1
      response
    end
  end

  # Check if a response is cached without fetching.
  def cached?(request_params)
    File.exist?(cache_path(cache_key(request_params)))
  end

  # Write a result directly (e.g., from batch API result parsing).
  def write(request_params, response)
    key = cache_key(request_params)
    File.write(cache_path(key), JSON.pretty_generate(response))
  end

  # Read a cached result without calling API.
  def read(request_params)
    key = cache_key(request_params)
    path = cache_path(key)
    return nil unless File.exist?(path)

    JSON.parse(File.read(path))
  end

  # Number of cached responses.
  def size
    Dir.glob(File.join(@cache_dir, "*.json")).length
  end

  # Clear all cached responses.
  def clear!
    Dir.glob(File.join(@cache_dir, "*.json")).each { |f| File.delete(f) }
  end

  private

  def cache_key(params)
    # Extract the parts that determine the response
    model = params[:model] || params["model"] || ""
    system = params[:system] || params["system"] || ""
    tools = params[:tools] || params["tools"] || []
    messages = params[:messages] || params["messages"] || []

    # Stable serialization for hashing
    content = JSON.generate({
      model: model,
      system: system,
      tools: tools,
      messages: messages,
    })

    Digest::SHA256.hexdigest(content)
  end

  def cache_path(key)
    File.join(@cache_dir, "#{key}.json")
  end
end
