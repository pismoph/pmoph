class AddProvcodeToGroupUser < ActiveRecord::Migration
  def self.up
    add_column :group_users, :provcode, :string
  end

  def self.down
    remove_column :group_users, :provcode
  end
end
