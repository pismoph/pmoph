pdf.font "#{Prawn::BASEDIR}/data/fonts/tahoma.ttf" 
records = Array.new()
for rec in @records
	rec_tmp = Array.new()
	for col in @col
		rec_tmp.push(rec[:"#{col}"].to_s)
	end
	records.push(rec_tmp)
end
=begin
pdf.table records, 
	:row_colors 		=> ["FFFFFF","DDDDDD"],
	:align_headers		=> :center,
	:border_style 		=> :grid,
	:headers 			=> @col_show,
	:align 			=> { 0 => :right, 1 => :left, 2 => :left, 3 => :left },
	:position			=> :center
=end

pdf.table([@col_show, *(records)], :header => true,:width => 550 ) do
  row(0).style :align => :center   
end