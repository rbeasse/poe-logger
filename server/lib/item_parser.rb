class ItemParser
  SEPERATOR = '--------'

  def initialize(item_string)
    @item      = { modifiers: [] }
    @fragments = item_string.split(SEPERATOR)

    parse_fragments
  end

  private

    def parse_fragments()
      @fragments.each do |fragment|
        rows = fragment.split("\n").compact

        parse_simple_attributes(rows)
        parse_simple_strings(rows)
        parse_modifiers(rows)
      end
    end

    def parse_simple_attributes(rows)
      regexp = /^[a-zA-Z1-9 ]*: .*$/

      rows.each do |row|
        next unless regexp =~ row

        key, value = row.split(': ')

        @item[key] = value
      end
    end

    def parse_simple_strings(rows)
      plain_text_attributes = %w[Shaper Elder Corrupted]

      rows.each do |row|
        next unless plain_text_attributes.include?(row)

        @item[row] = true
      end
    end

    def parse_modifiers(rows)
      regexp = /[-+]?[0-9]*\.?[0-9]{1,2}/

      rows.each do |row|
        row = row.gsub(regexp, '{_}').
                  gsub('%', '[%]').
                  gsub('\'', '\'\'')

        modifier_query = "SELECT TOP (1) ModifierID FROM ModifierString WHERE String LIKE #{row}'";

        puts Database.new
      end
    end

end