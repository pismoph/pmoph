class Cposition < ActiveRecord::Base
  set_table_name "cposition"
  set_primary_key "poscode"
  has_many :pisj18s,
    :class_name => "Pisj18",
    :foreign_key => "poscode"
  
  def full_name
    [longpre,posname].join(" ").strip
  end
end
