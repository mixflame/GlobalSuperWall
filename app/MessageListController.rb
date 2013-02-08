class MessageListController < UIViewController

  extend IB
  include BubbleWrap

  outlet :messages_view, UITextView
  outlet :message, UITextField

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end


  def viewWillAppear(animated)
    $wlc = self
    load_messages
    super(animated)
  end

  def load_messages
    messages = ""
    $messages.each do |m|
      messages += "#{m['message']}\n"
    end
    messages_view.text = messages
  end

  def new_message(sender)
    message_text = message.text
    if author_text != "" && message_text != ""
      HTTP.get("http://#{server.text}/add_message?wall_id=#{$wall_id}&message=#{message_text}") do |resp|
        break if resp.body.nil?
        @message = JSON.parse(resp.body.to_str)
        $messages << @message
        load_messages
      end
    end
  end

end