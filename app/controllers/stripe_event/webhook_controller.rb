module StripeEvent
  class WebhookController < ActionController::Base
    def event
      StripeEvent.instrument(params)
      head :ok
    end
  end
end
