pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 12
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
#######################
pdf.text "<u>ชื่อ-สกุลเดิม</u>",:inline_format => true
records = []
@rs_pischgname.each do |u|
    dt = u.chgdate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    records.push([
        dt_th,
        u.prefix,
        u.fname,
        u.lname,
        u.ref
    ])
end
if records.length > 0
    pdf.move_down(10)
    pdf.table(
        [
            ["วันที่เปลี่ยน","คำนำหน้า","ชื่อเดิม","นามสกุล","เอกสารอ้างอิง"],*(records)
        ],
        :cell_style => {
            :borders => []
        },
        :width => 440
    ) do
        row(0).style :borders => [:bottom,:top]
        row(-1).style :borders => [:bottom]
    end
    pdf.move_down(20)
end

######################
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
    pdf.move_down(10)
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

##########################Page 2
chk_upd = [600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,626,627]
chk_percent = [602,603,604,605]
chk_percent_val = [0.5,1,1.5,2]
records = []
@rs_poshis_old.each do |u|
    dt = u.forcedate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    idx = chk_percent.index(u.updcode.to_i)
    if !idx.nil?
        row2 = "เลื่อนขั้นเงินเดือน (#{chk_percent_val[idx.to_i]} ขั้น)  "
    elsif idx.nil? and u.updcode.to_i == 626
        row2 = "เลื่อนเงินเดือน(#{u.uppercent}%)"
    else
        row2 = "#{u.updname} "  
    end
    if !chk_upd.include?(u.updcode.to_i)
        row2 += "#{[u.pospre,u.posname].join("")} #{u.c} "
        row2 += "#{u.jobname} " 
        row2 += "#{u.secshort}#{u.secname} "     
        row2 += "#{[u.sdpre,u.subdeptname].join("")} #{short_title_head_subdept(u.sdcode)} " 
        row2 += "#{u.dpre}#{u.division} "
        row2 += "#{u.deptname} "
    end
    salary = ""
    if u.salary.to_i != 0
        salary = number_with_delimiter(u.salary.to_i.ceil)
    end
    records.push([
        dt_th,row2,u.posid,u.c,salary,u.refcmnd
    ])
end

