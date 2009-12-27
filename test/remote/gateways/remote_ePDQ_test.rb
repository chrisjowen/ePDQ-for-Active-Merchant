require 'test_helper'

class RemoteEPDQTest < Test::Unit::TestCase
  

  def setup
    @gateway = EPDQGateway.new(fixtures(:epdq))
    
    @amount = 100
    @credit_card = credit_card('4000100011112224')
    @declined_card = credit_card('4000300011112220')
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end
  
  def test_something
    response = @gateway.purchase(@amount, @credit_card, @options)
    print response.inspect
  end

 
end
