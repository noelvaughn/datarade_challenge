# frozen_string_literal: true

class Subscription < ApplicationRecord
  include AASM

  aasm(column: :state) do
    state :unpaid, initial: true
    state :paid, :canceled

    event :pay do
      transitions from: :unpaid, to: :paid
    end

    event :cancel do
      transitions from: :paid, to: :canceled
    end
  end
end
