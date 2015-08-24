$ ->
  # Need to improve security
  password = prompt("Input password for access. Default password is 'admin'")
  if password == 'admin'
    # Need to reconfigure if server start not on default ip and port
    client = new WebSocket("ws://0.0.0.0:8080")
    # get data on open connection
    client.onopen = ->
      console.log('Connected')
      client.send JSON.stringify(type: 'client_all')
      client.send JSON.stringify(type: 'task_all')
    # parse message and build interface
    client.onmessage = (message) ->
      data = JSON.parse message.data
      if data.type == 'client'
        $('.clients').append "<br><div id=client_#{ data.client_id }> Client name: #{ data.name }, ip: #{ data.ip } <button id=delete_client_#{ data.client_id }>Delete client</button></div>"
        $("#client_#{data.client_id}").append "<div><input id=commands_for_task_#{ data.client_id } type='text' placeholder='Input commands'></input><input id=date_for_task_#{ data.client_id } type='text' placeholder='Select for Date'></input><input id=time_for_task_#{ data.client_id } type='text'></input><button id=send_task_#{ data.client_id }>Create</button></div><br>"
        $("#date_for_task_#{ data.client_id }").datepicker()
        # $("#date_for_task_#{ data.client_id }").mask("99/99/2099",{placeholder:"12/31/2015"})
        $("#time_for_task_#{ data.client_id }").mask("99:99",{placeholder:"24:00"})
        button_send_task = $("#send_task_#{ data.client_id }")
        button_send_task.click ->
          date = $("#date_for_task_#{ data.client_id }").val()
          time = $("#time_for_task_#{ data.client_id }").val()
          command = $("#commands_for_task_#{ data.client_id }").val()
          out_message = JSON.stringify(type: 'task_new', data: command, date: date, time: time, client_id: data.client_id )
          client.send out_message
        $("#delete_client_#{ data.client_id }").click ->
          respond = prompt("Are you sure? Type 'delete' for delete client.")
          if respond == 'delete'
            client.send JSON.stringify(type: 'delete_client', client_id: data.client_id )
            $("#client_#{ data.client_id }").remove()
      else if data.type == 'task'
        $("#client_#{ data.client_id }").append "<div id=task_#{ data.task_id }> Task time: #{ data.date }, commands: #{ data.data }, completed: #{ data.completed }, result: #{ data.result }, start time: #{ data.start_time }, finished time: #{ data.finished_time }, duration: #{ data.duration } <button id=delete_task_#{ data.task_id }>Delete task</button></div>"
        button_delete_on_click data
      else if data.type == 'task_update'
        $("#task_#{ data.task_id }").remove()
        $("#client_#{ data.client_id }").append "<div id=task_#{ data.task_id }> Task time: #{ data.date }, commands: #{ data.data }, completed: #{ data.completed }, result: #{ data.result }, start time: #{ data.start_time }, finished time: #{ data.finished_time }, duration: #{ data.duration } <button id=delete_task_#{ data.task_id }>Delete task</button></div>"
        button_delete_on_click data
  else
    alert "Wrong password"
  button_delete_on_click = (data) ->
    button_delete_task = $("#delete_task_#{ data.task_id }")
    button_delete_task.click ->
      respond = prompt("Are you sure? Type 'delete' for delete task.")
      if respond == 'delete'
        client.send JSON.stringify(type: 'delete_task', task_id: data.task_id )
        $("#task_#{ data.task_id }").remove()