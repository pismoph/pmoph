# coding: utf-8
class ApplicationController < ActionController::Base
  include ControllerAuthentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for detai
  before_filter :login_required, :only => [:long_title_head_subdept]
  def month_th_short
    ["","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พฤ.ย.","ธ.ค."]
  end
  
  def month_th
    ["","มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"]
  end
  
  def date_th(dt)
    begin
      "#{dt.day} #{month_th[dt.month]} พ.ศ. #{dt.year+543}"
    rescue
      ""
    end
  end
  
  def date_th_short(dt)
    begin
      "#{dt.day} #{month_th_short[dt.month]}  #{dt.year+543}"
    rescue
      nil
    end
  end

  
  def to_date_db(dt)
    if dt.nil? or dt == ""
       d=''
       d
    else
      dt = dt.split("/")
      d = (dt[2].to_i - 543).to_s+"-"+dt[1]+"-"+dt[0]
      d     
    end
  end
  
  def year_fiscal_i(dt)
    dt = dt.split("-")
    dt = Time.local(dt[0].to_i,dt[1].to_i,dt[2].to_i)
    fiscal_min = Time.local(dt.year-1,10,1)
    fiscal_max = Time.local(dt.year,9,30)
    year_fiscal = ''
    if dt > fiscal_min and dt < fiscal_max
     year_fiscal = fiscal_max.year
    end     
    if dt > fiscal_max
      year_fiscal = fiscal_max.year + 1
    end
    year_fiscal   
  end
  
  def render_flag_education(s)
    flag = ""
    if s.to_s == "1"
      flag = "ใช่"
    elsif s.to_s == "0"
      flag = "ไม่ใช่"
    else
      flag = ""
    end
    flag
  end
  
  def render_maxed_education(s)
    maxed = ""
    if s.to_s == "1"
      maxed = "ใช่"
    elsif s.to_s == "0"
      maxed = "ไม่ใช่"
    else
      maxed = ""
    end
    maxed
  end
  
  def render_sex(s)
    sex = ""
    if s.to_s == "1"
      sex = "ชาย"
    elsif s.to_s == "2"
      sex = "หญิง"
    else
      sex = ""
    end
    sex
  end
  
  def render_date(dt)
    begin
      "#{"%02d" %dt.day}/#{"%02d" % dt.month}/#{dt.year+543}"
    rescue
      ""
    end
  end
  
  def render_flagcount(s)
    flag = ""
    if s.to_s == "1"
      flag = "นับครั้ง"
    elsif s.to_s == "0"
      flag = "ไม่นับครั้ง"
    else
      flag = ""
    end
    flag
  end
  
  def calage(dt1,dt2)
    y1 = dt1.year
    m1 = dt1.month
    d1 = dt1.mday
    y2 = dt2.year
    m2 = dt2.month
    d2 = dt2.mday
    if d1 < d2
            m1 = m1 - 1
            m_tmp = m2.to_i
            m_tmp = m2.to_i + 1 if m2.to_i != 12
            dt_tmp =  Time.local(y2,m_tmp) - 1
            dt_tmp =  Time.local(y2+1,1) - 1  if m2.to_i == 12
            tmp = dt_tmp.mday.to_i
            d1 += tmp
    end
    if m1 < m2
            y1 = y1 - 1
            m1 += 12
    end
    [y1 - y2, m1 - m2, d1 - d2]
  end
  
  def render_etype et
    str = case et.to_s
    when "1" then "ผู้ปฏิบัติงาน"
    when "2" then "หัวหน้างาน"
    when "3" then "หัวหน้าฝ่าย กลุ่ม กลุ่มงาน"
    when "4" then "หัวหน้าหน่วยงาน"
    end
    str
  end
  
  def format_pid pid
    #3-2201-00087-81-0
    pid = pid.to_s
    begin
      "#{pid[0]} #{pid[1..4]} #{pid[5..9]} #{pid[10..11]} #{pid[12]}"
    rescue
      ""
    end
  end
    
  def head_subdept
    #,11,12,13,14,15
    [
      {
        :arr => [2,3,4,5,6,7,8,9] ,
        :name => "สสจ.",
        :longname => "สำนักงานสาธารณสุขจังหวัด",
        :subcode => "provcode"
      },
      {
        :arr => [17,18] ,
        :name => "สสอ.",
        :longname => "สำนักงานสาธารณสุขอำเภอ",
        :subcode => "amcode"
      }
    ]
  end
  
  def long_title_head_subdept(sdcode)
    begin
      type_title = head_subdept
      rs_subdept = Csubdept.find(sdcode)
      title = ""
      type_title.each do|u|
        if !u[:arr].index(rs_subdept.sdtcode).nil?
          address = ""
          if u[:subcode] == "provcode"
            prov = begin
              Cprovince.find(rs_subdept.provcode)
            rescue
              ""
            end
            address += "#{(prov.to_s == "")? "" : prov.provname}"
          end
          if u[:subcode] == "amcode"
            amp = begin
              Camphur.find(:all,:conditions => "provcode = #{rs_subdept.provcode} and amcode = #{rs_subdept.amcode}")[0]
            rescue
              ""
            end
            address += "#{(amp.to_s == "")? "" : amp.amname}"
          end
          title = "#{u[:longname]}#{address}"
        end
      end
      title
    rescue
      ""
    end
  end
  
  def short_title_head_subdept(sdcode)
    begin
      type_title = head_subdept
      rs_subdept = Csubdept.find(sdcode)
      title = ""
      type_title.each do|u|
        if !u[:arr].index(rs_subdept.sdtcode).nil?
          address = ""
          if u[:subcode] == "provcode"
            prov = begin
              Cprovince.find(rs_subdept.provcode)
            rescue
              ""
            end
            address += "#{(prov.to_s == "")? "" : prov.provname}"
          end
          if u[:subcode] == "amcode"
            amp = begin
              Camphur.find(:all,:conditions => "provcode = #{rs_subdept.provcode} and amcode = #{rs_subdept.amcode}")[0]
            rescue
              ""
            end
            address += "#{(amp.to_s == "")? "" : amp.amname}"
          end
          title = "#{u[:name]}#{address}"
        end
      end
      title
    rescue
      ""
    end
  end
  
  def retiredate(dt)
    begin
      day = 30
      month = 9
      year = ""
      if dt.mon >= 10
        year = dt.year.to_i + 61
        if dt.mon == 10 and dt.day == 1
          year = dt.year.to_i + 60
        end
      else
        year = dt.year.to_i + 60
      end
      Date.new(year,month,day)
    rescue
      ""
    end
  end
  
  def to_data_db(data)
    str = "null"
    str = "'#{data}'" if data.to_s.strip != ""
    str
  end
  
  def to_date_export(dt)
    begin
      y = dt.year
      m = dt.month
      d = dt.mday
      "#{d}/#{m}/#{y}"
    rescue
      ""
    end
  end
  
  def date_import(dt)
    begin
      dt = dt.split(" ")
      dt = dt[0].split("/")
      d = "#{dt[2]}-#{"%02d" % dt[1]}-#{"%02d" % dt[0]}"
      d
    rescue
      ""
    end
  end
  
  helper_method :short_title_head_subdept
  helper_method :long_title_head_subdept
  helper_method :format_pid
  helper_method :month_th_short
  helper_method :date_th
  helper_method :date_th_short
  helper_method :to_data_db
end
