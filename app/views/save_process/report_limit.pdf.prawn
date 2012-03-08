# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14
year = params[:fiscal_year].to_s + params[:round]
date = case year[4].to_s
    when "1" then "ณ  วันที่ 1 เมษายน #{year[0..3]}"
    when "2" then "ณ วันที่ 1 ตุลาคม #{year[0..3]}"
    else ""
end
pdf.repeat :all do
    pdf.text "รายละเอียดการใช้เงิน",:align => :center
    pdf.text "ส่วนราชการ #{@subdeptname}",:align => :center
    pdf.text @title,:align => :center
    pdf.move_down(20)
end
n1 = 0
money1 = 0
records = @records1.map do |record|
    n1 += record[:n].to_i
    money1 += record[:a].to_f - record[:b].to_f + record[:c].to_f
    [
	  record[:gname],
	  number_with_delimiter(record[:n]),
	  number_to_currency(record[:a].to_f - record[:b].to_f + record[:c].to_f,:unit => "")
    ]
end
records.push(["<b>รวม</b>", "<b>#{number_with_delimiter(n1)}</b>","<b>#{number_to_currency(money1,:unit => "")}</b>"])
ks24 = 0
if @rs_ks24.length > 0
    ks24 = @rs_ks24[0].ks24
    records.push(["เงินงบประมาณ"," ",number_to_currency(@rs_ks24[0].ks24,:unit => "")]) 
else
    records.push(["เงินงบประมาณ"," ","0"])  
end
records.push([" "," "," "])
records.push(["<b>ผลต่าง</b>"," ","<b>#{number_to_currency(ks24-money1,:unit => "")}</b>"])
pdf.table(
            [["ประเภท","จำนวนคน","จำนวนเงน"], *(records)],
            :header => true,
            :position => :center,:column_widths => [150,100,100],
            :cell_style => {:inline_format => true }
) do
    column(1).style :align => :right,:padding_right => 10
    column(2).style :align => :right,:padding_right => 10
    row(0).style :align => :center
end
######################
pdf.move_down(20)
pdf.text "รายละเอียดการประกาศเงินเดือน",:align => :center
pdf.text date,:align => :center
total_n2 = 0
total_money2 = 0
records2 = @rs_subdetail.map do |r|
    rs = TIncsalary.select("count(*) as n,sum(t_incsalary.newsalary) as a, sum(t_incsalary.salary) as b, sum(t_incsalary.addmoney) as c").find(:all,:conditions => "#{@search} and evalno = #{r[:dno]}")
    n2 = 0
    money2 = 0
    if rs.length > 0
	total_n2 += rs[0].n.to_i
	total_money2 += rs[0].a.to_f - rs[0].b.to_f + rs[0].c.to_f
	n2 = rs[0].n
	money2 = number_to_currency(rs[0].a.to_f - rs[0].b.to_f + rs[0].c.to_f,:unit => "")
    end
    
    [
	r[:e_name],
	"#{r[:e_begin]} - #{r[:e_end]}",
	r[:up],
	number_with_delimiter(n2),
	number_to_currency(money2,:unit => "")
    ]
end
records2.push(["รวม","","",number_with_delimiter(total_n2),number_to_currency(total_money2,:unit => "")])
pdf.move_down(20)
pdf.table(
            [["ระดับ","ช่วงคะแนน","ร้อยละ","จำนวนคน","จำนวนเงิน"], *(records2)],
            :header => true,
            :position => :center,:column_widths => [105,120,105,105,105],
            :cell_style => {:inline_format => true,:borders => [] }
) do
    column(1).style :align => :left,:padding_right => 10
    column(2).style :align => :left,:padding_right => 10
    column(3).style :align => :left,:padding_right => 10
    column(4).style :align => :left,:padding_right => 10
    row( row_length - 1).style :align => :center,:borders => [:bottom,:top]
    row(0).style :align => :center,:borders => [:bottom,:top]
end
