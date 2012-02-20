pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.gcode.to_i,
	records.gname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","กลุ่ม"],
#	:align 				=> { 0 => :center, 1 => :left, 2 => :left },
#	:position			=> :center


pdf.table([["รหัส","กลุ่ม"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end