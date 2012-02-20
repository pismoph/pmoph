pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.acode.to_i,
	records.aname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสเขต","ชื่อเขต"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสเขต","ชื่อเขต"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


