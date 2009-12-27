 class EPDQResponseParser
    
    attr_accessor :result
    
    def initialize(response)
      @result = parse(response)
    end
    def parse(response_string)
        response = {}
        #print response_string
        xml = REXML::Document.new(response_string)
        xml = REXML::XPath.first(xml, "/EngineDocList/EngineDoc")
        max_sev_node = REXML::XPath.first(xml, 'MessageList/MaxSev')
        response[:error_response] = {}
        response[:error_response][:max_sev]  =  (max_sev_node.text.to_i || 0)
        
        if response[:error_response][:max_sev]>0
          parse_errors(REXML::XPath.first(xml, 'MessageList'), response[:error_response])
        end
        
        response[:card_proc_response] = parse_card_proc_response(REXML::XPath.first(xml, 'OrderFormDoc/Transaction/CardProcResp'))
        return response
    end
    def parse_errors(xml, error_response)
      return unless not xml.nil?
      error_response[:messages] = []
      xml.elements.each("Message/") do |node|
        message = REXML::XPath.first(node, "Text/").text
        sev = REXML::XPath.first(node, "Sev/").text
        error_response[:messages].push({:message => message, :sev => sev})
      end
  end
  def parse_card_proc_response(xml)
    card_proc_response = {}
    return card_proc_response unless not xml.nil?
    xml.elements.each do |node| 
        els = {
          node.name.to_sym => node.text
        }
        card_proc_response = card_proc_response.merge(els)
    end
    return card_proc_response
  end
 end