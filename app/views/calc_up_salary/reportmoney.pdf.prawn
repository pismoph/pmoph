# encoding: utf-8
#pdf.font "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf"

pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14
date = case params[:year][4].to_s
    when "1" then "1 มีนาคม"
    when "2" then "1 กันยายน"
    else ""
end

type_report = case params[:type]
    when "1" then "ตาม จ.18"
    when "2" then "ตามปฏิบัติงานจริง"
    else ""
end

pdf.repeat :all, :dynamic => true do
    pdf.move_down(-70)
    pdf.text "คำนวณนับเงิน ณ วันที่ #{date} #{params[:year][0..3]}", :align => :center
    pdf.text "#{type_report}", :align => :center,:inline_format => true
end

sum_person_case = 0
sum_sal_case = 0
sum_percent_case = 0

sum_person = 0
sum_sal = 0
sum_percent = 0

sum_person_case2 = 0
sum_sal_case2 = 0
sum_percent_case2 = 0
search_case = case params[:type]
    when "1" then " t_incsalary.j18code = '1' "
    when "2" then " t_incsalary.j18code in ('2','3','4','5','6') "
    else ""
end
#################################################        1. กลุ่มอำนวยการ
pdf.text "1. กลุ่มอำนวยการ"
pdf.table(
            [["ประเภท/ระดับ","จำนวนคน","เงินเดือน","ร้อยละ #{"%.2f" % params[:percent]}","ร้อยละ #{"%.2f" % params[:percent2]}","ร้อยละ #{"%.2f" % params[:percent3]}"],
            *([[@subdeptname,"","","","",""],[" ","","","","",""]])],
            :header => true,:position => :center,:column_widths => [250,60,60,60,60,60],
            :cell_style => { :inline_format => true }
) do
    row(0).style :align => :center
end






sql = "select sum(t_incsalary.salary) as salary,count(*) as n,cgrouplevel.clname from t_incsalary"
sql += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
sql += " where cgrouplevel.ccode in (21,22) and #{@search} and #{search_case} group by cgrouplevel.clname "


pdf.text sql

