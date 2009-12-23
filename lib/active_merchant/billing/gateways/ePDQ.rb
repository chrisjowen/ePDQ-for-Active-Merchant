require File.dirname(__FILE__) + '/ePDQ/epdq_response_parser'


module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EPDQGateway < Gateway
      
      URL = 'http://www.xxxxxxxx.com'
      
      TEST_URL = 'https://example.com/test'
      LIVE_URL = 'https://example.com/live'
      
      DOC_VERSION = '1.0'
            
      MODES = {
        :Production => 'P', 
        :Test  => 'T', 
        :SimulateNoVal => 'N',
        :SimulateWithVal => 'Y',
        :SimulateRandVal => 'R',
        :FraudShieldSimulateNoVal => 'FN',
        :FraudShieldSimulateWithVal => 'FY',
      }
      
      #TODO: Work out which cards are supported - Full list at: 
      #(Page 159) http://www.barclaycard.co.uk/business/documents/pdfs/DHR_OrderFormDoc_5.9.pdf
      CARDS = {
        :visa => 1,
        :master => 2,
        :discover => 3,
        :american_express => 8
      }
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US', 'UK']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.barclaycard.co.uk/'
      
      # The name of the gateway
      self.display_name = 'ePDQ'
      
      def initialize(options = {})
        requires!(options, :user, :password, :clientId)
        @options = options
        super
      end  

      def purchase(money, creditcard, options = {})
        request = build_purchase_or_authorization_request("Auth", money, creditcard, options) 
        commit(request)
      end                       
     
      def authorize(money, credit_card, options = {})
        request = build_purchase_or_authorization_request("PreAuth", money, creditcard, options) 
        commit(request)
      end   
        
      private                       
    #    <User>
    #     <Name>Your Username</Name>
    #     <Password>Your Password</Password>
    #     <ClientId DataType="S32">Your Client Id</ClientId>
    #    </User>
    def build_user_details(xml, options)
       xml.User{
          xml.Name(@options[:user])
          xml.Password(@options[:password])
          xml.ClientId(@options[:clientId], :DataType => "S32")
       }
    end
    #    <Instructions>
    #     <Pipeline>Payment</Pipeline>
    #    </Instructions>
    def build_pipeline_details(xml, options)
      xml.Instructions{
          xml.Pipeline("PAYMENT") #TODO: Not sure where this should come from
      }
    end
    #    <OrderFormDoc>
    #     <Mode>P</Mode>
    #     <Id>Your Order Id</Id>
    #     <Consumer>
    #     <Email>Customer's email address</Email>
    #     <BillTo>
    #       //Billing address details
    #     </BillTo>
    #     <ShipTo>
    #       //Shipping address details
    #     </ShipTo>
    #     <PaymentMech>
    #     <CreditCard>
    #       //Credit card number etc
    #     </CreditCard>
    #     </PaymentMech>
    #     </Consumer>
    #     <Transaction>
    #       //Orde details such as ammout etc
    #     </Transaction>
    #    </OrderFormDoc>
    def build_orderform_details(action, xml, options, money, credit_card)
       xml.OrderFormDoc{
          xml.Mode(MODES[:Test]) #TODO: Not sure where this should come from
        xml.Id(@options[:Id])
        xml.Consumer{
          xml.Email("Email") #TODO: Email
          build_address_details(xml, "BillTo", options[:billing_address] || options[:address] )
          build_address_details(xml, "ShipTo",  options[:shipping_address] || options[:billing_address] || options[:address])
            build_payment_mechanism(xml, credit_card)
            build_transaction_data(action, xml, options, money, credit_card)
          }
       }
    end
    #    <ShipTo>
    #     <Location>
    #       <Address>
    #         <FirstName>Jane</FirstName>
    #         <LastName>Smith</LastName>
    #         <Street1>22 High Street</Street1>
    #         <Street2></Street2>
    #         <Street3></Street3>
    #         <City>Northampton</City>
    #         <StateProv>Northants</StateProv>
    #         <PostalCode>NN1 1NN</PostalCode>
    #         <Country>826</Country>
    #        </Address>
    #     </Location>
    #    </ShipTo>
    def build_address_details(xml, addressType, address)
        if not address.nil? then
            xml.tag!(addressType){
              xml.Location{
                xml.Address{
                  xml.Firstname(address[:name]) 
                  xml.Street1(address[:address1]) unless address[:address1].nil?
                  xml.Street2(address[:address2]) unless address[:address2].nil?
                  xml.Street3(address[:address3]) unless address[:address3].nil?
                  xml.City(address[:city]) unless address[:city].nil?
                  xml.StateProv(address[:state]) unless address[:state].nil?
                  xml.PostalCode(address[:zip]) unless address[:zip].nil?
                }
              }
            }
        end
    end  
    #     <PaymentMech>
    #       <CreditCard>
    #         <Type DataType="S32">1</Type>
    #         <Number>4111111111111111</Number>
    #         <Expires DataType="ExpirationDate" Locale="826">01/10</Expires>
    #         <IssueNum></IssueNum>
    #         <StartDate DataType="StartDate"></StartDate>
    #         <Cvv2Indicator>1</Cvv2Indicator>
    #         <Cvv2Val>999</Cvv2Val>
    #      </CreditCard>
    #     </PaymentMech>
    def build_payment_mechanism(xml, credit_card)
       xml.PaymentMech{
        xml.CreditCard{
          type = credit_card.type
          xml.Type(CARDS[type.to_sym] || 1, :DataType=>"S32")
        xml.Number(credit_card.number)
        xml.Expires("#{credit_card.year}/#{credit_card.month}", :DataType=>"ExpirationDate", :Local=>"826") 
       
        if not credit_card.start_year.nil? or not credit_card.start_month.nil?
          xml.StartDate("#{credit_card.start_year}/#{credit_card.start_month}", :DataType=>"StartDate", :Local=>"826") 
        end
        if not credit_card.issue_number.nil?
          xml.IssueNum(credit_card.issue_number)
        end
        if not credit_card.verification_value.nil?
          xml.Cvv2Indicator("1")
              xml.Cvv2Indicator(credit_card.verification_value)
            end
         }
       }
    end
    #    <Transaction>
    #     <Type>Auth</Type>
    #     <CurrentTotals>
    #       <Totals>
    #        <Total DataType="Money" Currency="826">200</Total>
    #       </Totals>
    #     </CurrentTotals>
    #     <CardholderPresentCode DataType="S32"></CardholderPresentCode>
    #     <PayerSecurityLevel DataType="S32"></PayerSecurityLevel>
    #     <PayerAuthenticationCode></PayerAuthenticationCode>
    #     <PayerTxnId></PayerTxnId>
    #    </Transaction>
     def build_transaction_data(action, xml, options, money, credit_card)
        xml.Transaction{
          xml.Type(action)
          xml.CurrentTotals{
            xml.Totals{
              xml.Total(money, :DataType=>"Money", :Currency=>"826") #TODO: Currency codes to be mapped agains Hash
             
              #TODO: This information comes from 3d Secure/Authurization process. BUT, not sure when this happens
              xml.PayerSecurityLevel(:DataType=>"S32")
              xml.PayerAuthenticationCode()
              xml.PayerTxnId()
            }
          }
        }
     end
     
     def build_purchase_or_authorization_request(action, money, credit_card, options)        
        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'EngineDocList' do
          xml.DocVersion(DOC_VERSION)
          xml.EngineDoc {
            xml.ContentType("OrderFormDoc")
            build_user_details(xml, options)
            build_pipeline_details(xml, options)
            build_orderform_details(action, xml, options, money, credit_card)
          }
        end
        xml.target!
     end
      
     def parse(response)
        EPDQResponseParser.new(response)
     end     
      
     def commit(request)
        response = parse(ssl_post(URL, request))
#        Response.new(response[:result] == "00", message_from(response), response,
#          :test => response[:message] =~ /\[ test system \]/,
#          :authorization => response[:authcode],
#          :cvv_result => response[:cvnresult]
#        ) 
     end

    end
  end
end

