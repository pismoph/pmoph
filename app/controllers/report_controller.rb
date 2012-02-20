# coding: utf-8
class ReportController < ApplicationController
  before_filter :login_menu_report
  skip_before_filter :verify_authenticity_token
  def genre_fiscal_year    
    rs_min = Pispersonel.minimum("birthdate")
    rs_max = Pispersonel.maximum("birthdate")
    fiscal_min =rs_min.year.to_i + 65
    fiscal_max = rs_max.year.to_i + 65
    str = Array.new
    j = 0
    for i in fiscal_min..fiscal_max
      str[j] = "{year_en:#{i},year_th:#{i+543}}"
      j += 1 
    end    
    render :text => "{records:[#{str.join(",")}]}"
  end
  ###################################################################
  def retire
    limit = params[:limit]
    start = params[:start]
    dt = Date.today
    str_join = ""
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " LEFT JOIN cposition ON cposition.poscode = pisj18.poscode "
    search = " pisj18.flagupdate = '1' "
    if params[:fiscal_year].to_s != ""
      search += " and pispersonel.retiredate between '#{params[:fiscal_year].to_i - 1}-10-01' and '#{params[:fiscal_year]}-09-30'"
    end
    
    if params[:mcode].to_s != ""
      search += " and pispersonel.mincode = '#{params[:mcode]}'"
    end
    
    if params[:deptcode].to_s != ""
      search += " and pispersonel.deptcode = '#{params[:deptcode]}'"
    end

    if params[:dcode].to_s != ""
      search += " and pispersonel.dcode = '#{params[:dcode]}'"
    end
    
    if params[:sdcode].to_s != ""
      search += " and pispersonel.sdcode = '#{params[:sdcode]}'"
    end

    if params[:seccode].to_s != ""
      search += " and pispersonel.seccode = '#{params[:seccode]}'"
    end

    if params[:jobcode].to_s != ""
      search += " and pispersonel.jobcode = '#{params[:jobcode]}'"
    end
    select = "fname,lname,pisj18.posid,cposition.posname,cposition.poscode,pispersonel.appointdate"
    select += ",pispersonel.birthdate,pispersonel.retiredate,pisj18.sdcode"
    rs = Pisj18.joins(str_join).select(select)
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end 
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def report_retire
    dt = Date.today
    str_join = ""
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " LEFT JOIN cposition ON cposition.poscode = pisj18.poscode "
    search = " pisj18.flagupdate = '1' "
    if params[:fiscal_year].to_s != ""
      search += " and pispersonel.retiredate between '#{params[:fiscal_year].to_i - 1}-10-01' and '#{params[:fiscal_year]}-09-30'"
    end
    
    if params[:mcode].to_s != ""
      search += " and pispersonel.mincode = '#{params[:mcode]}'"
    end
    
    if params[:deptcode].to_s != ""
      search += " and pispersonel.deptcode = '#{params[:deptcode]}'"
    end

    if params[:dcode].to_s != ""
      search += " and pispersonel.dcode = '#{params[:dcode]}'"
    end
    
    if params[:sdcode].to_s != ""
      search += " and pispersonel.sdcode = '#{params[:sdcode]}'"
    end

    if params[:seccode].to_s != ""
      search += " and pispersonel.seccode = '#{params[:seccode]}'"
    end

    if params[:jobcode].to_s != ""
      search += " and pispersonel.jobcode = '#{params[:jobcode]}'"
    end
    select = "fname,lname,pisj18.posid,cposition.posname,cposition.poscode,pispersonel.appointdate"
    select += ",pispersonel.birthdate,pispersonel.retiredate,pisj18.sdcode"
    rs = Pisj18.joins(str_join).select(select)
    rs = rs.find(:all, :conditions => search,:order => "pisj18.posid")
    @records = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end ,
      }
    }
    prawnto :prawn=>{:page_layout=>:landscape}
  end
  ###################################################################
  def position_level
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' "
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.poscode,pisj18.c")
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start,
                 :order => "pisj18.poscode,pisj18.c" ,
                 :group => "pisj18.poscode,pisj18.c"
                )
    sql = "select count(*) as n from (SELECT poscode,c FROM pisj18 "
    sql += "WHERE ( #{search} ) group by poscode,c ) as t1"
    return_data = {}
    return_data[:totalCount] = Pisj18.find_by_sql(sql)[0].n
    return_data[:records]   = rs.collect{|u|
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง
      search_empty = " and (length(trim(pisj18.id))  = 0 or pisj18.id is null) " ##ว่าง      
      {
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end,
        :cname => begin Cgrouplevel.find(u.c).cname rescue "" end,
        :n => Pisj18.joins(str_join).find(:all, :conditions => search + " and pisj18.c = '#{u.c}' and pisj18.poscode = '#{u.poscode}'").count,
        :n_empty => Pisj18.find(:all, :conditions => search + search_empty + " and pisj18.c = '#{u.c}' and pisj18.poscode = '#{u.poscode}'").count,
      }
    }
    render :text => return_data.to_json,:layout => false
  end  
  def report_position_level
    search = " pisj18.flagupdate = '1' "
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.poscode,pisj18.c")
    rs = rs.find(:all, :conditions => search,
                 :order => "pisj18.poscode,pisj18.c" ,
                 :group => "pisj18.poscode,pisj18.c"
                )
    @records   = rs.collect{|u|
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง
      search_empty = " and (length(trim(pisj18.id))  = 0 or pisj18.id is null) " ##ว่าง      
      {
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end,
        :cname => begin Cgrouplevel.find(u.c).cname rescue "" end,
        :n => Pisj18.joins(str_join).find(:all, :conditions => search + " and pisj18.c = '#{u.c}' and pisj18.poscode = '#{u.poscode}'").count,
        :n_empty => Pisj18.find(:all, :conditions => search + search_empty + " and pisj18.c = '#{u.c}' and pisj18.poscode = '#{u.poscode}'").count,
      }
    }
  end
  ###################################################################
  def position_work_place
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' "
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.sdcode,pisj18.poscode")
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start,
                 :order => "pisj18.sdcode,pisj18.poscode" ,
                 :group => "pisj18.sdcode,pisj18.poscode"
                )
    sql = "select count(*) as n from (SELECT pisj18.sdcode,pisj18.poscode FROM pisj18 "
    sql += "WHERE ( #{search} ) group by pisj18.sdcode,pisj18.poscode ) as t1"
    return_data = {}
    return_data[:totalCount] = Pisj18.find_by_sql(sql)[0].n
    return_data[:records]   = rs.collect{|u|
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง
      search_empty = " and (length(trim(pisj18.id))  = 0 or pisj18.id is null) " ##ว่าง      
      {
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end,
        :posname => begin Cposition.find(u.poscode).full_name rescue u.poscode end,
        :n => Pisj18.joins(str_join).find(:all, :conditions => search + " and pisj18.sdcode = '#{u.sdcode}' and pisj18.poscode = '#{u.poscode}'").count,
        :n_empty => Pisj18.find(:all, :conditions => search + search_empty + " and pisj18.sdcode = '#{u.sdcode}' and pisj18.poscode = '#{u.poscode}'").count,
      }
    }
    render :text => return_data.to_json,:layout => false 
  end
  def report_position_work_place
    search = " pisj18.flagupdate = '1' "
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.sdcode,pisj18.poscode")
    rs = rs.find(:all, :conditions => search,
                 :order => "pisj18.sdcode,pisj18.poscode" ,
                 :group => "pisj18.sdcode,pisj18.poscode"
                )
    @records   = rs.collect{|u|
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง
      search_empty = " and (length(trim(pisj18.id))  = 0 or pisj18.id is null) " ##ว่าง      
      {
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end,
        :posname => begin Cposition.find(u.poscode).full_name rescue u.poscode end,
        :n => Pisj18.joins(str_join).find(:all, :conditions => search + " and pisj18.sdcode = '#{u.sdcode}' and pisj18.poscode = '#{u.poscode}'").count,
        :n_empty => Pisj18.find(:all, :conditions => search + search_empty + " and pisj18.sdcode = '#{u.sdcode}' and pisj18.poscode = '#{u.poscode}'").count,
      }
    }
  end
  ###################################################################
  def list_position_level
    limit = params[:limit]
    start = params[:start]
    dt = Date.today
    search = " pisj18.flagupdate = '1' "
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง  
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    if params[:poscode].to_s != ""
      search += " and pisj18.poscode = '#{params[:poscode]}'"
    end
    if params[:ccode].to_s != ""
      search += " and pisj18.c = '#{params[:ccode]}'"
    end    
    
    rs = Pisj18.select("pisj18.posid, pisj18.poscode, pispersonel.fname,pispersonel.lname,pispersonel.birthdate,pispersonel.appointdate,pispersonel.retiredate ,pisj18.c,pisj18.sdcode").joins(str_join)
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start,:order => "pisj18.poscode,pisj18.c")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).find(:all, :conditions => search).count
    return_data[:records]   = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end 
      }
    }
    render :text => return_data.to_json,:layout => false
  end  

  def report_list_position_level
    dt = Date.today
    search = " pisj18.flagupdate = '1' "
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง  
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    if params[:poscode].to_s != ""
      search += " and pisj18.poscode = '#{params[:poscode]}'"
    end
    if params[:ccode].to_s != ""
      search += " and pisj18.c = '#{params[:ccode]}'"
    end    
    
    rs = Pisj18.select("pisj18.posid, pisj18.poscode, pispersonel.fname,pispersonel.lname,pispersonel.birthdate,pispersonel.appointdate,pispersonel.retiredate ,pisj18.c,pisj18.sdcode").joins(str_join)
    rs = rs.find(:all, :conditions => search, :order => "pisj18.poscode,pisj18.c")
    @records   = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end 
      }
    }
    prawnto :prawn=>{:page_layout=>:landscape}
  end  
  ###################################################################
  def work_place
    limit = params[:limit]
    start = params[:start]
    dt = Date.today
    search = " pisj18.flagupdate = '1' "
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง  
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.posid, pisj18.poscode, pispersonel.fname,pispersonel.lname,pispersonel.birthdate,pispersonel.appointdate,pispersonel.retiredate ,pisj18.c,pisj18.sdcode").joins(str_join)
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start,:order => "pisj18.poscode")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).find(:all, :conditions => search).count
    return_data[:records]   = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end 
      }
    }
    render :text => return_data.to_json,:layout => false
  end  

  def report_work_place
    dt = Date.today
    search = " pisj18.flagupdate = '1' "
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id " #มีคนครองตำแหน่ง  
    if params[:mcode].to_s != ""
      search += " and pisj18.mincode = '#{params[:mcode]}'"
    end    
    if params[:deptcode].to_s != ""
      search += " and pisj18.deptcode = '#{params[:deptcode]}'"
    end
    if params[:dcode].to_s != ""
      search += " and pisj18.dcode = '#{params[:dcode]}'"
    end    
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}'"
    end
    if params[:seccode].to_s != ""
      search += " and pisj18.seccode = '#{params[:seccode]}'"
    end
    if params[:jobcode].to_s != ""
      search += " and pisj18.jobcode = '#{params[:jobcode]}'"
    end
    rs = Pisj18.select("pisj18.posid, pisj18.poscode, pispersonel.fname,pispersonel.lname,pispersonel.birthdate,pispersonel.appointdate,pispersonel.retiredate ,pisj18.c,pisj18.sdcode").joins(str_join)
    rs = rs.find(:all, :conditions => search, :order => "pisj18.poscode")
    @records   = rs.collect{|u|
      birthdate = u.birthdate
      age = [0,0,0]
      if birthdate.to_s != ""
        birthdate = u.birthdate.to_date
        if birthdate > dt
          age = calage(birthdate,dt)
        else
          age = calage(dt,birthdate)
        end        
      end
      age_tmp = []
      age_tmp.push(" #{age[0]} ปี ") if age[0] != 0
      age_tmp.push(" #{age[1]} เดือน ") if age[1] != 0
      age_tmp.push(" #{age[2]} วัน ") if age[2] != 0
      age = age_tmp.join("")
      
      appointdate = u.appointdate
      ageappoint = [0,0,0]
      if appointdate.to_s != ""
        appointdate = u.appointdate.to_date
        if appointdate > dt
          ageappoint = calage(appointdate,dt)
        else
          ageappoint = calage(dt,appointdate)
        end        
      end
      ageappoint_tmp = []
      ageappoint_tmp.push(" #{ageappoint[0]} ปี ") if ageappoint[0] != 0
      ageappoint_tmp.push(" #{ageappoint[1]} เดือน ") if ageappoint[1] != 0
      ageappoint_tmp.push(" #{ageappoint[2]} วัน ") if ageappoint[2] != 0
      ageappoint = ageappoint_tmp.join("")

      {
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid,
        :appointdate => (u.appointdate.to_s == "")? "" : render_date(u.appointdate.to_date),
        :birthdate => (u.birthdate.to_s == "")? "" : render_date(u.birthdate.to_date),
        :retiredate => (u.retiredate.to_s == "")? "" : render_date(u.retiredate.to_date),
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "" ,
        :age => age,
        :ageappoint => ageappoint,
        :j18_subdept => (u.sdcode.to_s == "" )? "" : begin Csubdept.find(u.sdcode).full_name rescue "" end 
      }
    }
    prawnto :prawn=>{:page_layout=>:landscape}
  end 
  
end

#work_place[min]
#work_place[dept]
#work_place[div]
#work_place[subdept]
#work_place[sec]
#work_place[job]
