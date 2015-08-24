require 'eventmachine'
require 'em-websocket'
require 'active_record'
require 'active_support'
require_relative 'manager'
require 'json'

class ShedulerServer < EventMachine::WebSocket::Connection
  def initialize(opts={})
    super
    onopen { on_open }
    onmessage { |message| on_message(message) }
    onclose { on_close }
  end

  def on_open
    Manager.add_client self
  end

  def on_message(message)
    begin
      data = JSON(message).symbolize_keys
      if data[:type] == 'new'
        Manager.find_or_save_client(data)
      elsif data[:type] == 'task_new'
        task = Manager.create_task data
        if task
          Manager.send_task task, self
        end
      elsif data[:type] == 'online'
        task = Manager.find_client_next_task data[:ip]
        if task
          Manager.send_task task, self
        end
      elsif data[:type] == 'result'
        task = Manager.add_data_to_task data
        Manager.update_tasks_on_web(task)
      elsif data[:type] == 'client_all'
        Manager.send_all_clients self
      elsif data[:type] == 'task_all'
        Manager.send_all_tasks self
      elsif data[:type] == 'change_ip'
        Manager.change_ip data
      elsif data[:type] == 'delete_client'
        Manager.delete_client! data
      elsif data[:type] == 'delete_task'
        Manager.delete_task! data
      else
        puts 'wrong incoming data'
      end
    # rescue
    #  puts 'wrong incoming data or error'
    end
  end

  def on_close
    Manager.remove_client self
  end
end
# start EventMachine loop and run server on ip address and port
EM.run do

  options = Hash[*ARGV]

  IP = options['-i']
  PORT = options['-p']

  EM.start_server IP, PORT, ShedulerServer
  p "==  Server is up on #{IP}:#{PORT} and ready"
end