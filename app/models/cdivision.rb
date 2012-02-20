class Cdivision < ActiveRecord::Base
  set_table_name "cdivision"
  set_primary_key "dcode"
  
  def full_name
    [prefix,division].join(" ").strip
  end
end
