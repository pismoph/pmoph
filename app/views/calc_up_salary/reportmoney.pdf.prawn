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
    pdf.text "คำนวณการนับเงิน ณ วันที่ #{date} #{params[:year][0..3]}", :align => :center
    pdf.text "#{type_report}", :align => :center,:inline_format => true
end


#################################################        1. กลุ่มอำนวยการ
pdf.text "1. กลุ่มอำนวยการ"

search = " t_incsalary.year = #{params[:year]} "
if params[:type].to_s == '1'
    search += " and t_incsalary.j18code in (1,2,3,4,5,6) "
    search += " and t_incsalary.level <= 99 "
    search += " and t_incsalary.flagcal = '1' "
elsif params[:type].to_s == '2'
    search += " and t_incsalary.level <= 99 "       
    search += " and t_incsalary.flagcal = '1' "
end
search += " and cgrouplevel.ccode in (21,22) "
search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
if params[:type].to_s == '1'
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
elsif params[:type].to_s == '2'
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
end
str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
str_join += " left join csection on t_incsalary.seccode = csection.seccode "
str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
select = " sum(t_incsalary.salary) as salary,count(*) as n,csection.secname,cgrouplevel.clname "
sql = "select #{select} from t_incsalary #{str_join} where #{search} group by csection.secname,cgrouplevel.clname"

rs = TIncsalary.find_by_sql(sql)


pdf.table(
            [["ประเภท/ระดับ","จำนวนคน","เงินเดือน","ร้อยละ #{"%.2f" % params[:percent]}","ร้อยละ #{"%.2f" % params[:percent2]}","ร้อยละ #{"%.2f" % params[:percent3]}"],
            *([[@subdeptname,"","","","",""],[" ","","","","",""]])],
            :header => true,:position => :center,:column_widths => [250,60,60,60,60,60],
            :cell_style => { :inline_format => true }
) do
    row(0).style :align => :center
end



