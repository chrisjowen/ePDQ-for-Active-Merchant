 class EPDQResponseParser
    def initialize(response)
        parse(response)
    end
    def parse(response_string)
        response = {}
        xml = REXML::Document.new(response_string)
        xml = REXML::XPath.first(xml, "/EngineDocList/EngineDoc")
        max_sev_node = REXML::XPath.first(xml, 'MessageList/MaxSev')
        response[:error_response] = {}
        response[:error_response][:max_sev]  =  (max_sev_node.text.to_i || 0)
        
        if response[:error_response][:max_sev]>0
          parse_errors(REXML::XPath.first(xml, 'MessageList'), response[:error_response])
        end
        
        response[:card_proc_response] = {}
        parse_card_proc_response(REXML::XPath.first(xml, 'OrderFormDoc/Transaction/CardProcResp'), response[:card_proc_response])
      
      print response[:card_proc_response].inspect
    end
    def parse_errors(xml, error_response)
      error_response[:messages] = []
      xml.elements.each("Message/") do |node|
        message = REXML::XPath.first(node, "Text/").text
        sev = REXML::XPath.first(node, "Sev/").text
        error_response[:messages].push({:message => message, :sev => sev})
      end
  end
  def parse_card_proc_response(xml, card_proc_response)
      xml.elements.each do |node| 
          print node.name.to_sym
          {
            node.name.to_sym => node.text
          }.update(card_proc_response)
      end
  end
 end