# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'state transitions' do
    context 'when in default state' do
      let(:subcription) { described_class.new }

      it 'has default state unpaid' do
        expect(subcription).to have_state :unpaid
      end

      it 'can transition from unpaid to paid' do
        expect(subcription).to allow_transition_to(:paid)
      end

      it 'cannot transition from unpaid to canceled' do
        expect(subcription).not_to allow_transition_to(:canceled)
      end
    end

    context 'when in "paid" state' do
      let(:paid_subscription) { described_class.new(state: 'paid') }

      it 'can transition from paid to canceled' do
        expect(paid_subscription).to allow_transition_to(:canceled)
      end

      it 'cannot transition from paid to unpaid' do
        expect(paid_subscription).not_to allow_transition_to(:unpaid)
      end
    end

    context 'when in "canceled" state' do
      let(:canceled_subscription) { described_class.new(state: 'canceled') }

      it 'cannot transition from canceled to paid' do
        expect(canceled_subscription).not_to allow_transition_to(:paid)
      end

      it 'cannot transition from canceled to unpaid' do
        expect(canceled_subscription).not_to allow_transition_to(:unpaid)
      end
    end
  end
end
