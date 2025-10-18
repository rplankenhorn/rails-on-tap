class PluginDatum < ApplicationRecord
  # Validations
  validates :plugin_name, presence: true, length: { maximum: 127 }
  validates :key, presence: true, length: { maximum: 127 }
  validates :key, uniqueness: { scope: :plugin_name }

  # Class methods
  def self.get_value(plugin_name, key, default = nil)
    record = find_by(plugin_name: plugin_name, key: key)
    record ? record.value : default
  end

  def self.set_value(plugin_name, key, value)
    record = find_or_initialize_by(plugin_name: plugin_name, key: key)
    record.value = value
    record.save!
    record
  end
end
