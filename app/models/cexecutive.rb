class Cexecutive < ActiveRecord::Base
  set_table_name "cexecutive"
  set_primary_key "excode"
  
  def full_name
    [shortpre,exname].join("").strip
  end
end
