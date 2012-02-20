pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.mcode.to_i,
	records.minname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสกระทรวง","ชื่อกระทรวง"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสกระทรวง","ชื่อกระทรวง"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


