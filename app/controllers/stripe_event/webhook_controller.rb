module StripeEvent
  class WebhookController < ActionController::Base
    before_filter do
      if StripeEvent.authenticate_with_http_basic.present?
        authenticate_with_http_basic(&StripeEvent.authenticate_with_http_basic) || head(:unauthorized)
      end
    end

    def event
      event = StripeEvent.event_retriever.call(params)
      StripeEvent.publish(event)
      head :ok
    rescue Stripe::StripeError
      head :unauthorized
    end
  end
end
