xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => 'รายงาน' do
    xml.Table do
        
       
 
        # Header "ชื่อหน่วยงาน","ตำแหน่งสายงาน","จำนวน"
        xml.Row do
          xml.Cell { xml.Data 'ชื่อหน่วยงาน', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ตำแหน่งสายงาน', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'จำนวนที่ครองตำแหน่ง', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'จำนวนที่ตำแหน่งว่าง', 'ss:Type' => 'String' }
        end

        # Rows
        @records.each do |rec|
          xml.Row do
            xml.Cell { xml.Data rec[:subdeptname], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:posname], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:n], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:n_empty], 'ss:Type' => 'String' }
          end
        end

    end
  end
end
