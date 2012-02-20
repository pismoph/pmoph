pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.dccode.to_i,
	records.shortname,
	records.dcname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","คำย่อ","เครื่องราชอิสริยาภรณ์"],
#	:align 				=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left },
#	:position			=> :center

pdf.table([["รหัส","คำย่อ","เครื่องราชอิสริยาภรณ์"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


