pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.pncode,
	records.pnname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=>      ["รหัส","การลงโทษทางวินัย"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table(  [["รหัส","การลงโทษทางวินัย"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end