class Hash
  def without(*keys)
    select { |k, _| !keys.include?(k) }
  end

  def hmap(&block)
    Hash[map { |k, v| block.call(k, v) }]
  end

  def hmap!(&block)
    keys.each do |key|
      hash = block.call(key, self[key])

      self[hash.keys.first] = hash[hash.keys.first]
      delete(key)
    end
    self
  end

  def deep_symbolize_keys
    inject({}) do |memo, (k, v)|
      memo[k.to_sym] = v.is_a?(Hash) ? v.deep_symbolize_keys : v
      memo
    end
  end

  def compact
    delete_if { |_, v| v.nil? }
  end
end