if records.length > 0
    pdf.start_new_page
    pdf.text "<b>ตำแหน่งและอัตราเงินเดือน</b>", :align => :center, :inline_format => true 
    row = "ชื่อ  #{@rs_personel.prefix}#{@rs_personel.fname} #{@rs_personel.lname}                  ระดับ  #{@rs_personel.clname}               #{@rs_pisj18.minname}    กรม #{@rs_pisj18.deptname}"
    pdf.text row
    pdf.table(
        [
            ["วัน เดือน ปี","ตำแหน่ง","เลขที่ <br />ตำแหน่ง","ระดับ","อัตรา<br />เงินเดือน","เอกสารอ้างอิง"],*(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [80,160,60,60,70,160]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
    
end

########################## page 3
records = []
@rs_poshis.each do |u|
    dt = u.forcedate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    idx = chk_percent.index(u.updcode.to_i)
    if !idx.nil?
        row2 = "เลื่อนขั้นเงินเดือน (#{chk_percent_val[idx.to_i]} ขั้น)  "
    elsif idx.nil? and u.updcode.to_i == 626
        row2 = "เลื่อนเงินเดือน(#{u.uppercent}%)"
    else
        row2 = "#{u.updname} "  
    end
    
    if !chk_upd.include?(u.updcode.to_i)
        row2 += "#{[u.pospre,u.posname].join("")} #{u.clname} "
        row2 += "#{u.jobname} " 
        row2 += "#{u.secshort}#{u.secname} "     
        row2 += "#{[u.sdpre,u.subdeptname].join("")} #{short_title_head_subdept(u.sdcode)} " 
        row2 += "#{u.dpre}#{u.division} "
        row2 += "#{u.deptname} "     
    end
    salary = ""
    if u.salary.to_i != 0
        salary = number_with_delimiter(u.salary.to_i.ceil)
    end
    records.push([
        dt_th,
        row2,
        u.gname,
        u.clname,
        u.posid,
        salary,
        u.refcmnd
    ])
end

if records.length > 0
    pdf.start_new_page
    pdf.text "<b>ตำแหน่งและอัตราเงินเดือน</b>", :align => :center, :inline_format => true 
    row = "ชื่อ  #{@rs_personel.prefix}#{@rs_personel.fname} #{@rs_personel.lname}                  ระดับ  #{@rs_personel.clname}               #{@rs_pisj18.minname}    กรม #{@rs_pisj18.deptname}"
    pdf.text row
    pdf.table(
        [
            ["วัน เดือน ปี","ตำแหน่ง","ตำแหน่ง<br />ประเภท","ระดับ","เลขที่ <br />ตำแหน่ง","เงินเดือน","เอกสารอ้างอิง"],*(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [60,150,70,60,60,60,140]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
end
###########################################page 4
records = []
i = 0
@rs_education.each do |u|
    i += 1
    dt = u.enddate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    records.push([
        i,
        dt_th,
        u.qualify,
        u.major,
        u.institute,
        u.coname
    ])
end
if records.length > 0
    pdf.start_new_page
    pdf.text "<b><u>ข้อมูลการศึกษา</u></b>",:align => :center,:inline_format => true
    pdf.move_down(10)
    pdf.table(
        [
            ["ลำดับ","วันที่จบ","วุฒิการศึกษา","สาขา/วิชาเอก","สถาบัน","ไทย"],
            *(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [50,80,130,130,120,70]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
    
end
#############################################page 5
records = []
@rs_pisinsig.each do |u|
    
    dt1 = u.kitjadate
    dt_th1 = ""
    if !dt1.nil?
      dt_th1 = "#{dt1.day} #{month_th_short[dt1.mon.to_i]} #{dt1.year + 543}"
    end
    
    dt2 = u.recdate
    dt_th2 = ""
    if !dt2.nil?
      dt_th2 = "#{dt2.day} #{month_th_short[dt2.mon.to_i]} #{dt2.year + 543}"
    end
    
    dt3 = u.retdate
    dt_th3 = ""
    if !dt3.nil?
      dt_th3 = "#{dt3.day} #{month_th_short[dt3.mon.to_i]} #{dt3.year + 543}"
    end
    
    records.push([
        u.dcyear,
        u.dcname,
        dt_th1,
        u.book,
        u.section,
        u.pageno,
        u.seq,
        dt_th2,
        dt_th3,
        "#{[u.pospre,u.posname].join("")} #{u.c}"
    ])
end

if records.length > 0
    pdf.start_new_page
    pdf.text "<b><u>ประวัติการรับเครื่องราชย์อิสริยาภรณ์</u></b>",:align => :center,:inline_format => true
    pdf.move_down(10)
    pdf.table(
        [
            ["ปี","เครื่องราชย์อิสริยาภรณ์","วันที่ลงราชกิจจา","เล่มที่","ตอนที่","หน้าที่","ลำดับที่","วันที่รับเหรียญ","วันที่คืนหรียญ","ตำแหน่ง"],
            *(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [30,110,70,35,35,35,35,70,70,110]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
end
######################################page 6
records = []
i = 0
@rs_pistrainning.each do |u|
    i += 1
    
    dt1 = u.begindate
    dt_th1 = ""
    if !dt1.nil?
      dt_th1 = "#{dt1.day} #{month_th_short[dt1.mon.to_i]} #{dt1.year + 543}"
    end
    
    dt2 = u.enddate
    dt_th2 = ""
    if !dt2.nil?
      dt_th2 = "#{dt2.day} #{month_th_short[dt2.mon.to_i]} #{dt2.year + 543}"
    end
    
    records.push([
        i,
        dt_th1,
        dt_th2,
        u.cource,
        u.institute,
        u.coname
    ])
end

if records.length > 0
    pdf.start_new_page
    pdf.text "<b><u>ข้อมูลการอบรม/ดูงาน</u></b>",:align => :center,:inline_format => true
    pdf.move_down(10)
    pdf.table(
        [
            ["ลำดับ","ตั้งแต่วันที่","ถึงวันที่","หลักสูตร","สถาบัน","ประเทศ"],
            *(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [40,80,80,160,160,80]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
end


###################################page 7
records = []
i = 0
@rs_pispunish.each do |u|
    i += 1
    dt = u.forcedate
    dt_th = ""
    if !dt.nil?
      dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    end
    records.push([
        i,
        dt_th,
        u.description,
        u.pnname,
        u.cmdno
    ])
end
if records.length > 0
    pdf.start_new_page
    pdf.text "<b><u>ข้อมูลการรับโทษทางวินัย</u></b>",:align => :center,:inline_format => true
    pdf.move_down(10)
    pdf.table(
        [
            ["ลำดับ","วันที่","กรณีความผิด","โทษที่ได้รับ","คำสั่ง"],
            *(records)
        ],
        :cell_style => {
            :borders => [:left,:right],
            :inline_format => true 
        },
        :column_widths => [40,80,200,140,140]
    ) do
        row(0).style :align => :center, :borders => [:left,:right,:top,:bottom]
        row(-1).style :borders => [:bottom,:left,:right]
    end
end












pdf.repeat :all, :dynamic => true do
    pdf.move_down(-45)
    pdf.text "<b>ทะเบียนประวัติข้าราชการ</b>", :align => :center, :inline_format => true
    pdf.text "<b>วันที่พิมพ์รายงาน #{@dt}</b>", :align => :center, :inline_format => true
end







