pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.seccode.to_i,
	records.shortname,
	records.secname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสฝ่าย/กลุ่มงาน","คำนำหน้า","ชื่อฝ่าย/กลุ่มงาน"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสฝ่าย/กลุ่มงาน","คำนำหน้า","ชื่อฝ่าย/กลุ่มงาน"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


