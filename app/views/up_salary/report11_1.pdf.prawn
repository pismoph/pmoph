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
    when "1" then "ณ วันที่ 1 เมษายน #{year[0..3]}"
    when "2" then "ณ วันที่ 1 ตุลาคม #{year[0..3]}"
    else ""
end

date2 = case year[4].to_s
    when "1" then "ณ วันที่ 1 มีนาคม #{year[0..3]}"
    when "2" then "ณ วันที่ 1 กันยายน #{year[0..3]}"
    else ""
end

type_report = case params[:type]
    when "1" then "ตาม จ.18"
    when "2" then "ตามปฏิบัติจริง"
    else ""
end

if @t_ks24usemain.length == 0
    pdf.text "ข้อมูลไม่สมบูรณ์หรือไม่พบข้อมูล",:align => :center
else

    pdf.repeat :all, :dynamic => true do
        pdf.bounding_box [380, 775], :width => 200, :height => 52 do
            pdf.text "เอกสารหมายเลข 9",:align => :right, :valign => :center
        end
        pdf.text "บัญชีสรุปจำนวนข้าราชการและจำนวนเงินที่ใช้ในการเลื่อนเงินเดือน",:align => :center
        pdf.text "กับได้รับค่าตอบแทนพิเศษ #{date}",:align => :center
        pdf.text "<u>#{@subdeptname}</u>",:align => :center,:inline_format => true
        pdf.text "<u>#{type_report}</u>",:align => :center,:inline_format => true
        money1 = @t_ks24usemain[0].salary.to_f*(params[:percent].to_f/100)
        pdf.text "จำนวนร้อยละ #{params[:percent]} #{date2} เป็นเงิน #{number_to_currency(money1,:unit => "")}",:align => :center
        pdf.text "จำนวน <u>#{@t_ks24usemain[0].calpercent}</u>           ที่ได้รับจัดสรรเป็นเงิน  <u>#{number_to_currency(@t_ks24usemain[0].ks24,:unit => "")}</u>",:align => :center, :inline_format => true

        pdf.bounding_box [5, 620], :width => 180, :height => 52 do
            pdf.text "ตำแหน่งประเภท/ระดับ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        #######################
        pdf.bounding_box [185, 620], :width => 136, :height => 26 do
            pdf.text "เลื่อนเงินเดือน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [185, 594], :width => 68, :height => 26 do
            pdf.text "จำนวนคน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [253, 594], :width => 68, :height => 26 do
            pdf.text "จำนวนเงิน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        #######################
        pdf.bounding_box [321, 620], :width => 136, :height => 26 do
            pdf.text "ค่าตอบแทนพิเศษ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [321, 594], :width => 68, :height => 26 do
            pdf.text "จำนวนคน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        pdf.bounding_box [389, 594], :width => 68, :height => 26 do
            pdf.text "จำนวนเงิน",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
        #########################
        pdf.bounding_box [457, 620], :width => 140, :height => 52 do
            pdf.text "หมายเหตุ",:align => :center, :valign => :center,:inline_format => true
            pdf.stroke_bounds
        end
    end
    records = []
    @rs_group.each do |u|
        records.push([
            u.gname,
            u.clname,
            "","","","",""
        ])
    end
    records.each do |r|
        @rs1.each do |rs1|
            if r[0] == rs1.gname and r[1] == rs1.clname
                r[2] = rs1.cn
                r[3] = rs1.salary
            end
        end
    end
    
    records.each do |r|
        @rs2.each do |rs2|
            if r[0] == rs2.gname and r[1] == rs2.clname
                r[4] = rs2.cn
                r[5] = rs2.salary
            end
        end
    end
    col1 = 0
    col2 = 0
    col3 = 0
    col4 = 0
    col1_total = 0
    col2_total = 0
    col3_total = 0
    col4_total = 0
    records2 = []
    for i in 0...records.length
        if i == 0
            records2.push([
                "<u>ประเภท#{records[i][0]}</u>","","","","",""
            ])
        else
            if records[i][0] != records[i - 1][0]
                records2.push([
                    "รวม",
                    number_with_delimiter(col1),
                    number_to_currency(col2,:unit => ""),
                    number_with_delimiter(col3),
                    number_to_currency(col4,:unit => ""),
                    ""
                ])
                records2.push([
                    "<u>ประเภท#{records[i][0]}</u>","","","","",""
                ])
                col1 = 0
                col2 = 0
                col3 = 0
                col4 = 0
            end
        end
        records2.push([
            "#{records[i][1]}",
            records[i][2],
            number_to_currency(records[i][3],:unit => ""),
            records[i][4],
            number_to_currency(records[i][5],:unit => ""),
            records[i][6]
        ])
        col1_total += records[i][2].to_i
        col2_total += records[i][3].to_f
        col3_total += records[i][4].to_i
        col4_total += records[i][5].to_f
        
        col1 += records[i][2].to_i
        col2 += records[i][3].to_f
        col3 += records[i][4].to_i
        col4 += records[i][5].to_f
        
        if i == records.length - 1
            records2.push([
                "รวม",
                number_with_delimiter(col1),
                number_to_currency(col2,:unit => ""),
                number_with_delimiter(col3),
                number_to_currency(col4,:unit => ""),
                ""
            ])
            col1 = 0
            col2 = 0
            col3 = 0
            col4 = 0                
        end
    end
    
    records2.push([
        "<b>รวมทั้งหมด</b>",
        number_with_delimiter(col1_total),
        number_to_currency(col2_total,:unit => ""),
        number_with_delimiter(col3_total),
        number_to_currency(col4_total,:unit => ""),
        ""
    ])    
    
    pdf.table(
            records2, :position => :center,:column_widths => [180,68,68,68,68,140],
            :cell_style => { :borders => [:left, :right],
            :inline_format => true } ) do
        row(-1).style :borders => [:bottom, :left, :right]
        
        row(lambda { |r|  cells[r, 1].content != "" and cells[r, 0].content != "รวม" and cells[r, 0].content != "<b>รวมทั้งหมด</b>" }).column(0).style :align => :left,:padding_left => 30

        row(lambda { |r|  cells[r, 0].content == "รวม" or cells[r, 0].content == "<b>รวมทั้งหมด</b>" }).style :borders => [:top,:bottom,:right,:left]
        
        
    end
end