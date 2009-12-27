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
  
  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(not_enough_privillages_response) 
    response = @gateway.purchase(@amount, @credit_card, @options)

    assert_failure response
    assert_true response.message != ""
  end

  def test_successful_request
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    response = @gateway.purchase(@amount, @credit_card, @options)
        
    assert_success response
  end

  private

  def not_enough_privillages_response
    <<-RESPONSE
    <?xml version="1.0" encoding="UTF-8"?>
      <EngineDocList>
        <DocVersion DataType="String">1.0</DocVersion>
        <EngineDoc>
          <ContentType DataType="String">OrderFormDoc</ContentType>
          <DocumentId DataType="String">4b3190e4-f3db-3000-002b-00144ff2e45c</DocumentId>
          <Instructions>
            <Pipeline DataType="String">PAYMENT</Pipeline>
          </Instructions>
          <MessageList>
            <MaxSev DataType="S32">6</MaxSev>
            <Message>
              <AdvisedAction DataType="S32">16</AdvisedAction>
              <Audience DataType="String">Merchant</Audience>
              <Component DataType="String">Director</Component>
              <ContextId DataType="String">Director</ContextId>
              <DataState DataType="S32">3</DataState>
              <FileLine DataType="S32">925</FileLine>
              <FileName DataType="String">CcxInput.cpp</FileName>
              <FileTime DataType="String">14:32:10Oct 13 2007</FileTime>
              <ResourceId DataType="S32">7</ResourceId>
              <Sev DataType="S32">6</Sev>
              <Text DataType="String">Insufficient permissions to perform requested operation.</Text>
            </Message>
          </MessageList>
          <OrderFormDoc>
            <Consumer>
              <BillTo>
                <Location>
                  <Address>
                    <City DataType="String">Ottawa</City>
                    <Firstname DataType="String">Jim Smith</Firstname>
                    <PostalCode DataType="String">K1C2N6</PostalCode>
                    <StateProv DataType="String">ON</StateProv>
                    <Street1 DataType="String">1234 My Street</Street1>
                    <Street2 DataType="String">Apt 1</Street2>
                  </Address>
                </Location>
              </BillTo>
              <Email DataType="String">Email</Email>
              <PaymentMech>
                <CreditCard>
                  <Cvv2Indicator DataType="String">1</Cvv2Indicator>
                  <Cvv2Indicator DataType="String">123</Cvv2Indicator>
                  <Expires DataType="ExpirationDate">10/10</Expires>
                  <Number DataType="String">4000100011112224</Number>
                  <Type DataType="S32">1</Type>
                </CreditCard>
              </PaymentMech>
              <ShipTo>
                <Location>
                  <Address>
                    <City DataType="String">Ottawa</City>
                    <Firstname DataType="String">Jim Smith</Firstname>
                    <PostalCode DataType="String">K1C2N6</PostalCode>
                    <StateProv DataType="String">ON</StateProv>
                    <Street1 DataType="String">1234 My Street</Street1>
                    <Street2 DataType="String">Apt 1</Street2>
                  </Address>
                </Location>
              </ShipTo>
              <Transaction>
                <CurrentTotals>
                  <Totals>
                    <PayerAuthenticationCode DataType="String"></PayerAuthenticationCode>
                    <PayerSecurityLevel DataType="S32">0</PayerSecurityLevel>
                    <PayerTxnId DataType="String"></PayerTxnId>
                    <Total DataType="Money" Currency="826">100</Total>
                  </Totals>
                </CurrentTotals>
                <Type DataType="String">Auth</Type>
              </Transaction>
            </Consumer>
            <Id DataType="String"></Id>
            <Mode DataType="String">T</Mode>
          </OrderFormDoc>
          <User>
            <Alias DataType="String">1997</Alias>
            <ClientId DataType="S32">1997</ClientId>
            <EffectiveAlias DataType="String">1997</EffectiveAlias>
            <EffectiveClientId DataType="S32">1997</EffectiveClientId>
            <Name DataType="String">mdeusr</Name>
            <Password DataType="String">XXXXXXX</Password>
          </User>
        </EngineDoc>
        <TimeIn DataType="DateTime">1261915495714</TimeIn>
        <TimeOut DataType="DateTime">1261915495717</TimeOut>
      </EngineDocList>
    RESPONSE
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
      <MaxSev DataType="S32"></MaxSev>
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
