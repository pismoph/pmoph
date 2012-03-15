class Cprovince < ActiveRecord::Base
  set_table_name "cprovince"
  set_primary_key "provcode"
  
  def full_name
    [longpre,provname].join("").strip
  end
end
