pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.amcode.to_i,
	records.shortpre,
	records.longpre,
	records.amname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","ชื่อย่อคำนำหน้า","คำนำหน้า","อำเภอ"],
#	:align 				=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left , 4 => :left },
#	:position			=> :center
pdf.text 'รายงานอำเภอภายใน จังหวัด'+@province, :align => :center
pdf.move_down(20)
pdf.table([["รหัส","ชื่อย่อคำนำหน้า","คำนำหน้า","อำเภอ"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


