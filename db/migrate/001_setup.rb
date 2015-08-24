class Setup < ActiveRecord::Migration
  def self.up
    create_table 'clients', force: true do |t|
      t.string 'name', default: '', null: false
      t.string 'ip', default: '', null: false
      t.timestamps null: false
    end

    create_table 'tasks', force: true do |t|
      t.timestamp 'date'
      t.timestamp 'start_time'
      t.timestamp 'finished_time'
      t.timestamp 'duration'
      t.text 'data', default: '', null: false
      t.integer 'time', default: 0, null: false
      t.boolean 'completed', default: false, null: false
      t.text 'result'
      t.belongs_to :client
      t.timestamps null: false
    end

    add_index 'tasks', ['client_id'], name: "tasks_client_id"
  end

  def self.down
    drop_table :clients
    drop_table :tasks
  end
end