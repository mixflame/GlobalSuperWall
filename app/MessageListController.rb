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
    if message_text != ""
      HTTP.get("http://#{$server}/add_message?wall_id=#{$wall_id}&message=#{message_text}") do |resp|
        break if resp.body.nil?
        message.text = ""
        @message = JSON.parse(resp.body.to_str)
        $messages << @message
        load_messages
      end
    end
  end

  def go_back(sender)
    $app.switch_to_vc($app.load_vc("WallList"))
  end

end