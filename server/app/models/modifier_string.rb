class ModifierString < ApplicationRecord
  NUMBER_REGEXP = /[-+]?[0-9]*\.?[0-9]{1,2}\%?/

  self.table_name  = 'ModifierString'
  self.primary_key = 'ModifierID'

  # Checks our database of modifiers and tries to find a valid modifier. If
  # a modifier is found we return that modifier id
  def self.find_if_valid_modifier(fragment_row)
    fragment_row = fragment_row.strip

    return false if fragment_row.empty?

    fragment_row = fragment_row.gsub(NUMBER_REGEXP, '{_}')

    puts fragment_row.inspect
    puts '----'

    modifier_string = where('[String] LIKE ?', fragment_row).first

    return unless modifier_string.present?

    modifier_string.ModifierID
  end
end
