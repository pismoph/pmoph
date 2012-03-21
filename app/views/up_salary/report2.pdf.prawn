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
    pdf.bounding_box [1, 570], :width => 782, :height => 102 do
        pdf.text "บัญชีแจ้งผลพิจารณาเลื่อนเงินเดือนข้าราชการ ปี #{year[0..3]} ครั้งที่  #{year[4]} #{date} ", :align => :center
    end
    if pdf.page_number != pdf.page_count
        pdf.stroke {
            pdf.line [0, 0], [782, 0]
            pdf.line [0, 0], [0, 100]
            pdf.line [35, 0], [35, 100]
            pdf.line [148, 0], [148, 100]
            pdf.line [233, 0], [233, 100]
            pdf.line [323, 0], [323, 100]
            pdf.line [373, 0], [373, 100]
            pdf.line [447, 0], [447, 100]
            pdf.line [487, 0], [487, 100]
            pdf.line [531, 0], [531, 100]
            pdf.line [575, 0], [575, 100]
            pdf.line [615, 0], [615, 100]
            pdf.line [650, 0], [650, 100]
            pdf.line [694, 0], [694, 100]
            pdf.line [738, 0], [738, 100]
            pdf.line [782, 0], [782, 100]
            pdf.line [826, 0], [826, 100]
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
            @records[i][:salary],
            @records[i][:midpoint],
            @records[i][:calpercent],
            @records[i][:score],
            @records[i][:diff],
            @records[i][:newsalary],
            @records[i][:addmoney]
        ]
    )
end
pdf.font_size 12

pdf.table(
    [
        [
            "ลำดับที่","ชื่อ-นามสกุล","เลขประจำตัวประชาชน","ตำแหน่ง/สังกัด","ประเภท","ระดับ",
            "ตำแหน่ง<br />เลขที่","เงินเดือน<br />เดิม","ฐานใน<br />การ<br />คำนวณ","ร้อยละที่<br />ได้เลื่อน","คะแนน<br />รวม",
            "จำนวน<br />เงินที่<br />ได้เลื่อน","เงิน<br />เดือนที่<br />ได้รับ","ค่าตอบ<br />แทน<br />พิเศษ"
        ],
        *(records)
    ],
    :header => true,
    :position => :center,
    :column_widths => [35,113,85,90,50,74,40,44,44,40,35,44,44,44],
    :cell_style => {:inline_format => true,:borders => [:left, :right] }
) do
    row(-1).style :borders => [:bottom, :left, :right]
    row(0).style :align => :center,:borders => [:top,:bottom,:left,:right]
end
