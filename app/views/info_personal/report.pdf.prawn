pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 12
pdf.text "<b>ทะเบียนประวัติข้าราชการ</b>", :align => :center, :inline_format => true
pdf.text "<b>วันที่พิมพ์รายงาน #{@dt}</b>", :align => :center, :inline_format => true
pdf.move_down(35)
pdf.text "<u><b>ข้อมูลการปฎิบัติราชการ</b></u>", :inline_format => true
pdf.move_down(5)
row = "ชื่อ  #{@rs_personel.prefix}#{@rs_personel.fname} #{@rs_personel.lname}             วันเกิด  #{@bt}             "
row += "อายุ #{"#{@rs_personel.age_year} ปี" if @rs_personel.age_year.to_i != 0} "
row += "#{"#{@rs_personel.age_month} เดือน" if @rs_personel.age_month.to_i != 0} "
row += "#{"#{@rs_personel.age_day} วัน" if @rs_personel.age_day.to_i != 0}             "
row += " วันครบเกษียณ  #{@rt}"
pdf.text  row
sex = case @rs_personel.sex.to_s
    when "1" then "ชาย"
    when "2" then "หญิง"
end

row = "เพศ  #{sex}             ตำแหน่งเลขที่ครอง  #{@rs_pisj18.posid}              "
row += "ตำแหน่งสายงาน  #{[@rs_pisj18.pospre,@rs_pisj18.posname].join("")}  ประเภท#{@rs_pisj18.gname}"
row += "ระดับ#{@rs_pisj18.clname}"
pdf.text row

row = "เงินเดือน  #{number_with_delimiter(@rs_personel.salary.to_i.ceil)}              "
row += "ตำแหน่งบริหาร  #{[@rs_pisj18.expre,@rs_pisj18.exname].join("")}"
pdf.text row

row = "สาขาความเชียวชาญ  #{[@rs_pisj18.eppre,@rs_pisj18.expert].join("")}              "
row += "ว./วช./ชช.  #{@rs_pisj18.ptname}"
pdf.text row

row = "ต้นสังกัด         #{[@rs_pisj18.secshort,@rs_pisj18.secname].join("")} #{[@rs_pisj18.sdpre,@rs_pisj18.subdeptname].join("")} #{@title_sd_j18}"
pdf.text row

row = "ปฎิบัติงานจริง  #{[@rs_personel.secshort,@rs_personel.secname].join("")} #{[@rs_personel.sdpre,@rs_personel.subdeptname].join("")} #{@title_sd_personel}"
pdf.text row

kbk = case @rs_personel.kbk.to_s
    when "1" then "สมัคร"
    when "0" then "ไม่สมัคร"
    else ""
end

dt1 = @rs_personel.appointdate
dt_th1 = ""
if !dt1.nil?
  dt_th1 = "#{dt1.day} #{month_th_short[dt1.mon.to_i]} #{dt1.year + 543}"
end
age1 = "#{"#{@rs_personel.appoint_year} ปี" if @rs_personel.appoint_year.to_i != 0}"
age1 += " #{"#{@rs_personel.appoint_month} เดือน" if @rs_personel.appoint_month.to_i != 0}"
age1 += " #{"#{@rs_personel.appoint_day} วัน" if @rs_personel.appoint_day.to_i != 0}"


dt2 = @rs_personel.deptdate
dt_th2 = ""
if !dt2.nil?
  dt_th2 = "#{dt2.day} #{month_th_short[dt2.mon.to_i]} #{dt2.year + 543}"
end
age2 = "#{"#{@rs_personel.dept_year} ปี" if @rs_personel.dept_year.to_i != 0}"
age2 += " #{"#{@rs_personel.dept_month} เดือน" if @rs_personel.dept_month.to_i != 0}"
age2 += " #{"#{@rs_personel.dept_day} วัน" if @rs_personel.dept_day.to_i != 0}"

dt3 = @rs_personel.cdate
dt_th3 = ""
if !dt3.nil?
  dt_th3 = "#{dt3.day} #{month_th_short[dt3.mon.to_i]} #{dt3.year + 543}"
end
age3 = "#{"#{@rs_personel.c_year} ปี" if @rs_personel.c_year.to_i != 0}"
age3 += " #{"#{@rs_personel.c_month} เดือน" if @rs_personel.c_month.to_i != 0}"
age3 += " #{"#{@rs_personel.c_day} วัน" if @rs_personel.c_day.to_i != 0}"

pdf.table(
    [
        ["สมาชิก กบข.",kbk,"",""],
        ["วันรับโอน",@getindate,"",""],
        ["วันที่บรรจุครั้งแรก/กลับ",dt_th1,"อายุราชการ",age1],
        ["วันเข้าสู่หน่วยงานปัจจุบัน",dt_th2,"เป็นระยะเวลา",age2],
        ["วันเข้าสู่ระดับปัจจุบัน",dt_th3,"เป็นระยะเวลา",age3],
        ["วุฒิในตำแหน่ง",[@rs_personel.qpre,@rs_personel.qualify].join(""),"สาขา/วิชาเอก",@rs_personel.major]
    ],
    :column_widths => [100,150,100,150],
    :cell_style => {
        :borders => []
    }
)
pdf.text "ได้รับเงินเพิ่มพิเศษ                                      จำนวน       #{number_with_delimiter(@rs_personel.spmny.to_i.ceil)}      บาท"
pdf.move_down(10)
#################
pdf.text "<b><u>ข้อมูลส่วนตัวและครอบครัว</u></b>",:inline_format => true
pdf.table(
    [
        ["เลขบัตรประชาชน","#{format_pid @rs_personel.pid}","หมู่เลือด",@rs_personel.bloodgroup,"",""],
        ["สถานะภาพ",@rs_personel.marital,"ศาสนา",@rs_personel.renname,"ภูมิลำเนา",[@rs_personel.provpre,@rs_personel.provname].join("")]
    ],
    :column_widths => [100,100,60,100,60,100],
    :cell_style => {
        :borders => []
    }
)
pdf.table(
    [
        ["ที่อยู่",@rs_personel.address1],
        ["",@rs_personel.address2]
    ],
    :cell_style => {
        :borders => []
    }
)
pdf.text "<u>ชื่อ-สกุลเดิม</u>",:inline_format => true
pdf.text "<u>บุคคลในครอบครัว</u>",:inline_format => true
records = []
i = 0
@rs_family.each do |u|
    i += 1
    dt = u.birthdate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    st = case u.status.to_s
        when "0" then "ถึงแก่กรรม"
        else ""
    end
    records.push([
        i,
        u.relname,
        ["#{u.prefix}#{u.fname}",u.lname].join(" "),
        dt_th,
        st
    ])
end
if @rs_family.length > 0
    pdf.table(
        [
            ["ลำดับ","ความสัมพันธ์","ชื่อ-นามสกุล","วันเกิด","สถานะ"],*(records)
        ],
        :column_widths => [40,100,100,100,100],
        :cell_style => {
            :borders => []
        }
    ) do
        row(0).style :borders => [:bottom,:top]
        row(-1).style :borders => [:bottom]
    end
end
pdf.start_new_page




pdf.text "<b>ทะเบียนประวัติข้าราชการ</b>", :align => :center, :inline_format => true
pdf.move_down(35)
pdf.text "sadasdas"








pdf.repeat :all, :dynamic => true do
    pdf.move_down(20)
    pdf.text "หนังสือแจ้งผลการเลื่อนเงินเดือน",:align => :center
    pdf.move_down(20)
end
