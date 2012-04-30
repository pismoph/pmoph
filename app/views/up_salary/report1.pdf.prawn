# encoding: utf-8
pdf.font_families.update(
    "THSarabunNew" => { :bold        => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Bold.ttf",
                        :italic      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew Italic.ttf",
                        :bold_italic => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew BoldItalic.ttf",
                        :normal      => "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf" })
pdf.font("THSarabunNew")
pdf.font_size 14

year = params[:year]
date = case year[4].to_s
    when "1" then "ณ  วันที่ 1 เมษายน #{year[0..3]}"
    when "2" then "ณ วันที่ 1 ตุลาคม #{year[0..3]}"
    else ""
end
pdf.repeat :all, :dynamic => true do
    pdf.bounding_box [0, 740], :width => 590, :height => 52 do
        pdf.text "รายละเอียดประกาศร้อยละของฐานในการคำนวณการเลื่อนเงินเดือน  #{date} ", :align => :center
        pdf.text @subdeptname,:align => :center
    end
end
records = []
@usesub_id.each do |u|
    i = 0
    TKs24usesubdetail.select("t_ks24usesubdetail.*,t_ks24usesub.*")
    .joins("left join t_ks24usesub on t_ks24usesubdetail.id = t_ks24usesub.id and t_ks24usesubdetail.year = t_ks24usesub.year")
    .find(:all,:conditions => "t_ks24usesubdetail.year = #{year} and t_ks24usesubdetail.id = #{u}", :order => "dno desc").each {|r|
        records.push(
            [
                (i == 0)? r[:usename] : "",
                r[:e_name],
                "#{r[:e_begin]} - #{r[:e_end]}",
                r[:up]
            ]
        )
        i += 1
    }
end
pdf.font_size 10
pdf.table(
            [["กลุ่มบริหารเงิน","ระดับ","ช่วงคะแนน","ร้อยละ"], *(records)],
            :header => true,
            :position => :center,:column_widths => [120,105,105,105],
            :cell_style => {:inline_format => true ,:borders => []}
) do
    column(0).style :borders => [:left]
    column(3).style :borders => [:right]
    row(0).style :align => :center,:borders => [:bottom,:top]
    row(0).column(0).style :borders => [:left,:top,:bottom]
    row(0).column(3).style :borders => [:right,:top,:bottom]
    row( row_length - 1).style :borders => [:bottom]
    row( row_length - 1).column(0).style :borders => [:left,:bottom]
    row( row_length - 1).column(3).style :borders => [:right,:bottom]
    row(lambda { |r|  cells[r, 0].content != "" and r != 0 }).column(0).style :borders => [:top,:left]
    row(lambda { |r|  cells[r, 0].content != "" and r != 0 }).column(1).style :borders => [:top]
    row(lambda { |r|  cells[r, 0].content != "" and r != 0 }).column(2).style :borders => [:top]
    row(lambda { |r|  cells[r, 0].content != "" and r != 0 }).column(3).style :borders => [:top,:right]
end