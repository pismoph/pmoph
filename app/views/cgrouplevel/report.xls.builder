xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => 'รายงาน Code Expert' do
    xml.Table do
        
       # Column
	xml.Column 'ss:Width'=>'100'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'100'
	xml.Column 'ss:Width'=>'100'
	xml.Column 'ss:Width'=>'100'
	xml.Column 'ss:Width'=>'100'
	xml.Column 'ss:Width'=>'100'
 
        # Header "รหัส","ชื่อ","คำย่อ","เงินเดือนขั้นต่ำ","เงินเดือนขั้นสูง","กลุ่ม","ประเภท"
        xml.Row do
          xml.Cell { xml.Data 'รหัส', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ชื่อ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'คำย่อ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'เงินเดือนขั้นต่ำ', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'เงินเดือนขั้นสูง', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'กลุ่ม', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'ประเภท', 'ss:Type' => 'String' }
        end

        # Rows
        for rec in @records
          xml.Row do
            xml.Cell { xml.Data rec.ccode, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data rec.cname, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.scname, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.minsal1, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data rec.maxsal1, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data rec.gname, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.clname, 'ss:Type' => 'String' }
	  end
        end

    end
  end
end
