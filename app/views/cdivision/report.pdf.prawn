pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.dcode.to_i,
	records.prefix,
	records.division
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสกอง","คำนำหน้า","ชื่อกอง"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสกอง","คำนำหน้า","ชื่อกอง"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


