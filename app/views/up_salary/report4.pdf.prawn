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
    when "1" then "วันที่ 1 เมษายน #{year[0..3]}"
    when "2" then "วันที่ 1 ตุลาคม #{year[0..3]}"
    else ""
end

pdf.repeat :all, :dynamic => true do
    pdf.bounding_box [570, 595], :width => 200, :height => 52 do
        pdf.text "เอกสารหมายเลข 6",:align => :right, :valign => :center
    end
    pdf.bounding_box [1, 570], :width => 782, :height => 102 do
        pdf.text "บัญชีแจ้งผลพิจารณาเลื่อนเงินเดือนข้าราชการดำรงตำแหน่ง ประเภทอำนวยการ ระดับต้น และสูง", :align => :center
        pdf.text "ส่วนราชการ #{@subdeptname} ปี #{year[0..3]} ครั้งที่  #{year[4]} #{date}",:align => :center
    end
    if pdf.page_number != pdf.page_count
        pdf.stroke {
            pdf.line [18, 0], [782, 0]
            pdf.line [18, 0], [18, 100]
            pdf.line [53, 0], [53, 100]
            pdf.line [165, 0], [165, 100]
            pdf.line [250, 0], [250, 100]
            pdf.line [341, 0], [341, 100]
            pdf.line [391, 0], [391, 100]
            pdf.line [464, 0], [464, 100]
            pdf.line [504, 0], [504, 100]
            pdf.line [548, 0], [548, 100]
            pdf.line [592, 0], [592, 100]
            pdf.line [633, 0], [633, 100]
            pdf.line [677, 0], [677, 100]
            pdf.line [721, 0], [721, 100]
            pdf.line [764, 0], [764, 100]
        }
    end    
end

records = []
for i in 0...@records.length do
    records.push(
        [
            @records[i][:i],
            @records[i][:name],
            @records[i][:pid],
            @records[i][:posname],
            @records[i][:gname],
            @records[i][:clname],
            @records[i][:posid],
            (@records[i][:name].to_s == "")? "" : params[:fiscal_year],
            (@records[i][:name].to_s == "")? "" : params[:round],
            @records[i][:salary],
            @records[i][:midpoint],
            @records[i][:score],
            @records[i][:note1]
        ]
    )
end
pdf.font_size 10

pdf.table(
    [
        [
            "ลำดับที่","ชื่อ-นามสกุล","เลขประจำตัวประชาชน","ตำแหน่ง/สังกัด","ประเภท","ระดับ",
            "ตำแหน่ง<br />เลขที่","ปี","ครั้งที่<br />ประเมิน","เงินเดือน<br />เดิม","ฐานในการ<br />คำนวณ",
            "คะแนน<br />รวม","หมายเหตุ"
        ],
        *(records)
    ],
    :header => true,
    :position => :center,
    :column_widths => [35,113,85,90,50,74,40,44,44,40,44,44,44],
    :cell_style => {:inline_format => true,:borders => [:left, :right] }
) do
    row(-1).style :borders => [:bottom, :left, :right]
    row(0).style :align => :center,:borders => [:top,:bottom,:left,:right]
end
