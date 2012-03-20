# encoding: utf-8
def hd
    h = [
        {
          :a => [2,3,4,5,6,7,8,9],
          :h => "สำนักงานสาธารณสุขจังหวัด",
          :sh => "provcode"
        },
        {
            :a => [11,12,13,14,15,17,18],
            :h => "provcode",
            :sh => ""
        }
    ]
end

def title_hd(sdcode)
    title = ""
    begin
        type_title = hd
        rs_subdept = Csubdept.find(sdcode)
        type_title.each do|u|
            if !u[:a].index(rs_subdept.sdtcode).nil?
                if u[:h] != "provcode"
                    address = ""
                    prov = begin
                        Cprovince.find(rs_subdept.provcode)
                    rescue
                        ""
                    end
                    address += "#{(prov.to_s == "")? "" : prov.provname}"
                    title = "#{u[:h]}#{address}"
                else
                    prov = begin
                        Cprovince.find(rs_subdept.provcode)
                    rescue
                        ""
                    end
                    title = "#{prov.longpre}#{prov.provname}"
                end
            end
        end
        title += "#{rs_subdept.longpre}#{rs_subdept.subdeptname}"
    rescue
        ""
    end   
    title
end

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

total_n = 0
total_sal = 0
total_percent1 = 0
total_percent2 = 0
total_percent3 = 0
################################
sd_n = 0
sd_sal = 0
sd_percent1 = 0
sd_percent2 = 0
sd_percent3 = 0
#
sec_n = 0
sec_sal = 0
sec_percent1 = 0
sec_percent2 = 0
sec_percent3 = 0
#
job_n = 0
job_sal = 0
job_percent1 = 0
job_percent2 = 0
job_percent3 = 0

#################################################        1. กลุ่มอำนวยการ
pdf.text "1. กลุ่มอำนวยการ"
records = []
search = " t_incsalary.year = #{params[:year]} "
if params[:type].to_s == '1'
    search += " and t_incsalary.j18code in (1,2,3,4,5,6) "
    search += " and t_incsalary.level <= 99 "
    search += " and t_incsalary.flagcal = '1' "
elsif params[:type].to_s == '2'
    search += " and t_incsalary.level <= 99 "       
    search += " and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.wsdcode is not null "
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
if params[:type].to_s == '1'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
elsif params[:type].to_s == '2'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.wsdcode as sdcode,cprovince.provcode,t_incsalary.wseccode as seccode,t_incsalary.wjobcode as jobcode,t_incsalary.level "
end
sql = "select #{select} from t_incsalary #{str_join} where #{search} "
if params[:type].to_s == '1'
    sql += " group by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
    sql += " order by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level"
elsif params[:type].to_s == '2'
    sql += " group by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level "
    sql += " order by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level"    
end

