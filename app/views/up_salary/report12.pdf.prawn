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
if @rs.length == 0
    pdf.text "ข้อมูลไม่สมบูรณ์หรือไม่พบข้อมูล",:align => :center
else
    pdf.repeat :all, :dynamic => true do
        pdf.move_down(-70)
        pdf.text "บัญชีสรุป ผลการบริหารวงเงินเลื่อนเงินเดือน #{date}",:align => :center
        pdf.text "ส่วนราชการ #{@subdeptname}", :align => :center
    end
end
records = []
cn_total = 0
sal_total = 0.00
ks24_total = 0.00
cn = 0
sal = 0.00
for i in 0...@rs.length
    salary = @rs[i].a.to_f - @rs[i].b.to_f + @rs[i].c.to_f 
    if i == 0
        cn = 0
        sal = 0
        records.push([
            @rs[i].usename,
            "",
            "",
            "",
            "",
            "",
            "",
            ""
        ])
        records.push([
            "",
            @rs[i].e_name,
            "#{@rs[i].e_begin} - #{@rs[i].e_end}",
            @rs[i].up,
            number_with_delimiter(@rs[i].cn),
            number_to_currency(salary,:unit => ""),
            "",
            ""
        ])
        cn += @rs[i].cn.to_i
        sal += salary.to_f
        if @rs.length == 1
            records.push([
                "<b>รวม</b>",
                "",
                "",
                "",
                number_with_delimiter(cn),
                number_to_currency(sal,:unit => ""),
                number_to_currency(@rs[i].ks24,:unit => ""),
                number_to_currency(@rs[i].ks24.to_f - sal.to_f,:unit => "")
            ])
            ks24_total += @rs[i].ks24.to_f
        end
    else
        if @rs[i].usename != @rs[i - 1].usename
            records.push([
                "<b>รวม</b>",
                "",
                "",
                "",
                number_with_delimiter(cn),
                number_to_currency(sal,:unit => ""),
                number_to_currency(@rs[i - 1 ].ks24,:unit => ""),
                number_to_currency(@rs[i - 1].ks24.to_f - sal.to_f,:unit => "")
            ])
            ks24_total += @rs[i - 1].ks24.to_f
            cn = 0
            sal = 0 
            records.push([
                @rs[i].usename,
                "",
                "",
                "",
                "",
                "",
                "",
                ""
            ])
        end
        records.push([
            "",
            @rs[i].e_name,
            "#{@rs[i].e_begin} - #{@rs[i].e_end}",
            @rs[i].up,
            number_with_delimiter(@rs[i].cn),
            number_to_currency(salary,:unit => ""),
            "",
            ""
            
        ])
        cn += @rs[i].cn.to_i
        sal += salary
        if @rs.length - 1 == i
            records.push([
                "<b>รวม</b>",
                "",
                "",
                "",
                number_with_delimiter(cn),
                number_to_currency(sal,:unit => ""),
                number_to_currency(@rs[i].ks24,:unit => ""),
                number_to_currency(@rs[i].ks24.to_f - sal.to_f,:unit => "")
            ])
            ks24_total += @rs[i].ks24.to_f
        end
        
    end
    
    cn_total += @rs[i].cn.to_i
    sal_total += salary
end

records.push([
    "<b>รวมทั้งหมด</b>",
    "",
    "",
    "",
    number_with_delimiter(cn_total),
    number_to_currency(sal_total,:unit => ""),
    number_to_currency(ks24_total,:unit => ""),
    number_to_currency(ks24_total - sal_total,:unit => "")
])

pdf.table(
            [["กลุ่มบริหารเงิน","ระดับ","ช่วงคะแนน","ร้อยละ","จำนวนคน","จำนวนเงิน<br />ที่ใช้ในการเลื่อน","งบประมาณ","งบประมาณ<br />ขาด/เกิน"], *(records)],
            :header => true,:width => 590,
            :position => :center,:column_widths => [80,44,70,50,62,120,65,99],
            :cell_style => {:inline_format => true ,:borders => []}
) do
    row(0).style :align => :center, :valign => :center ,:borders => [:bottom,:top]
    row(lambda { |r|  cells[r, 1].content == "" and cells[r, 4].content != ""  }).style :borders => [:top,:bottom]
end
