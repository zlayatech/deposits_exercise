class Tradeline < ApplicationRecord
  has_many :deposits, dependent: :restrict_with_error
end
