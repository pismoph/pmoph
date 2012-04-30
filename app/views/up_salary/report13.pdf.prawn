# encoding: utf-8

pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14
year = params[:year].to_s
date = case year[4].to_s
    when "1" then "รอบที่ 1 วันที่ 1 ตุลาคม #{year[0..3].to_i - 1} ถึง วันที่ 31 มีนาคม #{year[0..3]}"
    when "2" then "รอบที่ 2 วันที่ 1 เมษายน #{year[0..3].to_i - 1} ถึง วันที่ 30 กันยายน #{year[0..3].to_i - 1}"
    else ""
end

if @rs.length == 0
    pdf.text "ข้อมูลไม่สมบูรณ์หรือไม่พบข้อมูล",:align => :center
else
    pdf.repeat :all, :dynamic => true do
        pdf.move_down(-70)
        pdf.text "หนังสือแจ้งผลการเลื่อนเงินเดือน",:align => :center
        pdf.move_down(20)
        pdf.text "#{date}", :align => :left
    end
    check_page = 0
    @rs.each do |u|
        check_page += 1
        pdf.text "ชื่อ   #{u.prefix}#{u.fname}     นามสกุล #{u.lname}"
        pdf.text "ตำแหน่ง #{u.posname} ประเภท#{u.gname} ระดับ#{u.clname}"
        h_subdept = ""
        @head_subdept.each do|h|
            if !h[:arr].index(u.sdtcode.to_i).nil?
                h_subdept = h[:longname]
            end
        end
        pdf.text "ส่วนราชการ  #{h_subdept}#{u.provname} "
        pdf.indent(50) do
            pdf.text "#{u.longpre_subdept}#{u.subdeptname}"
            pdf.text "#{u.secname}"
            pdf.text "#{u.jobname}"
        end
        pdf.move_down(20)
        pdf.text "หมายเหตุ::  ผลการเลื่อนเงินเดือนข้าราชการพลเรือนเป็นข้อมูลเฉพาะบุคคล"
        pdf.move_down(50)
        pdf.text "เงินเดือนเดิม(บาท)        #{number_to_currency(u.salary,:unit => "")}"
        pdf.move_down(10)
        pdf.stroke do
            pdf.rectangle [30, pdf.cursor], 15, 15
            if u.updcode.to_s != "600"
                pdf.line [40,pdf.cursor - 2] , [35,pdf.cursor - 13]
            end
        end
        pdf.indent(55) do
            pdf.text "ได้รับการเลื่อนเงินเดือน"
        end
        y = pdf.cursor - 10
        ######################
        pdf.bounding_box [55, y], :width => 88, :height => 78 do
            pdf.text "ฐานในการ<br />คำนวณ<br />(บาท)",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [55, y-78], :width => 88, :height => 26 do
            pdf.text "#{number_to_currency(u.midpoint,:unit => "")}",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###########################
        pdf.bounding_box [143, y], :width => 88, :height => 78 do
            pdf.text "ร้อยละ<br />ที่ได้เลื่อน ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [143, y-78], :width => 88, :height => 26 do
            pdf.text "#{u.up}",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###########################
        pdf.bounding_box [231, y], :width => 180, :height => 26 do
            pdf.text "จำนวนเงินที่ได้เพิ่ม",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###########################
        pdf.bounding_box [231, y - 26], :width => 80, :height => 52 do
            pdf.text "เงินเดือน<br />ที่ได้เลื่อน(บาท)",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [231, y - 78], :width => 80, :height => 26 do
            pdf.text number_to_currency((u.newsalary.to_f - u.salary.to_f),:unit => ""),:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###########################
        pdf.bounding_box [311, y - 26], :width => 100, :height => 52 do
            pdf.text "จำนวนค่าตอบแทนพิเศษ<br />(บาท)",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        pdf.bounding_box [311, y - 78], :width => 100, :height => 26 do
            pdf.text number_to_currency(u.addmoney.to_f,:unit => ""),:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        ###########################
        pdf.bounding_box [411, y], :width => 88, :height => 78 do
            pdf.text "เงินเดือนที่ได้รับ<br />(บาท)",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        pdf.bounding_box [411, y-78], :width => 88, :height => 26 do
            pdf.text number_to_currency(u.newsalary.to_f,:unit => ""),:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        
        ###########################
        
        pdf.stroke do
            pdf.rectangle [30, pdf.cursor - 20], 15, 15
            if u.updcode.to_s == "600"
                pdf.line [40,pdf.cursor - 22] , [35,pdf.cursor - 33]
            end
        end
        pdf.move_down(20)
        pdf.indent(55) do
            pdf.text "กรณีที่ไม่ได้รับเงินเดือน เนื่องจาก(เหตุผล)"
            pdf.text "#{u.note1}"
        end
        
        if @rs.length != check_page
            pdf.start_new_page
        end
        
        
    end
    
end
