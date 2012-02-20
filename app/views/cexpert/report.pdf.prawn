pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.epcode.to_i,
	records.prename,
	records.expert
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 			=> ["รหัส","คำนำหน้า","ความเชี่ยวชาญ"],
#	:align 				=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left },
#	:position			=> :center

pdf.table([["รหัส","คำนำหน้า","ความเชี่ยวชาญ"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


