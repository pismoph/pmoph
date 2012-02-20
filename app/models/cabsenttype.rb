class Cabsenttype < ActiveRecord::Base
  set_table_name "cabsenttype"
  set_primary_key "abcode"
  
  def self.holiday(id)
    rs_person = Pispersonel.find(id)
    rs = Pisabsent.count(:conditions => "id = '#{id}'")
    if rs == 0
      rs_person.vac1oct = 10
      rs_person.totalabsent = 10
      rs_person.save!
    else
      ""
    end
  end
end
#Cabsenttype.holiday('0000000002621')
