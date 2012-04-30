# encoding: utf-8

pdf.font "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf"
pdf.font_size 14
date = case @year[4].to_s
    when "1" then "1 มีนาคม"
    when "2" then "1 กันยายน"
    else ""
end

pdf.repeat :all, :dynamic => true do
    pdf.move_down(-105)
    pdf.text "บัญชีรายชื่อข้าราชการ ณ วันที่ #{date} #{@year[0..3]}", :align => :center
    pdf.text "ตาม จ.18", :align => :center
    pdf.move_down(20)
    pdf.bounding_box [1, 688], :width => 40, :height => 52 do
        pdf.text "ลำดับที่",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [41, 688], :width => 120, :height => 52 do
        pdf.text "ชื่อ/นามสกุล",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    #####################################
    pdf.bounding_box [161, 688], :width => 330, :height => 26 do
        pdf.text "ตำแหน่งและส่วนราชการ",:align => :center, :valign => :center
        pdf.stroke_bounds
    end    
    pdf.bounding_box [161, 662], :width => 180, :height => 26 do
        pdf.text "สังกัด/ตำแหน่ง",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [341, 662], :width => 60, :height => 26 do
        pdf.text "ประเภท",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [401, 662], :width => 90, :height => 26 do
        pdf.text "ระดับ",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    ###################################
    pdf.bounding_box [491, 688], :width => 50, :height => 52 do
        pdf.text "เลขที่ตำแหน่ง",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [541, 688], :width => 50, :height => 52 do
        pdf.text "เงินเดือน",:align => :center, :valign => :center#,:inline_format => true
        pdf.stroke_bounds
    end
    
    if pdf.page_number != pdf.page_count
        pdf.stroke {
            pdf.line [0.5, 0], [591.5, 0]
            pdf.line [1, 0], [1, 50]
            pdf.line [41, 0], [41, 50]
            pdf.line [161, 0], [161, 50]
            pdf.line [341, 0], [341, 50]
            pdf.line [401, 0], [401, 50]
            pdf.line [491, 0], [491, 50]
            pdf.line [541, 0], [541, 50]
            pdf.line [591, 0], [591, 50]
        }
    end

end


i = 0
records = @records.map do |records|
    if records[:gname].to_s != "" and records[:clname].to_s != ""
       i += 1 
    end    
    [
        (records[:gname].to_s != "" and records[:clname].to_s != "")? i : "",
        records[:name],
        records[:posname],
        records[:gname],
        records[:clname],
        records[:posid],
        records[:salary]
    ]
end
pdf.font_size 10

pdf.table(records, :position => :center,:column_widths => [40,120, 180,60,90, 50,50], :cell_style => { :borders => [:left, :right],:inline_format => true } ) do
    row(-1).style :borders => [:bottom, :left, :right]
    row(lambda { |r|  cells[r, 5].content == "รวม" }).style :borders => [:left,:right,:bottom]
end



