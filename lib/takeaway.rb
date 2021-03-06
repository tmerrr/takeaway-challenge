require 'sinatra'
require 'twilio-ruby'
require_relative 'twilio'
require_relative 'order'
require_relative 'dish'
require_relative 'menu'
require_relative 'methods'

class Takeaway
  attr_reader :order_history

  def initialize(menu = Menu.new(curry_menu), order_class = Order)
    @menu           = menu
    @order_class    = order_class
    @order_history  = []
    new_order
  end

  def view_menu
    @menu.view_full_menu
  end

  def choose(option, dish_name, quantity = 1)
    raise 'InvalidQuantity' if quantity < 1
    selection = @menu.select_dish(dish_name, option)
    quantity.times { @order.add(selection) }
  end

  def view_order
    @order.view
  end

  def view_order_total
    "£#{@order.total}"
  end

  def complete_order
    @order_history << @order
    send_text
    new_order
  end

  private
  def new_order
    @order = @order_class.new
  end

  def send_text
    client = Twilio::REST::Client.new account_sid, auth_token

    from = twilio_number

    client.messages.create(
      from: from,
      to: my_number,
      body: "Your order has been confirmed"
    )

    puts "message sent"

  end

end