TIncsalary.find_by_sql(sql).each do |u|
    sal = u.salary.to_f*(params[:percent].to_f/100)
    sal = ("%.2f" % sal).to_f
    sum_person_case += u.n.to_i
    sum_sal_case += ("%.2f" % u.salary).to_f
    sum_percent_case += sal
    
    sum_person += u.n.to_i
    sum_sal += ("%.2f" % u.salary).to_f
    sum_percent += sal
    
    pdf.table(
            [["#{u.clname}","#{u.n}","#{number_to_currency(u.salary,:unit => "")}","#{number_to_currency(sal,:unit => "")}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:bottom],:inline_format => true }
    )do
        column(0).style :align => :left,:padding_left => 20
        column(1).style :align => :right
        column(2).style :align => :right
        column(3).style :align => :right
    end
end

pdf.table(
        [["รวมกลุ่มอำนวยการ","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
pdf.table(
        [["รวม1.กลุ่มอำนวยการ","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
sum_person_case = 0
sum_sal_case = 0
sum_percent_case = 0

################################################# 2. กลุ่มวิชาการ(เชี่ยวชาญ/ทรงคุณวุฒิ)
pdf.move_down(10)
pdf.text "2. กลุ่มวิชาการ(เชี่ยวชาญ/ทรงคุณวุฒิ)"
pdf.table(
            [["ตำแหน่งประเภท/ระดับ","จำนวนผู้ครองตำแหน่ง","จำนวนเงิน","ร้อยละ #{"%.2f" % params[:percent]}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:top, :bottom],:inline_format => true }
) do
    row(0).style :align => :right
    column(0).style :align => :left,:padding_left => 20
end
pdf.text "<u>วิชาการ</u>", :align => :left,:inline_format => true
sql = "select sum(t_incsalary.salary) as salary,count(*) as n,cgrouplevel.clname from t_incsalary"
sql += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
sql += " where cgrouplevel.ccode in (34,35) and #{@search} and #{search_case} group by cgrouplevel.clname "
TIncsalary.find_by_sql(sql).each do |u|
    sal = u.salary.to_f*(params[:percent].to_f/100)
    sal = ("%.2f" % sal).to_f
    sum_person_case += u.n.to_i
    sum_sal_case += ("%.2f" % u.salary).to_f
    sum_percent_case += sal
    
    sum_person += u.n.to_i
    sum_sal += ("%.2f" % u.salary).to_f
    sum_percent += sal
    
    pdf.table(
            [["#{u.clname}","#{u.n}","#{number_to_currency(u.salary,:unit => "")}","#{number_to_currency(sal,:unit => "")}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:bottom],:inline_format => true }
    )do
        column(0).style :align => :left,:padding_left => 20
        column(1).style :align => :right
        column(2).style :align => :right
        column(3).style :align => :right
    end
end
pdf.table(
        [["รวมวิชาการ","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
pdf.table(
        [["รวม2. กลุ่มวิชาการ(เชี่ยวชาญ/ทรงคุณวุฒิ)","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
sum_person_case = 0
sum_sal_case = 0
sum_percent_case = 0

################################################# 3.กลุ่มวิชาการและทั่วไป
pdf.move_down(10)
pdf.text "3.กลุ่มวิชาการและทั่วไป"
pdf.table(
            [["ตำแหน่งประเภท/ระดับ","จำนวนผู้ครองตำแหน่ง","จำนวนเงิน","ร้อยละ #{"%.2f" % params[:percent]}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:top, :bottom],:inline_format => true }
) do
    row(0).style :align => :right
    column(0).style :align => :left,:padding_left => 20
end
pdf.text "<u>ทั่วไป</u>", :align => :left,:inline_format => true
sql = "select sum(t_incsalary.salary) as salary,count(*) as n,cgrouplevel.clname from t_incsalary"
sql += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
sql += " where cgrouplevel.ccode in (51,52,53,54) and #{@search} and #{search_case} group by cgrouplevel.clname "
TIncsalary.find_by_sql(sql).each do |u|
    sal = u.salary.to_f*(params[:percent].to_f/100)
    sal = ("%.2f" % sal).to_f
    sum_person_case += u.n.to_i
    sum_sal_case += ("%.2f" % u.salary).to_f
    sum_percent_case += sal
    
    sum_person_case2 += u.n.to_i
    sum_sal_case2 += ("%.2f" % u.salary).to_f
    sum_percent_case2 += sal
    
    sum_person += u.n.to_i
    sum_sal += ("%.2f" % u.salary).to_f
    sum_percent += sal
    
    pdf.table(
            [["#{u.clname}","#{u.n}","#{number_to_currency(u.salary,:unit => "")}","#{number_to_currency(sal,:unit => "")}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:bottom],:inline_format => true }
    )do
        column(0).style :align => :left,:padding_left => 20
        column(1).style :align => :right
        column(2).style :align => :right
        column(3).style :align => :right
    end
end
pdf.table(
        [["รวมทั่วไป","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
sum_person_case = 0
sum_sal_case = 0
sum_percent_case = 0

#####
pdf.text "<u>วิชาการ</u>", :align => :left,:inline_format => true
sql = "select sum(t_incsalary.salary) as salary,count(*) as n,cgrouplevel.clname from t_incsalary"
sql += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
sql += " where cgrouplevel.ccode in (31,32,33) and #{@search} and #{search_case} group by cgrouplevel.clname "
TIncsalary.find_by_sql(sql).each do |u|
    sal = u.salary.to_f*(params[:percent].to_f/100)
    sal = ("%.2f" % sal).to_f
    sum_person_case += u.n.to_i
    sum_sal_case += ("%.2f" % u.salary).to_f
    sum_percent_case += sal
    
    sum_person_case2 += u.n.to_i
    sum_sal_case2 += ("%.2f" % u.salary).to_f
    sum_percent_case2 += sal    
    
    sum_person += u.n.to_i
    sum_sal += ("%.2f" % u.salary).to_f
    sum_percent += sal
    
    pdf.table(
            [["#{u.clname}","#{u.n}","#{number_to_currency(u.salary,:unit => "")}","#{number_to_currency(sal,:unit => "")}"]],
            :position => :left,:column_widths => [230,120,120,120],
            :cell_style => { :borders => [:bottom],:inline_format => true }
    )do
        column(0).style :align => :left,:padding_left => 20
        column(1).style :align => :right
        column(2).style :align => :right
        column(3).style :align => :right
    end
end
pdf.table(
        [["รวมวิชาการ","#{sum_person_case}","#{number_to_currency(sum_sal_case,:unit => "")}","#{number_to_currency(sum_percent_case,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
sum_person_case = 0
sum_sal_case = 0
sum_percent_case = 0
pdf.table(
        [["รวม3.กลุ่มวิชาการและทั่วไป","#{sum_person_case2}","#{number_to_currency(sum_sal_case2,:unit => "")}","#{number_to_currency(sum_percent_case2,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true,:border_width => 2 }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
sum_person_case2 = 0
sum_sal_case2 = 0
sum_percent_case2 = 0
pdf.table(
        [["<b>รวมทั้งหมด</b>","#{sum_person}","#{number_to_currency(sum_sal,:unit => "")}","#{number_to_currency(sum_percent,:unit => "")}"]],
        :position => :left,:column_widths => [230,120,120,120],
        :cell_style => { :borders => [:bottom],:inline_format => true }
)do
    column(0).style :align => :left
    column(1).style :align => :right
    column(2).style :align => :right
    column(3).style :align => :right
end
