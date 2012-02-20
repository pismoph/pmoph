pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |r|
  [
	r[:posname],
        r[:cname],
        r[:n],
	r[:n_empty]
  ]
end

pdf.table([["ตำแหน่งสายงาน","ระดับ","จำนวนที่ครองตำแหน่ง","จำนวนที่ตำแหน่งว่าง"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end
