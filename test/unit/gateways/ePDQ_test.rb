require 'test_helper'

class EPDQTest < Test::Unit::TestCase
  def setup
    @gateway = EPDQGateway.new(
                 :user => 'login',
                 :password => 'password',
                 :clientId => '123213'
               )

    @credit_card = credit_card
    @amount = 100
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    @gateway.purchase(@amount, @credit_card, @options)
    #assert_instance_of 
    #assert_success response
    
    # Replace with authorization number from the successful response
#    assert_equal '', response.authorization
#    assert response.test?
  end

#  def test_unsuccessful_request
#    @gateway.expects(:ssl_post).returns(failed_purchase_response)
#    
#    assert response = @gateway.purchase(@amount, @credit_card, @options)
#    assert_failure response
#    assert response.test?
#  end

  private

  # Place raw failed response from gateway here
  def failed_purcahse_response
  end

  def successful_purchase_response
    <<-REQUEST
      <?xml version="1.0" encoding="UTF-8"?>
      <EngineDocList>
      <DocVersion DataType="String">1.0</DocVersion>
      <EngineDoc>
      <ContentType DataType="String">OrderFormDoc</ContentType>
      <DocumentId DataType="String">445029fd-1a8e-3000-0005-0003ba65c10f</DocumentId>
      <Instructions>
      <Pipeline DataType="String">Payment</Pipeline>
      </Instructions>
      <MessageList>
      <MaxSev DataType="S32">1</MaxSev>
      <Message>
      <Sev DataType="S32"></Sev>
      <Text DataType="String"></Text>
      </Message>
      </MessageList>
      <OrderFormDoc>
      <Consumer>
      <BillTo>
      <Location>
      <Address>
      <City DataType="String">Northampton</City>
      <Country DataType="String">826</Country>
      <FirstName DataType="String">John</FirstName>
      <LastName DataType="String">Smith</LastName>
      <PostalCode DataType="String">NN11NN</PostalCode>
      <StateProv DataType="String">Northants</StateProv>
      <Street1 DataType="String">1 High Street</Street1>
      </Address>
      </Location>
      </BillTo>
      <Email DataType="String">epdq@barclaycard.co.uk</Email>
      <PaymentMech>
      <CreditCard>
      <Cvv2Indicator DataType="String">1</Cvv2Indicator>
      <Cvv2Val DataType="String">999</Cvv2Val>
      <Expires DataType="ExpirationDate">01/10</Expires>
      <Number DataType="String">4111111111111111</Number>
      <Type DataType="S32">1</Type>
      </CreditCard>
      <Type DataType="String">CreditCard</Type>
      </PaymentMech>
      <ShipTo>
      <Location>
      <Address>
      <City DataType="String">Northampton</City>
      <Country DataType="String">826</Country>
      <FirstName DataType="String">Jane</FirstName>
      <LastName DataType="String">Smith</LastName>
      <PostalCode DataType="String">NN1 1NN</PostalCode>
      <StateProv DataType="String">Northants</StateProv>
      <Street1 DataType="String">22 High Street</Street1>
      </Address>
      </Location>
      </ShipTo>
      </Consumer>
      <DateTime DataType="DateTime">1146133410918</DateTime>
      <FraudInfo>
      <FraudResultCode DataType="S32">0</FraudResultCode>
      <TotalScore DataType="Numeric" Precision="0">0</TotalScore>
      </FraudInfo>
      <GroupId DataType="String">445029fd-1a8f-3000-0005-0003ba65c10f</GroupId>
      <Id DataType="String">445029fd-1a8f-3000-0005-0003ba65c10f</Id>
      <Mode DataType="String">P</Mode>
      <Transaction>
      <AuthCode DataType="String">611287</AuthCode>
      <CardProcResp>
      <AvsDisplay DataType="String">YY</AvsDisplay>
      <AvsRespCode DataType="String">EX</AvsRespCode>
      <CcErrCode DataType="S32">1</CcErrCode>
      <CcReturnMsg DataType="String">Approved</CcReturnMsg>
      <Cvv2Resp DataType="String">1</Cvv2Resp>
      <ProcAvsRespCode DataType="String">44</ProcAvsRespCode>
      <ProcReturnCode DataType="String">1</ProcReturnCode>
      <ProcReturnMsg DataType="String">Approved</ProcReturnMsg>
      <Status DataType="String">1</Status>
      </CardProcResp>
      <CardholderPresentCode DataType="S32">7</CardholderPresentCode>
      <CurrentTotals>
      <Totals>
      <Total DataType="Money" Currency="826">200</Total>
      </Totals>
      </CurrentTotals>
      <Id DataType="String">445029fd-1a90-3000-0005-0003ba65c10f</Id>
      <InputEnvironment DataType="S32">4</InputEnvironment>
      <SecurityIndicator DataType="S32">7</SecurityIndicator>
      <TerminalInputCapability DataType="S32">1</TerminalInputCapability>
      <Type DataType="String">Auth</Type>
      </Transaction>
      </OrderFormDoc>
      <User>
      <Alias DataType="String"></Alias>
      <ClientId DataType="S32">Your Client Id</ClientId>
      <EffectiveAlias DataType="String"></EffectiveAlias>
      <EffectiveClientId DataType="S32"></EffectiveClientId>
      <Name DataType="String">Your Username</Name>
      <Password DataType="String">Your Password</Password>
      </User>
      </EngineDoc>
      <TimeIn DataType="DateTime">1146133410910</TimeIn>
      <TimeOut DataType="DateTime">1146133411332</TimeOut>
      </EngineDocList>
    REQUEST
  end

end
