pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.wrkcode.to_i,
	records.gcode.to_i,
	records.grpcode.to_i,
	records.wrknm,
	records.levels,
	records.minwages.to_f,
	records.maxwages.to_f,
	records.wrkatrb,
	records.note,
	records.numcode.to_i
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัสตำแหน่ง","รหัสกลุ่ม","รหัสหมวด","ชื่อตำแหน่ง","ระดับ","ค่าจ้างขั้นต่ำ","ค่าจ้างขั้นสูง","attribute","หมายเหตุ","รหัสตัวเลข"],
#	:align 				=> { 0 => :center, 1 => :center, 2 => :center, 3 => :left, 4 => :left, 5 => :right, 6 => :right, 7 => :left, 8 => :left, 9 => :center, 10 => :center },
#	:position			=> :center

pdf.table([["รหัสตำแหน่ง","รหัสกลุ่ม","รหัสหมวด","ชื่อตำแหน่ง","ระดับ","ค่าจ้างขั้นต่ำ","ค่าจ้างขั้นสูง","attribute","หมายเหตุ","รหัสตัวเลข"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end
