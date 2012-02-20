class Pispersonel < ActiveRecord::Base
  set_table_name "pispersonel"
  belongs_to :cprefix,
    :class_name => "Cprefix",
    :foreign_key => "pcode"
  
  def full_name
    prefix = (pcode.to_s == "")? "" : begin Cprefix.find(:all,:conditions => "pcode = #{pcode}")[0].longprefix rescue "" end
    ["#{prefix}#{fname}", lname].compact.join(' ').strip
  end
end
