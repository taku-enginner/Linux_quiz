class User < ApplicationRecord
  has_many :answers, dependent: :destroy
end
