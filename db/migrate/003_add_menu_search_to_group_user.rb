class AddMenuSearchToGroupUser < ActiveRecord::Migration
  def self.up
    add_column :group_users, :menu_search, :string
  end

  def self.down
    remove_column :group_users, :menu_search
  end
end
