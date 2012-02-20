pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.sdcode.to_s,
	records.shortpre.to_s,    
	records.longpre.to_s,  
	records.subdeptname.to_s,        
	records.sdgname.to_s,
	records.trlname.to_s,    
	records.location.to_s,     
	records.aname.to_s, 
	records.provname.to_s,       
	records.amname.to_s,  
	records.tmname.to_s,    
	records.finname.to_s
  ]
end

pdf.font_size(8) do
  pdf.table([["รหัสหน่วยงาน","ชื่อย่อคำนำหน้า","คำนำหน้า","หน่วยงาน","ประเภทหน่วยงาน","Training","ส่วน","เขต","จังหวัด","อำเภอ","ตำบล" ,"คลังเบิกจ่าย"], *(records)], :header => true,:width => 720 ) do
    row(0).style :align => :center   
  end
end


