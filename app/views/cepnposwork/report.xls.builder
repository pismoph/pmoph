xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => 'รายงาน Code Epnposwork' do
    xml.Table do
        
       # Column
			xml.Column 'ss:Width'=>'100'
			xml.Column 'ss:Width'=>'100'
			xml.Column 'ss:Width'=>'100'
 
        # Header "รหัสตำแหน่ง","รหัสกลุ่ม","รหัสหมวด","ชื่อตำแหน่ง","ระดับ","ค่าจ้างขั้นต่ำ","ค่าจ้างขั้นสูง","attribute","หมายเหตุ","รหัสตัวเลข"
        xml.Row do
          xml.Cell { xml.Data 'รหัสตำแหน่ง', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'รหัสกลุ่ม', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'รหัสหมวด', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ชื่อตำแหน่ง', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ระดับ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ค่าจ้างขั้นต่ำ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ค่าจ้างขั้นสูง', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'attribute', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'หมายเหตุ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'รหัสตัวเลข', 'ss:Type' => 'String' }
        end

        # Rows
        for rec in @records
          xml.Row do
            xml.Cell { xml.Data rec.wrkcode.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.gcode.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.grpcode.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.wrknm.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.levels.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.minwages.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.maxwages.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.wrkatrb.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.note.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.numcode.to_s, 'ss:Type' => 'String' }
          end
        end

    end
  end
end
