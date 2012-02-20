pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.j18code,
	records.j18status
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=>      ["รหัส","สถานะตาม จ.18"],
#	:align 			=> { 0 => :center, 1 => :left, 2 => :left, 3 => :left, 4 => :right, 5 => :right, 6 => :left, 7 => :left },
#	:position		=> :center

pdf.table(  [["รหัส","สถานะตาม จ.18"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end