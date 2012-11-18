require 'spec_helper'

describe StripeEvent::WebhookController do
  before do
    @base_params = {
      :type => StripeEvent::TYPE_LIST.sample,
      :use_route => :stripe_event
    }
  end

  context "with valid event data" do
    before do
      stub_event('evt_charge_succeeded')
    end

    it "is successful" do
      post :event, @base_params.merge(:id => 'evt_charge_succeeded')
      expect(response).to be_success
    end
  end

  context "with invalid event data" do
    before do
      stub_event('evt_invalid_id', 404)
    end

    it "denies access" do
      post :event, @base_params.merge(:id => 'evt_invalid_id')
      expect(response.code).to eq '401'
    end
  end

  context "with a custom event retriever" do
    before do
      StripeEvent.event_retriever = Proc.new { |params| params }
    end

    it "is successful" do
      post :event, @base_params.merge(:id => '1')
      expect(response).to be_success
    end

    it "fails without an event type" do
      expect {
        post :event, @base_params.merge(:id => '1', :type => nil)
      }.to raise_error(StripeEvent::InvalidEventTypeError)
    end
  end

  context "failed http basic authentication" do
    before do
      StripeEvent.event_retriever = Proc.new { |params| params }
      StripeEvent.authenticate_with_http_basic = Proc.new do |username, password|
        username == 'foo' && password == 'bar'
      end
    end

    it "denies access" do
      post :event, @base_params.merge(:id => '1')
      expect(response.code).to eq '401'
    end
  end

  context "successful http basic authentication" do
    before do
      StripeEvent.event_retriever = Proc.new { |params| params }
      StripeEvent.authenticate_with_http_basic = Proc.new do |username, password|
        username == 'Jim' && password == 'Dandy!'
      end
    end

    it "is successful" do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('Jim', 'Dandy!')
      post :event, @base_params.merge(:id => '1')
      expect(response).to be_success
    end
  end
end
