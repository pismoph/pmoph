pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.pcode.to_i,
	records.prefix,
	records.longprefix
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัส","คำย่อคำนำหน้า","คำนำหน้า"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัส","คำย่อคำนำหน้า","คำนำหน้า"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


