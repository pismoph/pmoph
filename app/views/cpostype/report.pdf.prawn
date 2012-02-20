pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.ptcode.to_i,
	records.ptname,
	records.shortmn
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","ประเภท","คำย่อ"],
#	:align 				=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left },
#	:position			=> :center


pdf.table([["รหัส","ประเภท","คำย่อ"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


