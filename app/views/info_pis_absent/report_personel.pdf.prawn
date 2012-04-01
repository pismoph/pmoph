# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14
dt = Time.now
dt_th = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
pdf.repeat :all, :dynamic => true do
    pdf.move_down(-40)
    pdf.text "<b>รายการสรุปวันลา</b>", :align => :center, :inline_format => true
    pdf.text "วันที่พิมรายงาน #{dt_th}", :align => :center
end
j18 = @rs_j18[0]
person = @rs_personel[0]
pdf.text "ชื่อ  #{"#{j18.prefix}#{j18.fname} #{j18.lname}".strip}"

pdf.text "ตำแหน่งเลขที่  #{j18.posid}        ตำแหน่งสายงาน  #{"#{j18.pospre}#{j18.posname}".strip} #{j18.clname}        เงินเดือน  #{number_with_delimiter(j18.salary.to_i.ceil)} บาท"
row = ""
row = "งาน#{j18.jobname}" if j18.jobcode.to_s != ""
row += "  #{"#{j18.secshort}#{j18.secname}".strip}" if j18.seccode.to_s != ""
row += "  #{"#{j18.subdeptpre}#{j18.subdeptname}"}  #{long_title_head_subdept(j18.sdcode)}" if j18.sdcode.to_s != ""
row += "  #{"#{j18.dpre}#{j18.division}".strip}"
pdf.text "ต้นสังกัด  #{row}"
row = ""
row = "งาน#{person.jobname}#{person.jobcode}" if person.jobcode.to_s != ""
row += "  #{"#{person.secshort}#{person.secname}".strip}" if person.seccode.to_s != ""
row += "  #{"#{person.subdeptpre}#{person.subdeptname}"}  #{long_title_head_subdept(person.sdcode)}" if person.sdcode.to_s != ""
row += "  #{"#{person.dpre}#{person.division}".strip}"
pdf.text "ปฎิบัติงานจริง  #{row}"

pdf.table(
    [
        [
            "จำนวนวันลาพักผ่อน","1 ต.ค.","#{person.vac1oct} วัน"
        ],
        [
            "","คงเหลือ","#{person.totalabsent} วัน"
        ]
    ],
    :cell_style => {:borders => []}
)
pdf.move_down(10)
data = ActiveSupport::JSON.decode(params[:data])
if data["report_type"].to_s == "1"
    pdf.text "<u>วันลาปีงบประมาณ #{data["fiscal_year"]}</u>", :inline_format => true
    str_join = "left join cabsenttype on pisabsent.abcode = cabsenttype.abcode"
    select = "pisabsent.*,cabsenttype.abtype"
    search = " id = '#{person.id}' and begindate between '#{data["fiscal_year"].to_i - 544}-10-01' and '#{data["fiscal_year"].to_i - 543}-09-30'"
    rs = Pisabsent.select(select).joins(str_join).find(:all, :conditions => search,:order => "id, abcode, begindate")
    
elsif data["report_type"].to_s == "2"
    pdf.text "<u>วันลาปี #{data["fiscal_year"]}</u>", :inline_format => true
    str_join = "left join cabsenttype on pisabsent.abcode = cabsenttype.abcode"
    select = "pisabsent.*,cabsenttype.abtype"
    search = " id = '#{person.id}' and begindate between '#{data["fiscal_year"].to_i - 543}-01-01' and '#{data["fiscal_year"].to_i - 543}-12-31'"
    rs = Pisabsent.select(select).joins(str_join).find(:all, :conditions => search,:order => "id, abcode, begindate")
end
records = []
rs.each do |u|
    dt1 = u.begindate
    dt_th1 = begin "#{dt1.day} #{month_th_short[dt1.mon.to_i]} #{dt1.year + 543}" rescue "" end
    
    dt2 = u.enddate
    dt_th2 = begin "#{dt2.day} #{month_th_short[dt2.mon.to_i]} #{dt2.year + 543}" rescue "" end
    flag = case u.flagcount.to_s
    when "1" then "นับครั้ง"
    when "0" then "ไม่นับครั้ง"
    else ""
    end      
    
    records.push([
        dt_th1,
        dt_th2,
        u.abtype,
        u.amount,
        flag
    ])
end
pdf.table([["เริ่มวันลา","ถึงวันที่","ประเภทการลา","จำนวนวัน","นับครั้ง/ไม่นับครั้ง"],*(records)],
    :header => true,
    :cell_style => {:borders => []}
) do
    row(lambda { |r|  cells[r, 0].content == "เริ่มวันลา" }).style :borders => [:top, :bottom]
    row(-1).style :borders => [:bottom]
end

dt = ""
if data["report_type"].to_s == "1"
    dt = "begindate between '#{data["fiscal_year"].to_i - 544}-10-01' and '#{data["fiscal_year"].to_i - 543}-09-30'"
elsif data["report_type"].to_s == "2"
    dt = "begindate between '#{data["fiscal_year"].to_i - 543}-01-01' and '#{data["fiscal_year"].to_i - 543}-12-31'"
end


rs = Pisabsent.select("distinct abcode").where("id = '#{person.id}' and #{dt} ")
i = 0
records = []
rs.each do |r|
  records.push([
    (r.abcode.to_s == "")? "" : begin Cabsenttype.find(r.abcode).abtype rescue "" end ,
    begin Pisabsent.sum("amount",:conditions => "id = '#{person.id}' and abcode = '#{r.abcode}' and #{dt}").to_f rescue "" end ,
    begin Pisabsent.count("flagcount",:conditions => "id = '#{person.id}' and abcode = '#{r.abcode}' and and #{dt} and flagcount = '1' ").to_i rescue "" end ,
  ])
end

pdf.move_down(20)
if data["report_type"].to_s == "1"
    pdf.text "สรุปวันลาปีงบประมาณ #{data["fiscal_year"]}"
elsif data["report_type"].to_s == "2"
    pdf.text "สรุปวันลาปี #{data["fiscal_year"]}"
end


pdf.table([["ประเภทการลา","จำนวนวัน","ครั้ง"],*(records)],
    :header => true,
    :cell_style => {:borders => []}
) do
    row(lambda { |r|  cells[r, 0].content == "ประเภทการลา" }).style :borders => [:top, :bottom]
    row(-1).style :borders => [:bottom]
end


