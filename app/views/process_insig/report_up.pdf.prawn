# encoding: utf-8
def date_process_insig(dt)
  begin
    "#{dt.day}#{month_th_short[dt.month]}#{(dt.year+543).to_s[-2..-1]}"
  rescue
    nil
  end
end

pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14

pdf.repeat(:all, :dynamic => true) do
    pdf.move_down(-152)
    pdf.text "<b>บัญชีแสดงคุณสมบัติของข้าราชการ ซึ่งเสนอขอพระราชทาน เครื่องราชอิสริยาภรณ์ ประจำปี พ.ศ. #{params[:year]}</b>",:inline_format => true,:align => :center
    pdf.text "<b>#{@subdeptname}</b>",:inline_format => true,:align => :center
    pdf.text "แบบ ขร 4/#{params[:year][-2..-1]}",:align => :right
    #######################
    ##772
    pdf.bounding_box [0, 508], :width => 30, :height => 104 do
        pdf.text "อันดับ",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    pdf.bounding_box [30, 508], :width => 140, :height => 104 do
        pdf.text "ชื่อตัว - ชื่อนามสกุล",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    #########################
    pdf.bounding_box [170, 508], :width => 230, :height => 26 do
        pdf.text "เป็นข้าราชการ",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [170, 482], :width => 50, :height => 78 do
        pdf.text "ประเภท",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [220, 482], :width => 80, :height => 78 do
        pdf.text "ระดับ",:align => :center, :valign => :center
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [300, 482], :width => 50, :height => 78 do
        pdf.text "ตั้งแต่<br />วัน เดือน ปี",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    
    pdf.bounding_box [350, 482], :width => 50, :height => 78 do
        pdf.text "เงินเดือน<br />ปัจจุบัน",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    #####################
    pdf.bounding_box [400, 508], :width => 140, :height => 104 do
        pdf.text "ตำแหน่ง ปัจจุบัน อตีต<br />เฉพาะปีที่ได้รับพระราชทาน<br />เครื่องราชอิสริยาภรณ์",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    #########################
    pdf.bounding_box [540, 508], :width => 132, :height => 26 do
        pdf.text "เครื่องราชอิสริยาภรณ์",:align => :center, :valign => :center
        pdf.stroke_bounds
    end

    pdf.bounding_box [540, 482], :width => 50, :height => 78 do
        pdf.text "ที่ได้รับ<br />จากชั้นสูง<br />ไปชั้นรอง",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [590, 482], :width => 50, :height => 78 do
        pdf.text "วัน เดือน ปี<br />(5ธ.ค...)",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    pdf.bounding_box [640, 482], :width => 32, :height => 78 do
        pdf.text "ขอ<br />ครั้ง<br />นี้",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end    
    #########################
    pdf.bounding_box [672, 508], :width => 100, :height => 104 do
        pdf.text "หมายเหตุ",:align => :center, :valign => :center,:inline_format => true
        pdf.stroke_bounds
    end
    #######################
    if pdf.page_number != pdf.page_count
        pdf.stroke {
            pdf.line [0, 0], [0, 480]
            pdf.line [30, 0], [30, 480]
            pdf.line [170, 0], [170, 480]
            pdf.line [220, 0], [220, 480]
            pdf.line [300, 0], [300, 480]
            pdf.line [350, 0], [350, 480]
            pdf.line [400, 0], [400, 480]
            pdf.line [540, 0], [540, 480]
            pdf.line [590, 0], [590, 480]
            pdf.line [640, 0], [640, 480]
            pdf.line [672, 0], [672, 480]
            pdf.line [772, 0], [772, 480]
            pdf.line [0, 0], [772, 0]        
        }
    end
end

records = []
n = 0
str_join = " left join cdecoratype on  pisinsig.dccode = cdecoratype.dccode "
str_join += " left join cgrouplevel on pisinsig.c = cgrouplevel.ccode "
str_join += " left join cposition on pisinsig.poscode = cposition.poscode "
select = "cdecoratype.shortname as dcname,gname,clname,cname,posname,pisinsig.note,dcyear,c"
c_tmp = [1,2,3,4,5,6,7,8,9,10,11,12]
for i in 0...@records.length do
    n += 1
    u = @records[i]
    records.push([
        "#{n}.",
        "#{u.prefix}#{u.fname}  #{u.lname}",
        u.gname,
        u.clname,
        date_process_insig(u.leveldate),
        number_with_delimiter(u.salary.to_i),
        u.posname,
        "",
        "",
        u.dcname,
        "#{u.note1} #{u.note2}"
    ])
    
    rs = Pisinsig.select(select).joins(str_join).where("id = '#{u.id}'").order("dcyear")
    for j in 0...rs.length
        records.push([
            "",
            "",
            "",
            "",
            "",
            "",
            "#{rs[j].posname} #{ ( c_tmp.include?(rs[j].c.to_i) )?  rs[j].c : rs[j].clname}",
            rs[j].dcname,
            "5ธ.ค.#{rs[j].dcyear.to_s[-2..-1]}",
            "",
            rs[j].note
        ])
    end
end




pdf.table(records, :position => :left,:column_widths => [30,140,50,80,50,50,140,50,50,32,100], :cell_style => { :borders => [:left,:right],:inline_format => true })do
    column(0).style :align => :right
    row(-1).style :borders => [:bottom,:right,:left]
end
pdf.move_down(5)
pdf.table(
    [
        [
            "ขอรับรองว่า รายละเอียดข้างต้อนและเป็นผู้มีคุณสมบัติตามระเบียบ<br />ว่าด้วยการขอพระราชทานเครื่อราชอิสริยาภรณ์ พ.ศ.2536 ข้อ 8,10,19(3),22<br /><br /><br />ผู้ขอพระราชทาน"
        ]
    ],
    :position => :right,
    :cell_style => { :inline_format => true,:align => :center,:borders => [] },
    :column_widths => [552]
)



##########################################################
pdf.repeat(:all, :dynamic => true) do
    string = "หน้า <page> / <total>"
    options = { :at => [pdf.bounds.right - 160, 565],
              :width => 150,
             :align => :right,
              :start_count_at => 1,
               }
    pdf.number_pages string, options
end
