# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 12
if @records.length == 0
    pdf.text "ไม่พบข้อมูล",:align => :center
else

    date = case @year[4].to_s
        when "1" then "วันที่ 1 เมษายน #{@year[0..3]}"
        when "2" then "วันที่ 1 ตุลาคม #{@year[0..3]}"
        else ""
    end
    
    pdf.repeat :all, :dynamic => true do
        pdf.move_down(-105)
        pdf.text "บัญชีแจ้งผลพิจารณาเลื่อนเงินเดือนข้าราชการ ที่มาปฏิบัติงาน(มาช่วยราชการ)", :align => :center
        pdf.text "ส่วนราชการ #{@subdeptname} ปี #{@year[0..3]} ครั้งที่  #{@year[4]} #{date}",:align => :center
        pdf.move_down(20)
        pdf.bounding_box [0, 688], :width => 32, :height => 52 do
            pdf.text "ลำดับ<br />ที่",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [32, 688], :width => 120, :height => 52 do
            pdf.text "ชื่อ-นามสกุล",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        #####################################
        pdf.bounding_box [152, 688], :width => 200, :height => 26 do
            pdf.text "ตำแหน่งและส่วนราชการ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end    
        pdf.bounding_box [152, 662], :width => 100, :height => 26 do
            pdf.text "สังกัด/ตำแหน่ง",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [252, 662], :width => 68, :height => 26 do
            pdf.text "ระดับ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [320, 662], :width => 32, :height => 26 do
            pdf.text "เลขที่ตำแหน่ง",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###################################
        pdf.bounding_box [352, 688], :width => 44, :height => 52 do
            pdf.text "เงินเดือน<br />เดิม",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [396, 688], :width => 44, :height => 52 do
            pdf.text "ฐาน<br />ในการ<br />คำนวณ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [440, 688], :width => 29, :height => 52 do
            pdf.text "ร้อยละ<br />ที่ได้<br />เลื่อน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [469, 688], :width => 44, :height => 52 do
            pdf.text "จำนวนเงิน<br />ที่ได้<br />เลื่อน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [513, 688], :width => 44, :height => 52 do
            pdf.text "เงินเดือน<br />ที่ได้รับ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [557, 688], :width => 44, :height => 52 do
            pdf.text "หมายเหตุ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        if pdf.page_number != pdf.page_count
            pdf.stroke {
                pdf.line [0, 0], [599, 0]
                pdf.line [0, 0], [0, 50]
                pdf.line [32, 0], [32, 50]
                pdf.line [152, 0], [152, 50]
                pdf.line [252, 0], [252, 50]
                pdf.line [320, 0], [320, 50]
                pdf.line [352, 0], [352, 50]
                pdf.line [396, 0], [396, 50]
                pdf.line [440, 0], [440, 50]
                pdf.line [469, 0], [469, 50]
                pdf.line [513, 0], [513, 50]
                pdf.line [557, 0], [557, 50]
                pdf.line [601, 0], [601, 50]
            }
        end
    
    end
    records = @records.map do |r|
        [
            r[:i],
            r[:name],
            r[:posname],
            r[:clname],
            r[:posid],
            r[:salary],
            r[:midpoint],
            r[:calpercent],
            r[:diff],
            r[:newsalary],
            r[:note1]
        ]
    end
    
    pdf.font_size 10
    pdf.table(
            records, :position => :left,:column_widths => [32,120,
                                                           100,68,32,
                                                           44,44,29,44,44,44],
            :cell_style => { :borders => [:left, :right],
            :inline_format => true } ) do
        row(-1).style :borders => [:bottom, :left, :right]
    end
end