require_relative 'models/client'
require_relative 'models/task'
require 'active_record'
require 'json'

module Manager
  CLIENTS = []
  # choice environment from database config (production, development, test)
  config = Psych.load(File.open 'db/config.yml')
  ActiveRecord::Base.establish_connection(config['development'])

  module_function
  # add connection to array CLIENTS
  def add_client(client)
    CLIENTS.push client
    puts 'new connection opened'
  end
  # remove connection from array CLIENTS
  def remove_client(client)
    CLIENTS.delete client
    puts 'connection closed'
  end
  # search client with ip and create new client if it's new
  def find_or_save_client(data)
    client = Client.where(ip: data[:ip]).first
    Client.create({name: data[:client], ip: data[:ip]}) unless client
  end
  # find all client incompeted tasks and return array with tasks
  def find_client_tasks(ip)
    client = Client.where(ip: ip).first
    if client
      tasks = client.tasks.incompleted
    end
    tasks
  end
  # find client next task, return first one if more then one
  def find_client_next_task(ip)
    tasks = find_client_tasks(ip)
    return unless tasks
    task_list = []
    tasks.each do |task|
      task_list << task if task.date - (DateTime.now + 1.minute) > 0
    end
    task_list.first
  end
  # add result of command to task, get data from client message, return task
  def add_data_to_task(data)
    task = Task.find data[:task_id]
    task.result = data[:result]
    task.start_time = data[:start_time]
    task.finished_time = data[:finished_time]
    task.duration = data[:duration]
    task.completed = true
    task.save
    task
  end
  # send all clients to connected websocket webclient
  def send_all_clients(connection)
    Client.all.each do |client|
      connection.send({ type: 'client', client_id: client.id, name: client.name, ip: client.ip }.to_json)
    end
  end
  # send all tasks to connected websocket webclient
  def send_all_tasks(connection)
    Task.all.each do |task|
      send_task task, connection
    end
  end
  # create task from webclient message, return task if saved or nil if not
  def create_task(message)
    date_time = message[:date] + 't' + message[:time]
    date = DateTime.strptime(date_time, "%m/%d/%Yt%H:%M")
    if date > Time.now
      task = Task.new date: date, data: message[:data], client_id: message[:client_id]
      return nil unless task.save
      task
    end
  end
  # send task to client
  def send_task(task, connection, task_type = 'task')
    connection.send({ type: task_type, task_id: task.id, client_id: task.client_id, data: task.data, date: task.date, completed: task.completed, result: task.result, duration: task.duration, start_time: task.start_time, finished_time: task.finished_time }.to_json)
  end
  # send updated task to web client
  def update_tasks_on_web(task)
    CLIENTS.each do |connection|
      send_task task, connection, 'task_update'
    end
  end
  # change client's ip address
  def change_ip(data)
    client = Client.where(ip: data[:ip_old]).first
    client.ip = data[:ip_new]
    client.save
  end
  # delete client
  def delete_client!(data)
    client = Client.find data[:client_id]
    client.tasks.each do |task|
      task.destroy
    end
    client.destroy
  end
  # delete task
  def delete_task!(data)
    task = Task.find data[:task_id]
    task.destroy
  end

end