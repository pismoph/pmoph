# coding: utf-8
class ApplicationController < ActionController::Base
  include ControllerAuthentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for detai
  before_filter :login_required, :only => [:long_title_head_subdept]
  def month_th_short
    ["","ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พฤ.ย.","ธ.ค."]
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
    dt1 = dt1.to_date + 1
    y1 = dt1.year
    m1 = dt1.month
    d1 = dt1.mday
    y2 = dt2.year
    m2 = dt2.month
    d2 = dt2.mday
    if d1 < d2
      m1 = m1 -1
      d1 += Date.new(y2, m2, -1).day
    end
    if m1 < m2
      y1 = y1 -1
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
    begin
      pid = pid.to_s
      "#{pid[0]} #{pid[1..4]} #{pid[5..9]} #{pid[10..11]} #{pid[12]}"
    rescue
      ""
    end
  end
    
  def head_subdept
    [{
      :arr => [2,3,4,5,6,7,8,9,11,12,13,14,15] ,
      :name => "สสจ.",
      :longname => "สำนักงานสาธารณสุขจังหวัด",
      :subcode => "provcode"
    }]
  end
  
  def long_title_head_subdept
    type_title = head_subdept
    rs_subdept = Csubdept.find(@user_work_place[:sdcode])
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
          address += "#{(prov == "")? "" : prov.provname}"
        end
        title = "#{u[:longname]}#{address}"
      end
    end
    title
  end
  
end
