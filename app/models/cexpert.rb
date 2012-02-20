class Cexpert < ActiveRecord::Base
  set_table_name "cexpert"
  set_primary_key "epcode"
  
  def full_name
    [prename,expert].join(" ").strip
  end
end