rs = TIncsalary.find_by_sql(sql)
for i in 0...rs.length
    if i == 0
        records.push([
            "<b>#{title_hd(rs[i].sdcode)}</b>",
            "",
            "",
            "",
            "",
            ""
        ])
        
        if rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0" and rs[i].seccode.to_s != ""
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0" and rs[i].jobcode.to_s != ""
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s
            
            rs_job = begin
                Cjob.find(rs[i - 1].jobcode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{rs_job.jobname if rs_job != ""}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s
            rs_sec =begin
                Csection.find(rs[i - 1].seccode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{"#{rs_sec.shortname}#{rs_sec.secname}" if rs_sec != ""}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
            records.push([
                "รวม #{title_hd(rs[i - 1].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0            
        end
        

        if rs[i].sdcode != rs[i - 1].sdcode
            records.push([
                "<b>#{title_hd(rs[i].sdcode)}</b>",
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].seccode != rs[i - 1].seccode and rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode != rs[i - 1].jobcode and rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    end
    sd_n += rs[i].n.to_i
    sd_sal += rs[i].salary.to_i.ceil
    sd_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sd_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sd_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    sec_n += rs[i].n.to_i
    sec_sal += rs[i].salary.to_i.ceil
    sec_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sec_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sec_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    job_n += rs[i].n.to_i
    job_sal += rs[i].salary.to_i.ceil
    job_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    job_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    job_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    total_n += rs[i].n.to_i
    total_sal += rs[i].salary.to_i.ceil
    total_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    total_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    total_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    
    rs_group = Cgrouplevel.find(rs[i].level)
    records.push([
        {:content => "ประเภท#{rs_group.gname} ระดับ#{rs_group.clname}",:padding_left =>50},
        number_with_delimiter(rs[i].n),
        number_with_delimiter(rs[i].salary.to_i.ceil),
        number_to_currency(rs[i].salary.to_i*(params[:percent].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent2].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent3].to_f / 100),:unit => "")
    ])
    
    
    
    if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "รวม #{rs_job.jobname}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0         
        end
        if rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "รวม #{rs_sec.shortname}#{rs_sec.secname}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
        if rs[i].sdcode.to_s != "0"
            records.push([
                "รวม #{title_hd(rs[i].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
    end
    
end
pdf.font_size 10
pdf.table(
    [
        ["ประเภท/ระดับ","จำนวนคน","เงินเดือน","ร้อยละ #{"%.2f" % params[:percent]}","ร้อยละ #{"%.2f" % params[:percent2]}","ร้อยละ #{"%.2f" % params[:percent3]}"],
        *(records)
    ],
    :header => true,:position => :center,:column_widths => [250,60,60,60,60,60],
    :cell_style => { :inline_format => true }
) do
    row(0).style :align => :center
end
################################
sd_n = 0
sd_sal = 0
sd_percent1 = 0
sd_percent2 = 0
sd_percent3 = 0
#
sec_n = 0
sec_sal = 0
sec_percent1 = 0
sec_percent2 = 0
sec_percent3 = 0
#
job_n = 0
job_sal = 0
job_percent1 = 0
job_percent2 = 0
job_percent3 = 0

#################################################       2. กลุ่มวิชาการ(เชี่ยวชาญ/ทรงคุณวุฒิ)
pdf.text "2. กลุ่มวิชาการ(เชี่ยวชาญ/ทรงคุณวุฒิ)"
records = []
search = " t_incsalary.year = #{params[:year]} "
if params[:type].to_s == '1'
    search += " and t_incsalary.j18code in (1,2,3,4,5,6) "
    search += " and t_incsalary.level <= 99 "
    search += " and t_incsalary.flagcal = '1' "
elsif params[:type].to_s == '2'
    search += " and t_incsalary.level <= 99 "       
    search += " and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.wsdcode is not null "
end
search += " and cgrouplevel.ccode in (34,35)"#(21,22) "
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
if params[:type].to_s == '1'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
elsif params[:type].to_s == '2'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.wsdcode as sdcode,cprovince.provcode,t_incsalary.wseccode as seccode,t_incsalary.wjobcode as jobcode,t_incsalary.level "
end
sql = "select #{select} from t_incsalary #{str_join} where #{search} "
if params[:type].to_s == '1'
    sql += " group by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
    sql += " order by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level"
elsif params[:type].to_s == '2'
    sql += " group by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level "
    sql += " order by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level"    
end

rs = TIncsalary.find_by_sql(sql)
for i in 0...rs.length
    if i == 0
        records.push([
            "<b>#{title_hd(rs[i].sdcode)}</b>",
            "",
            "",
            "",
            "",
            ""
        ])
        
        if rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0" and rs[i].seccode.to_s != ""
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0" and rs[i].jobcode.to_s != ""
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s
            
            rs_job = begin
                Cjob.find(rs[i - 1].jobcode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{rs_job.jobname if rs_job != ""}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s
            rs_sec =begin
                Csection.find(rs[i - 1].seccode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{"#{rs_sec.shortname}#{rs_sec.secname}" if rs_sec != ""}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
            records.push([
                "รวม #{title_hd(rs[i - 1].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0            
        end
        

        if rs[i].sdcode != rs[i - 1].sdcode
            records.push([
                "<b>#{title_hd(rs[i].sdcode)}</b>",
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].seccode != rs[i - 1].seccode and rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode != rs[i - 1].jobcode and rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    end
    sd_n += rs[i].n.to_i
    sd_sal += rs[i].salary.to_i.ceil
    sd_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sd_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sd_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    sec_n += rs[i].n.to_i
    sec_sal += rs[i].salary.to_i.ceil
    sec_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sec_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sec_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    job_n += rs[i].n.to_i
    job_sal += rs[i].salary.to_i.ceil
    job_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    job_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    job_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    total_n += rs[i].n.to_i
    total_sal += rs[i].salary.to_i.ceil
    total_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    total_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    total_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    
    rs_group = Cgrouplevel.find(rs[i].level)
    records.push([
        {:content => "ประเภท#{rs_group.gname} ระดับ#{rs_group.clname}",:padding_left =>50},
        number_with_delimiter(rs[i].n),
        number_with_delimiter(rs[i].salary.to_i.ceil),
        number_to_currency(rs[i].salary.to_i*(params[:percent].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent2].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent3].to_f / 100),:unit => "")
    ])
    
    
    
    if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "รวม #{rs_job.jobname}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0         
        end
        if rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "รวม #{rs_sec.shortname}#{rs_sec.secname}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
        if rs[i].sdcode.to_s != "0"
            records.push([
                "รวม #{title_hd(rs[i].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
    end
    
end
pdf.font_size 10
pdf.table(
    [
        ["ประเภท/ระดับ","จำนวนคน","เงินเดือน","ร้อยละ #{"%.2f" % params[:percent]}","ร้อยละ #{"%.2f" % params[:percent2]}","ร้อยละ #{"%.2f" % params[:percent3]}"],
        *(records)
    ],
    :header => true,:position => :center,:column_widths => [250,60,60,60,60,60],
    :cell_style => { :inline_format => true }
) do
    row(0).style :align => :center
end


#################################################        3.กลุ่มวิชาการและทั่วไป
pdf.text " 3.กลุ่มวิชาการและทั่วไป"
records = []
search = " t_incsalary.year = #{params[:year]} "
if params[:type].to_s == '1'
    search += " and t_incsalary.j18code in (1,2,3,4,5,6) "
    search += " and t_incsalary.level <= 99 "
    search += " and t_incsalary.flagcal = '1' "
elsif params[:type].to_s == '2'
    search += " and t_incsalary.level <= 99 "       
    search += " and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.wsdcode is not null "
end
search += " and cgrouplevel.ccode in (51,52,53,54,31,32,33)"#(34,35)"#(21,22) "
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
if params[:type].to_s == '1'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
elsif params[:type].to_s == '2'
    select = " sum(t_incsalary.salary) as salary,count(*) as n,t_incsalary.wsdcode as sdcode,cprovince.provcode,t_incsalary.wseccode as seccode,t_incsalary.wjobcode as jobcode,t_incsalary.level "
end
sql = "select #{select} from t_incsalary #{str_join} where #{search} "
if params[:type].to_s == '1'
    sql += " group by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level "
    sql += " order by t_incsalary.sdcode,cprovince.provcode,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level"
elsif params[:type].to_s == '2'
    sql += " group by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level "
    sql += " order by t_incsalary.wsdcode,cprovince.provcode,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level"    
end

rs = TIncsalary.find_by_sql(sql)
for i in 0...rs.length
    if i == 0
        records.push([
            "<b>#{title_hd(rs[i].sdcode)}</b>",
            "",
            "",
            "",
            "",
            ""
        ])
        
        if rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0" and rs[i].seccode.to_s != ""
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0" and rs[i].jobcode.to_s != ""
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s
            
            rs_job = begin
                Cjob.find(rs[i - 1].jobcode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{rs_job.jobname if rs_job != ""}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s
            rs_sec =begin
                Csection.find(rs[i - 1].seccode)
            rescue
                ""
            end
            records.push([
                {:content => "รวม #{"#{rs_sec.shortname}#{rs_sec.secname}" if rs_sec != ""}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
            records.push([
                "รวม #{title_hd(rs[i - 1].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0            
        end
        

        if rs[i].sdcode != rs[i - 1].sdcode
            records.push([
                "<b>#{title_hd(rs[i].sdcode)}</b>",
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].seccode != rs[i - 1].seccode and rs[i].seccode.to_s != "" and rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "<u>#{rs_sec.shortname}#{rs_sec.secname}</u>",:padding_left => 20},
                "",
                "",
                "",
                "",
                ""
            ])
        end
        
        if rs[i].jobcode != rs[i - 1].jobcode and rs[i].jobcode.to_s != "" and rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "<u>#{rs_job.jobname}</u>",:padding_left => 40},
                "",
                "",
                "",
                "",
                ""
            ])
        end
    end
    sd_n += rs[i].n.to_i
    sd_sal += rs[i].salary.to_i.ceil
    sd_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sd_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sd_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    sec_n += rs[i].n.to_i
    sec_sal += rs[i].salary.to_i.ceil
    sec_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    sec_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    sec_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    job_n += rs[i].n.to_i
    job_sal += rs[i].salary.to_i.ceil
    job_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    job_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    job_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    total_n += rs[i].n.to_i
    total_sal += rs[i].salary.to_i.ceil
    total_percent1 += rs[i].salary.to_i*(params[:percent].to_f / 100)
    total_percent2 += rs[i].salary.to_i*(params[:percent2].to_f / 100)
    total_percent3 += rs[i].salary.to_i*(params[:percent3].to_f / 100)
    
    rs_group = Cgrouplevel.find(rs[i].level)
    records.push([
        {:content => "ประเภท#{rs_group.gname} ระดับ#{rs_group.clname}",:padding_left =>50},
        number_with_delimiter(rs[i].n),
        number_with_delimiter(rs[i].salary.to_i.ceil),
        number_to_currency(rs[i].salary.to_i*(params[:percent].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent2].to_f / 100),:unit => ""),
        number_to_currency(rs[i].salary.to_i*(params[:percent3].to_f / 100),:unit => "")
    ])
    
    
    
    if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
            rs_job = Cjob.find(rs[i].jobcode)
            records.push([
                {:content => "รวม #{rs_job.jobname}",:padding_left => 40},
                number_with_delimiter(job_n),
                number_with_delimiter(job_sal.to_i.ceil),
                number_with_delimiter("%.2f" % job_percent1),
                number_with_delimiter("%.2f" % job_percent2),
                number_with_delimiter("%.2f" % job_percent3)
            ])
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0         
        end
        if rs[i].seccode.to_s != "0"
            rs_sec = Csection.find(rs[i].seccode)
            records.push([
                {:content => "รวม #{rs_sec.shortname}#{rs_sec.secname}",:padding_left => 20},
                number_with_delimiter(sec_n),
                number_with_delimiter(sec_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sec_percent1),
                number_with_delimiter("%.2f" % sec_percent2),
                number_with_delimiter("%.2f" % sec_percent3)
            ])
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
        if rs[i].sdcode.to_s != "0"
            records.push([
                "รวม #{title_hd(rs[i].sdcode)}",
                number_with_delimiter(sd_n),
                number_with_delimiter(sd_sal.to_i.ceil),
                number_with_delimiter("%.2f" % sd_percent1),
                number_with_delimiter("%.2f" % sd_percent2),
                number_with_delimiter("%.2f" % sd_percent3)
            ])
            sd_n = 0
            sd_sal = 0
            sd_percent1 = 0
            sd_percent2 = 0
            sd_percent3 = 0
            
            sec_n = 0
            sec_sal = 0
            sec_percent1 = 0
            sec_percent2 = 0
            sec_percent3 = 0
            
            job_n = 0
            job_sal = 0
            job_percent1 = 0
            job_percent2 = 0
            job_percent3 = 0  
        end
    end
    
end

records.push([
    "<b>รวมทั้งหมด</b>",
    "<b>#{number_with_delimiter(total_n)}</b>",
    "<b>#{number_with_delimiter(total_sal.to_i.ceil)}</b>",
    "<b>#{number_with_delimiter("%.2f" % total_percent1)}</b>",
    "<b>#{number_with_delimiter("%.2f" % total_percent2)}</b>",
    "<b>#{number_with_delimiter("%.2f" % total_percent3)}</b>"
])
pdf.font_size 10
pdf.table(
    [
        ["ประเภท/ระดับ","จำนวนคน","เงินเดือน","ร้อยละ #{"%.2f" % params[:percent]}","ร้อยละ #{"%.2f" % params[:percent2]}","ร้อยละ #{"%.2f" % params[:percent3]}"],
        *(records)
    ],
    :header => true,:position => :center,:column_widths => [250,60,60,60,60,60],
    :cell_style => { :inline_format => true }
) do
    row(0).style :align => :center
end

