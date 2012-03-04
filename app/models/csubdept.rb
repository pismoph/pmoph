# coding: utf-8
class Csubdept < ActiveRecord::Base
  set_table_name "csubdept"
  set_primary_key "sdcode"
  has_many :pisj18s,
    :class_name => "Pisj18",
    :foreign_key => "sdcode"
  
  def full_name
    str_address = ""
    if provcode.to_s.strip != ""
      str_address = "จ."+Cprovince.where(:provcode => provcode)[0].provname.to_s
    end
    if provcode.to_s.strip != "" and amcode.to_s.strip != ""
      str_address += " อ."+Camphur.where(:provcode => provcode,:amcode => amcode)[0].amname.to_s
    end
    if provcode.to_s.strip != "" and amcode.to_s.strip != "" and tmcode.to_s.strip != ""
      str_address += " ต."+Ctumbon.where(:provcode => provcode,:amcode => amcode,:tmcode => tmcode)[0].tmname.to_s
    end
    [longpre,subdeptname,str_address].join(" ").strip
  end
  
  def full_shortpre_name
    str_address = ""
    if provcode.to_s.strip != ""
      str_address = "จ."+Cprovince.where(:provcode => provcode)[0].provname.to_s
    end
    if provcode.to_s.strip != "" and amcode.to_s.strip != ""
      str_address += " อ."+Camphur.where(:provcode => provcode,:amcode => amcode)[0].amname.to_s
    end
    if provcode.to_s.strip != "" and amcode.to_s.strip != "" and tmcode.to_s.strip != ""
      str_address += " ต."+Ctumbon.where(:provcode => provcode,:amcode => amcode,:tmcode => tmcode)[0].tmname.to_s
    end
    [shortpre,subdeptname,str_address].join(" ").strip
  end
  
  def short_name
    [longpre,subdeptname].join(" ").strip
  end
end
