# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 10

pdf.repeat :all, :dynamic => true do
    pdf.move_down(-120)
    pdf.text "<b>สรุปวันลา ปีงบประมาณ #{@year}</b>",:align => :center, :inline_format => true
    pdf.text "<b>เงื่อนไข</b>",:align => :center, :inline_format => true
    dt = Time.now
    dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    pdf.text "พิมพ์วันที่ #{dt_th} จำนวน #{@records.length} รายการ"
    ##################################################################
    pdf.bounding_box [1, 705], :width => 30, :height => 78 do
        pdf.text "ลำดับที่",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [31, 705], :width => 50, :height => 78 do
        pdf.text "เลขที่ตำแหน่ง",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [81, 705], :width => 160, :height => 78 do
        pdf.text "ชื่อ-นามสกุล",:align => :center, :valign => :center
        pdf.stroke_bounds
    end    
    ##################################################################
    pdf.bounding_box [241, 679], :width => 30, :height => 52 do
        pdf.text "ลาพักผ่อน<br />คงเหลือ<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [271, 679], :width => 30, :height => 52 do
        pdf.text "ลาพักผ่อน<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end     
    
    pdf.bounding_box [301, 679], :width => 30, :height => 52 do
        pdf.text "ป่วย<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [331, 679], :width => 30, :height => 52 do
        pdf.text "กิจ<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [361, 679], :width => 30, :height => 52 do
        pdf.text "จำนวน<br />(ครั้ง)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [391, 679], :width => 30, :height => 52 do
        pdf.text "สาย<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [421, 679], :width => 30, :height => 52 do
        pdf.text "ขาด<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [451, 679], :width => 30, :height => 52 do
        pdf.text "ป่วย<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [481, 679], :width => 30, :height => 52 do
        pdf.text "กิจ<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [511, 679], :width => 30, :height => 52 do
        pdf.text "จำนวน<br />(ครั้ง)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [541, 679], :width => 30, :height => 52 do
        pdf.text "สาย<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [571, 679], :width => 30, :height => 52 do
        pdf.text "ลาพักผ่อน<br />(วัน)",:align => :center, :valign => :center, :inline_format => true
        pdf.stroke_bounds
    end 
    
    ##################################################################

    

    pdf.bounding_box [241, 705], :width => 210, :height => 26 do
        pdf.text "1 ต.ค. #{@year.to_i - 1} - 30 ก.ย. #{@year.to_i}",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [451, 705], :width => 150, :height => 26 do
        pdf.text "1 เม.ย. #{@year.to_i}  - 30 ก.ย. #{@year.to_i}",:align => :center, :valign => :center
        pdf.stroke_bounds
    end  
    
    
    

    #pdf.bounding_box [0, 740], :width => 590, :height => 52 do
    #    pdf.text "รายละเอียดประกาศร้อยละของฐานในการคำนวณการเลื่อนเงินเดือน  #{date} ", :align => :center
    #    pdf.text @subdeptname,:align => :center
    #end
end


pdf.table(
    @records,
    :cell_style => {:inline_format => true ,:borders => [:left,:right]},
    :position => :center,
    :column_widths => [30,50,160,30,30,30,30,30,30,30,30,30,30,30,30],
) do
    row(-1).style :borders => [:left,:right,:bottom]
end
