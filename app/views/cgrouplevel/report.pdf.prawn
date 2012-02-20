pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.ccode.to_i,
	records.cname,
	records.scname,
	records.minsal1.to_f,
	records.maxsal1.to_f,
	records.gname,
	records.clname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","ชื่อ","คำย่อ","เงินเดือนขั้นต่ำ","เงินเดือนขั้นสูง","กลุ่ม","ประเภท"],
#	:align 			=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left, 4 => :right, 5 => :right, 6 => :left, 7 => :left },
#	:position			=> :center

pdf.table([["รหัส","ชื่อ","คำย่อ","เงินเดือนขั้นต่ำ","เงินเดือนขั้นสูง","กลุ่ม","ประเภท"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


