class Csection < ActiveRecord::Base
  set_table_name "csection"
  set_primary_key "seccode"
  
  def full_name
    [shortname,secname].join(" ").strip
  end
end
