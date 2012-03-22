# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 12
date = case @year[4].to_s
    when "1" then "ณ วันที่ 1 เมษายน #{@year[0..3]}"
    when "2" then "ณ วันที่ 1 ตุลาคม #{@year[0..3]}"
    else ""
end

pdf.repeat :all, :dynamic => true do
    pdf.move_down(-105)
    pdf.text "บัญชีรายชื่อผู้ไม่อยู่ในเกณฑ์เลื่อนเงินเดือน ซึ่งต้องพ้นจากราชการเพราะครบเกษียณอายุ เมื่อสิ้นปีงบประมาณ พ.ศ. #{@year[0..3]}", :align => :center
    
    pdf.move_down(20)
    pdf.bounding_box [73, 688], :width => 32, :height => 52 do
        pdf.text "ลำดับ<br />ที่",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [105, 688], :width => 120, :height => 52 do
        pdf.text "ชื่อ-นามสกุล<br />เลขประจำตัวประชาชน",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    #####################################
    pdf.bounding_box [225, 688], :width => 200, :height => 26 do
        pdf.text "ตำแหน่งและส่วนราชการ",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end    
    pdf.bounding_box [225, 662], :width => 100, :height => 26 do
        pdf.text "สังกัด/ตำแหน่ง",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [325, 662], :width => 68, :height => 26 do
        pdf.text "ระดับ",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [393, 662], :width => 32, :height => 26 do
        pdf.text "เลขที่",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    ###################################
    pdf.bounding_box [425, 688], :width => 44, :height => 52 do
        pdf.text "อัตรา<br />เงินเดือน",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [469, 688], :width => 60, :height => 52 do
        pdf.text "หมายเหตุ",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    
    if pdf.page_number != pdf.page_count
        pdf.stroke {            
            pdf.line [73, 0], [529, 0]
            pdf.line [73, 0], [73, 50]
            pdf.line [105, 0], [105, 50]
            pdf.line [225, 0], [225, 50]
            pdf.line [325, 0], [325, 50]
            pdf.line [393, 0], [393, 50]
            pdf.line [425, 0], [425, 50]
            pdf.line [469, 0], [469, 50]
            pdf.line [529, 0], [529, 50]
        }
    end

end
records = @records.map do |r|
    [
        r[:i],
        "#{r[:name]}<br />#{r[:pid]}",
        r[:posname],
        r[:clname],
        r[:posid],
        r[:salary],
        r[:note1]
    ]
end

pdf.font_size 10
pdf.table(
        records, :position => :center,:column_widths => [32,120,
                                                       100,68,32,
                                                       44,60],
        :cell_style => { :borders => [:left, :right],
        :inline_format => true } ) do
    row(-1).style :borders => [:bottom, :left, :right]
end



