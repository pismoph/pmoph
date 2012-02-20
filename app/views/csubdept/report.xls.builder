xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => 'รายงาน Code Ministry' do
    xml.Table do
        
       # Column
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	xml.Column 'ss:Width'=>'250'
	
        # Header
        xml.Row do
          xml.Cell { xml.Data "รหัสหน่วยงาน", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "ชื่อย่อคำนำหน้า", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "คำนำหน้า", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "หน่วยงาน", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "ประเภทหน่วยงาน", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "Training", 'ss:Type' => 'String' }
          xml.Cell { xml.Data "ส่วน", 'ss:Type' => 'String' }
	  xml.Cell { xml.Data "เขต", 'ss:Type' => 'String' }
	  xml.Cell { xml.Data "จังหวัด", 'ss:Type' => 'String' }
	  xml.Cell { xml.Data "อำเภอ", 'ss:Type' => 'String' }
	  xml.Cell { xml.Data "ตำบล", 'ss:Type' => 'String' }
	  xml.Cell { xml.Data "คลังเบิกจ่าย", 'ss:Type' => 'String' }
	end

        # Rows
        for rec in @records
          xml.Row do
            xml.Cell { xml.Data rec.sdcode.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.shortpre.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.longpre.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.subdeptname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.sdgname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.trlname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.location.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.aname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.provname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.amname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.tmname.to_s, 'ss:Type' => 'String' }
            xml.Cell { xml.Data rec.finname.to_s, 'ss:Type' => 'String' } 
          end
        end
    end
  end
end
