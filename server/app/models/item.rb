class Item < ApplicationRecord
  self.table_name  = 'Item'
  self.primary_key = 'ItemID'

  has_many :item_modifiers, foreign_key: 'ItemID'

  include ItemParser
end
