# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  protect_from_forgery except: :webhook

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = parse_stripe_event(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])
    # TODO: Handle duplicate events by saving event
    handle_stripe_event(event)
    head :ok
  end

  private

  def parse_stripe_event(payload, sig_header, endpoint_secret)
    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "Unable to parse event: #{e.message}"
      return head(:bad_request)
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Error verifying webhook signature: #{e.message}"
      return head(:unauthorized)
    end
    event
  end

  def handle_stripe_event(event)
    if Webhooks::Stripe::SUPPORTED_STRIPE_EVENTS.include?(event.type)
      Webhooks::Stripe.process_event(event)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end
  end
end
