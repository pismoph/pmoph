class AddMenuDetailPersonalInfoToGroupUser < ActiveRecord::Migration
  def self.up
    add_column :group_users, :menu_pisj18, :string
    add_column :group_users, :menu_perform_now, :string
    add_column :group_users, :menu_pisposhis, :string
    add_column :group_users, :menu_pispersonel, :string
    add_column :group_users, :menu_piseducation, :string
    add_column :group_users, :menu_pisabsent, :string
    add_column :group_users, :menu_pistrain, :string
    add_column :group_users, :menu_pisinsig, :string
    add_column :group_users, :menu_pispunish, :string
  end

  def self.down
    remove_column :group_users, :menu_pisj18
    remove_column :group_users, :menu_perform_now
    remove_column :group_users, :menu_pisposhis
    remove_column :group_users, :menu_pispersonel
    remove_column :group_users, :menu_piseducation
    remove_column :group_users, :menu_pisabsent
    remove_column :group_users, :menu_pistrain
    remove_column :group_users, :menu_pisinsig
    remove_column :group_users, :menu_pispunish
  end
end
