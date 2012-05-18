# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14
####################################################
pdf.repeat(:all, :dynamic => true) do
    pdf.move_down(-90)
    pdf.text "<b>ประวัติสำหรับเสนอขอพระราชทานเหรียญจักรพรรดิมาลา</b>",:size => 16, :inline_format => true,:align => :center
    pdf.move_down(20)
    str = "<b>ชื่อ</b>  #{@info[0].longprefix}#{@info[0].fname}  #{@info[0].lname}              "
    pos = "#{@info[0].posname}" if @info[0].posname.to_s != ""
    pos += " #{@info[0].clname}" if @info[0].clname.to_s != ""
    pos += " #{@info[0].eppre}#{@info[0].expert}" if @info[0].expert.to_s != ""
    pos += " (#{@info[0].ptname})" if @info[0].ptname.to_s != ""
    str += "<b>ตำแหน่ง</b>  #{pos}"
    pdf.text str, :inline_format => true
    str = begin Csubdept.find(@info[0].sdcode).full_name_mala rescue "" end
    str += begin " "+Cdept.find(@info[0].deptcode).deptname rescue "" end
    str += begin " "+Cministry.find(@info[0].mincode).minname rescue "" end
    pdf.text str
    birth_date = ""
    begin
        birth_date = @info[0].birthdate.split("-")
        birth_date = Time.new(birth_date[0].to_i,birth_date[1].to_i,birth_date[2].to_i)
    rescue
        birth_date = ""
    end
    appoint_date = begin
        dt = @info[0].appointdate.split("-")
        Time.new(dt[0].to_i + 25,dt[1].to_i,dt[2].to_i)
    rescue
        ""
    end
    pdf.text "เกิดวันที่  #{date_th(birth_date)} ได้รับราชการมาครบ 25 ปี เมื่อวันที่  #{date_th(appoint_date)}"
    #pdf.bounding_box([-10, 744], :width => 574, :height => 754) do
    #    pdf.stroke_bounds 
    #end
    
    if pdf.page_number != pdf.page_count
        pdf.stroke {
            pdf.line [0, 0.5], [552, 0.5]
            pdf.line [0, 0], [0, 200]
            pdf.line [70, 0], [70, 200]
            pdf.line [226, 0], [226, 200]
            pdf.line [316, 0], [316, 200]
            pdf.line [346, 0], [346, 200]
            pdf.line [396, 0], [396, 200]
            pdf.line [552, 0], [552, 200]
        }
    end
end



records = @records.collect{|u|
    str = ""
    str = u.minname if u.minname.to_s != ""
    str = "กรม#{u.deptname}" if u.deptname.to_s != ""
    str = "สป. สธ." if u.deptcode.to_s == "10"
    [
        date_th_short(u.forcedate),
        [u.pospre,u.posname," #{u.clname}"].join(""),
        str,
        u.age,
        number_with_delimiter(u.salary.to_i),
        u.refcmnd
    ]    
}
pdf.table(
           [["วัน เดือน ปี<br />ที่รับราชการ","ตำแหน่ง","กรมหรือกระทรวง","อายุ<br>ตัว","เงินเดือน","หมายเหตุ"],*(records)],
           :cell_style => {
               :inline_format => true,
                :borders => [:left,:right]
            },
           :position => :center,
           :column_widths => [70,156,90,30,50,156],
           :header => true
) do
    rows(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
    rows(-1).style :borders => [:left,:right,:bottom]
end
##################################################################
pdf.repeat(:all, :dynamic => true) do
    string = "หน้า <page> / <total>"
    options = { :at => [pdf.bounds.right - 160, 740],
              :width => 150,
             :align => :right,
              :start_count_at => 1,
               }
    pdf.number_pages string, options
end






