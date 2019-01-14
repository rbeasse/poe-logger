module ItemParser
  extend ActiveSupport::Concern

  SEPERATOR = '--------'
  SIMPLE_ATTRIBUTES  = ['Rarity', 'Quality' 'Sockets', 'Item Level']
  BOOLEAN_ATTRIBUTES = ['Shaper', 'Elder', 'Corrupted']

  # Accepcts a formatted Path Of Exile item string and parses out
  # the attributes in to our model
  def save_from_string(item_string)
    return if item_string.blank?

    fragments = item_string.split(SEPERATOR)

    fragments.each do |fragment|
      rows = fragment.split("\n").compact

      parse_simple_attributes(rows)
      parse_boolean_attributes(rows)
      parse_modifiers(rows)
    end

    # We know that Rarity will always be set - as it's in every valid item string. If
    # it is not, then we can assume the parse failed
    self.Rarity.present? && save
  end

  private

    def parse_simple_attributes(rows)
      regexp = /^[a-zA-Z1-9 ]*: .*$/

      rows.each do |row|
        next unless regexp =~ row

        key, value      = row.split(': ')
        database_column = key.gsub(' ', '')

        self[database_column] = value if SIMPLE_ATTRIBUTES.include?(key)
      end
    end

    def parse_boolean_attributes(rows)
      rows.each do |row|
        next unless BOOLEAN_ATTRIBUTES.include?(row)

        self[row] = true
      end
    end

    def parse_modifiers(rows)
      rows.each do |row|
        modifier = ModifierString.find_if_valid_modifier(row)

        item_modifiers << ItemModifier.new(ModifierID: modifier) if modifier.present?
      end
    end

end