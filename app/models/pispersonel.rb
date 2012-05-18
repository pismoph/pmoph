# coding: utf-8
class Pispersonel < ActiveRecord::Base
  set_table_name "pispersonel"
  belongs_to :cprefix,
    :class_name => "Cprefix",
    :foreign_key => "pcode"
  
  def full_name
    prefix = (pcode.to_s == "")? "" : begin Cprefix.find(:all,:conditions => "pcode = #{pcode}")[0].longprefix rescue "" end
    ["#{prefix}#{fname}", lname].compact.join(' ').strip
  end
  
  def sex_name
    case self.sex.to_s
    when '1' then "ชาย"
    when '2' then "หญิง"
    else ""
    end
  end
end
