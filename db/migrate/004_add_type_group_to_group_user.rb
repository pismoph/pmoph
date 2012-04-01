class AddTypeGroupToGroupUser < ActiveRecord::Migration
  def self.up
    add_column :group_users, :type_group, :string# "1=รพศ/รพท,2=สสจ"
  end

  def self.down
    remove_column :group_users, :type_group
  end
end
