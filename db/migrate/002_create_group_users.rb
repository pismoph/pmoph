class CreateGroupUsers < ActiveRecord::Migration
  def self.up
    create_table :group_users do |t|
      t.string :name
      t.string :menu_code
      t.string :menu_manage_user
      t.string :menu_personal_info
      t.string :menu_report
      t.string :menu_command
      t.string :admin
      t.string :mcode
      t.string :deptcode
      t.string :dcode
      t.string :sdcode
      t.string :seccode
      t.string :jobcode
      t.timestamps
    end
  end

  def self.down
    drop_table :group_users
  end
end
