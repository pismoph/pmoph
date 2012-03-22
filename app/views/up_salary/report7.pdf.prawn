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
        when "1" then "ณ วันที่ 1 เมษายน #{@year[0..3]}"
        when "2" then "ณ วันที่ 1 ตุลาคม #{@year[0..3]}"
        else ""
    end
    
    pdf.repeat :all, :dynamic => true do
        pdf.move_down(-105)
        pdf.text "บัญชีรายละเอียดเลื่อนเงินเดือนข้าราชการ ได้รับค่าตอบแทนพิเศษ #{date}", :align => :center
        pdf.text "แนบท้ายคำสั่ง #{@province} ที่....................ลงวันที่....................", :align => :center
        pdf.move_down(20)
        pdf.bounding_box [40.5, 508], :width => 32, :height => 52 do
            pdf.text "ลำดับ<br />ที่",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [72.5, 508], :width => 120, :height => 52 do
            pdf.text "ชื่อ-นามสกุล<br />เลขประจำตัวประชาชน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        #####################################
        pdf.bounding_box [192.5, 508], :width => 200, :height => 26 do
            pdf.text "ตำแหน่งและส่วนราชการ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end    
        pdf.bounding_box [192.5,482], :width => 100, :height => 26 do
            pdf.text "สังกัด/ตำแหน่ง",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [292.5, 482], :width => 68, :height => 26 do
            pdf.text "ระดับ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [360.5, 482], :width => 32, :height => 26 do
            pdf.text "เลขที่",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###################################
        pdf.bounding_box [392.5, 508], :width => 44, :height => 52 do
            pdf.text "อัตรา<br />เงินเดือน<br />เดิม",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [436.5, 508], :width => 44, :height => 52 do
            pdf.text "อัตรา<br />เงินเดือน<br />ที่เต็มขั้น",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [480.5, 508], :width => 29, :height => 52 do
            pdf.text "ฐาน<br />ในการ<br />คำนวณ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [509, 508], :width => 44, :height => 52 do
            pdf.text "ร้อยละ<br />ที่ได้<br />เลื่อน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [553.5, 508], :width => 44, :height => 52 do
            pdf.text "จำนวนเงิน<br />ที่ได้เลื่อน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        pdf.bounding_box [597.5, 508], :width => 44, :height => 52 do
            pdf.text "จำนวนเงิน<br />ค่าตอบแทน<br />พิเศษ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [641.5, 508], :width => 100, :height => 52 do
            pdf.text "หมายเหตุ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        if pdf.page_number != pdf.page_count
            pdf.stroke {
                pdf.line [40.5, 0], [741.5, 0]
                pdf.line [40.5, 0], [40.5, 100]
                pdf.line [72.5, 0], [72.5, 100]
                pdf.line [192.5, 0], [192.5, 100]
                pdf.line [292.5, 0], [292.5, 100]
                pdf.line [360.5, 0], [360.5, 100]
                pdf.line [392.5, 0], [392.5, 100]
                pdf.line [436.5, 0], [436.5, 100]
                pdf.line [480.5, 0], [480.5, 100]
                pdf.line [509.5, 0], [509.5, 100]
                pdf.line [553.5, 0], [553.5, 100]
                pdf.line [597.5, 0], [597.5, 100]
                pdf.line [641.5, 0], [641.5, 100]
                pdf.line [741.5, 0], [741.5, 100]
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
            r[:maxsalary],
            r[:midpoint],
            r[:calpercent],
            r[:diff],
            r[:newsalary],
            r[:note1]
        ]
    end
    
    pdf.font_size 10
    pdf.table(
            records, :position => :center,:column_widths => [32,120,
                                                           100,68,32,
                                                           44,44,29,44,44,44,100],
            :cell_style => { :borders => [:left, :right],
            :inline_format => true } ) do
        row(-1).style :borders => [:bottom, :left, :right]
    end
end

