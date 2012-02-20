xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => 'รายงานสอบถามข้อมูลตามตำแหน่ง(จ.18)' do
    xml.Table do 
      # Header    
      xml.Row do
        for col_show in @col_show
          xml.Cell { xml.Data col_show, 'ss:Type' => 'String' }
        end
      end     
      # Rows
      for rec in @records
        xml.Row do
          for col in @col
            xml.Cell { xml.Data rec[:"#{col}"].to_s, 'ss:Type' => 'String' }
          end
        end
      end
      
    end
  end
end