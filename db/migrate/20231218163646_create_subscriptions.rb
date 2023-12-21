# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.text 'stripe_id'
      t.text 'state'
      t.timestamps
    end
  end
end
