class WallListController < UIViewController
  extend IB
  include BubbleWrap

  attr_accessor :walls

  outlet :wall_list_table
  outlet :server, UITextField
  outlet :topic, UITextField

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
  end

  def viewWillAppear(animated)
    $wlc = self
    refresh_walls
    super(animated)
  end

  def refresh(sender)
    refresh_walls
  end

  def new_wall(sender)
    if topic.text != ""
      HTTP.get("http://#{server.text}/new?topic=#{topic.text}") do |resp|
        break if resp.body.nil?
        @wall = JSON.parse(resp.body.to_str)
        refresh_walls
      end
    end
  end

  def refresh_walls
    HTTP.get("http://#{server.text}/list") do |resp|
      break if resp.body.nil?
      @walls = JSON.parse(resp.body.to_str)
      @wall_list_table.reloadData
    end
  end

  def load_wall(sender)
    HTTP.get("http://#{server.text}/wall_messages?wall_id=#{$wall_id}") do |resp|
      break if resp.body.nil?
      $messages = JSON.parse(resp.body.to_str)
      $app.switch_to_vc($app.load_vc("MessageList"))
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    $wall_id = @walls[indexPath.row]["id"]
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("GlobalChat2")

    if not cell
      cell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleDefault, reuseIdentifier:'GlobalChat2'
    end

    cell.setText @walls[indexPath.row]['topic']

    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @walls.nil? ? 0 : @walls.size
  end

end