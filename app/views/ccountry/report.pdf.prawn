pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.cocode.to_i,
	records.coname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสประเทศ","ชื่อประเทศ"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสประเทศ","ชื่อประเทศ"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


