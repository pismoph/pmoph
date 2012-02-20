pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = @records.map do |records|
  [
	records.jobcode.to_i,
	records.jobname
  ]
end

#pdf.table records, 
#	:row_colors 		=> ["FFFFFF","DDDDDD"],
#	:align_headers		=> :center,
#	:border_style 		=> :grid,
#	:headers 		=> ["รหัสงาน","ชื่องาน"],
#	:align 			=> { 0 => :center, 1 => :left },
#	:position		=> :center

pdf.table([["รหัสงาน","ชื่องาน"], *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end


