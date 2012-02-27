# encoding: utf-8

def stroke_axis(options={},pdf)
  options = { :height => (pdf.cursor - 20).to_i,
              :width => pdf.bounds.width.to_i
            }.merge(options)
  
  pdf.dash(1, :space => 4)
  pdf.stroke_horizontal_line(-21, options[:width], :at => 0)
  pdf.stroke_vertical_line(-21, options[:height], :at => 0)
  pdf.undash
  
  pdf.fill_circle [0, 0], 1
  
  (100..options[:width]).step(100) do |point|
    pdf.fill_circle [point, 0], 1
    pdf.draw_text point, :at => [point-5, -10], :size => 7
  end

  (100..options[:height]).step(100) do |point|
    pdf.fill_circle [0, point], 1
    pdf.draw_text point, :at => [10, point-2], :size => 7
  end
end
stroke_axis({},pdf)




pdf.font "#{Prawn::BASEDIR}/data/fonts/THSarabunNew.ttf"
pdf.font_size 14

date = case params[:year][4].to_s
    when "1" then "1 เมษายน"
    when "2" then "1 ตุลาคม"
    else ""
end

type_report = case params[:type]
    when "1" then "ตาม จ.18"
    when "2" then "ตามปฏิบัติงานจริง"
    else ""
end

pdf.repeat :all, :dynamic => true do
    pdf.bounding_box [380, 775], :width => 200, :height => 52 do
        pdf.text "เอกสารหมายเลข "+params[:type],:align => :right, :valign => :center
    end
    pdf.text "บัญชีแสดงวงเงินเดือนข้าราชการ", :align => :center
    pdf.text "คำนวณนับเงิน ณ วันที่ #{date} #{params[:year][0..3]}", :align => :center
    pdf.text "<u>#{@subdeptname}</u>", :align => :center,:inline_format => true
    pdf.text "<u>#{type_report}</u>", :align => :center,:inline_format => true
    pdf.move_down(20)
end


