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
        
       
 
        # Header "ชื่อ","นามสกุล","ตำแหน่งเลขที่","ตำแหน่ง","วันที่บรรจุ","วันเกิด","วันที่เกษียณ","อายุ","อายุราชการ","หน่วยงานตามจ.18"
        xml.Row do
          xml.Cell { xml.Data "ชื่อ", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "นามสกุล", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "ตำแหน่งเลขที่", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "ตำแหน่ง",'ss:Type' => 'String' }
          xml.Cell { xml.Data "วันที่บรรจุ", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "วันเกิด", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "วันที่เกษียณ", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "อายุ", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "อายุราชการ", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "หน่วยงานตามจ.18", 'ss:Type' => 'String' }
        end

        # Rows
        @records.each do |rec|
          xml.Row do
            xml.Cell { xml.Data rec[:fname], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:lname], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:posid], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:posname], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:appointdate], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:birthdate], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:retiredate], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:age], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:ageappoint], 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec[:j18_subdept], 'ss:Type' => 'String' }
          end
        end

    end
  end
end
