# frozen_string_literal: true

module Webhooks
  module Stripe
    module_function

    SUPPORTED_STRIPE_EVENTS = %w[customer.subscription.created invoice.paid customer.subscription.deleted].freeze

    def process_event(event)
      raise StandardError, "Unsupported stripe event: #{event.inspect}" unless SUPPORTED_STRIPE_EVENTS.include?(event.type)

      case event.type
      when 'customer.subscription.created'
        handle_subscription_creation(event)
      when 'invoice.paid'
        handle_invoice_paid(event)
      when 'customer.subscription.deleted'
        handle_subscription_deleted(event)
      end
    end

    def handle_subscription_creation(event)
      Subscription.create(stripe_id: event.data.object.id)
    rescue StandardError => e
      Rails.logger.error(e.message)
    end

    def handle_invoice_paid(event)
      subscription = Subscription.find_by(stripe_id: event.data.object.subscription)
      raise StandardError("Unable to find subscription with stripe id: #{event.object.id}") unless subscription

      begin
        subscription.pay!
      rescue AASM::InvalidTransition => e
        Rails.logger.error("Unable to change state to 'paid':  #{e.message}")
      end
    end

    def handle_subscription_deleted(event)
      subscription = Subscription.find_by(stripe_id: event.data.object.id)
      raise StandardError("Unable to find subscription with stripe id: #{event.object.id}") unless subscription

      begin
        subscription.cancel!
      rescue AASM::InvalidTransition => e
        Rails.logger.error("Unable to change state to 'canceled'.  #{e.message}")
      end
    end
  end
end
