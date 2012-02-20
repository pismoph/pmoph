pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf"
pdf.font_size 7
records = @records.map do |r|
  [
        r[:fname],
        r[:lname],
        r[:posid],
	r[:posname],
        r[:appointdate],
        r[:birthdate],
        r[:retiredate],
        r[:age],
        r[:ageappoint],
        r[:j18_subdept]
  ]
end

pdf.table([["ชื่อ","นามสกุล","ตำแหน่งเลขที่","ตำแหน่ง","วันที่บรรจุ","วันเกิด","วันที่เกษียณ","อายุ","อายุราชการ","หน่วยงานตามจ.18"], *(records)], :header => true,:width => 740 ) do
  row(0).style :align => :center   
end


