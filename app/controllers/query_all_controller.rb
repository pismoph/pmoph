# coding: utf-8
class QueryAllController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def j18
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'fname', 'lname'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}"
        when 'poscode', 'excode', 'epcode', 'ptcode', 'salary'
          where[x]["field"] = "pisj18.#{where[x]["field"]}"
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end    
    str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    
    rs = Pisj18.select("pispersonel.fname,pispersonel.lname,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).find(:all,:conditions => tmp_where).count
    return_data[:records]   = rs.collect{|u|
      {
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  def perform
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'j18code', 'birthdate'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}"
        when 'day_of_birth'
          where[x]["field"] = "extract(day from date(pispersonel.birthdate))"
        when 'month_of_birth'
          where[x]["field"] = "extract(month from date(pispersonel.birthdate))"
        when 'year_of_birth'
          where[x]["field"] = "extract(year from date(pispersonel.birthdate))"
          where[x]["id"] = where[x]["id"].to_i - 543
        when 'age'
          where[x]["field"] = "extract(year from age(date(now())+1, date(pispersonel.birthdate)))" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end    
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    
    rs = Pisj18.select("pispersonel.fname,pispersonel.lname,pispersonel.appointdate,pispersonel.birthdate,pispersonel.retiredate,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false    
  end
  def poshist   
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'force_day'
          where[x]["field"] = "extract(day from date(pisposhis.forcedate))"
        when 'force_month'
          where[x]["field"] = "extract(month from date(pisposhis.forcedate))"
        when 'force_year'
          where[x]["field"] = "extract(year from date(pisposhis.forcedate))"
          where[x]["id"] = where[x]["id"].to_i - 543
      when 'updcode'
          where[x]["field"] = "pisposhis.#{where[x]["field"]}"
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisposhis.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pisposhis.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pisposhis.select("pispersonel.fname,pispersonel.lname,pispersonel.appointdate,pispersonel.birthdate,pispersonel.retiredate,pisposhis.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisposhis.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => render_date(u.appointdate.to_date),
        :birthdate => render_date(u.birthdate.to_date),
        :retiredate => render_date(u.retiredate.to_date),
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false     
  end
  
  def insig
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'recdate', 'kitjadate', 'retdate' 
          where[x]["field"] = "pisinsig.#{where[x]["field"]}"
        when 'qcode', 'mprovcode', 'codetrade', 'recode', 'mrcode', 'sex'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pisinsig.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pisinsig.select("pispersonel.fname,pispersonel.lname,pispersonel.appointdate,pispersonel.birthdate,pispersonel.retiredate,pisinsig.*,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisinsig.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => render_date(u.appointdate.to_date),
        :birthdate => render_date(u.birthdate.to_date),
        :retiredate => render_date(u.retiredate.to_date),
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false     
  end
  
  def education
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "endyear"
          where[x]["field"] = "extract(year from date(piseducation.enddate))"
          where[x]["id"] = where[x]["id"].to_i - 543
        when "enddate", "qcode", "ecode", "mprovcode", "institute", "cocode"  
          where[x]["field"] = "piseducation.#{where[x]["field"]}"
        when "mrcode", "sex", "provcode"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on piseducation.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Piseducation.select("pispersonel.*,piseducation.*,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Piseducation.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false     
  end
  
  def trainning
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "begindate", "enddate", "cource","institute", "cocode"  
          where[x]["field"] = "pistrainning.#{where[x]["field"]}"
        when "codetrade", "recode", "provcode", "mrcode", "sex"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pistrainning.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pistrainning.select("pispersonel.*,pistrainning.*,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pistrainning.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false     
  end

  def punish
    dt = Date.today
    limit = params[:limit]
    start = params[:start]
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "forcedate", "pncode", "description", "cmdno" 
          where[x]["field"] = "pispunish.#{where[x]["field"]}"
        when "codetrade", "recode", "provcode", "mrcode", "sex"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pispunish.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pispunish.select("pispersonel.*,pispunish.*,pisj18.*").joins(str_join).find(:all,:conditions => tmp_where, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pispunish.joins(str_join).find(:all,:conditions => tmp_where).count
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }
    render :text => return_data.to_json,:layout => false     
  end
  ####################################################################
  def reportj18
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'fname', 'lname'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}"
        when 'poscode', 'excode', 'epcode', 'ptcode', 'salary'
          where[x]["field"] = "pisj18.#{where[x]["field"]}"
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end    
    str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    
    rs = Pisj18.select("pispersonel.fname,pispersonel.lname,pisj18.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
    
    @records = rs.collect{|u|
      {
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary
      }
    }
  end
  
  def reportperform
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'j18code', 'birthdate'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}"
        when 'day_of_birth'
          where[x]["field"] = "extract(day from date(pispersonel.birthdate))"
        when 'month_of_birth'
          where[x]["field"] = "extract(month from date(pispersonel.birthdate))"
        when 'year_of_birth'
          where[x]["field"] = "extract(year from date(pispersonel.birthdate))"
          where[x]["id"] = where[x]["id"].to_i - 543
        when 'age'
          where[x]["field"] = "extract(year from age(date(now())+1, date(pispersonel.birthdate)))" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end    
    str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pisj18.select("pispersonel.*,pisj18.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date)  rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date) rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date) rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }
  end
  def reportposhist   
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'force_day'
          where[x]["field"] = "extract(day from date(pisposhis.forcedate))"
        when 'force_month'
          where[x]["field"] = "extract(month from date(pisposhis.forcedate))"
        when 'force_year'
          where[x]["field"] = "extract(year from date(pisposhis.forcedate))"
          where[x]["id"] = where[x]["id"].to_i - 543
      when 'updcode'
          where[x]["field"] = "pisposhis.#{where[x]["field"]}"
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          tmp_where2.push(" pisposhis.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pisposhis.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pisposhis.select("pispersonel.*,pisposhis.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => render_date(u.appointdate.to_date),
        :birthdate => render_date(u.birthdate.to_date),
        :retiredate => render_date(u.retiredate.to_date),
        :age => age,
        :ageappoint => ageappoint
      }
    }   
  end
  
  def reportinsig
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when 'recdate', 'kitjadate', 'retdate' 
          where[x]["field"] = "pisinsig.#{where[x]["field"]}"
        when 'qcode', 'mprovcode', 'codetrade', 'recode', 'mrcode', 'sex'
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pisinsig.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pisinsig.select("pispersonel.*,pisinsig.*,pisj18.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => render_date(u.appointdate.to_date),
        :birthdate => render_date(u.birthdate.to_date),
        :retiredate => render_date(u.retiredate.to_date),
        :age => age,
        :ageappoint => ageappoint
      }
    }    
  end
  
  def reporteducation
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "endyear"
          where[x]["field"] = "extract(year from date(piseducation.enddate))"
          where[x]["id"] = where[x]["id"].to_i - 543
        when "enddate", "qcode", "ecode", "mprovcode", "institute", "cocode"  
          where[x]["field"] = "piseducation.#{where[x]["field"]}"
        when "mrcode", "sex", "provcode"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on piseducation.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Piseducation.select("pispersonel.*,piseducation.*,pisj18.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
    @records  = rs.collect{|u|
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }    
  end

  def reporttrainning
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "begindate", "enddate", "cource","institute", "cocode"  
          where[x]["field"] = "pistrainning.#{where[x]["field"]}"
        when "codetrade", "recode", "provcode", "mrcode", "sex"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pistrainning.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pistrainning.select("pispersonel.*,pistrainning.*,pisj18.*")
    rs = rs.joins(str_join).find(:all,:conditions => tmp_where, :order => "pisj18.posid")
    @records  = rs.collect{|u|
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }    
  end

  def reportpunish
    dt = Date.today
    @col      = params[:col].split(',')
    @col_show = params[:col_show].split(',')
    col = params[:col].split(',')
    where = ActiveSupport::JSON.decode(params[:where])
    tmp_where = ""
    where.each_index {|x|
      case where[x]["field"]
        when "forcedate", "pncode", "description", "cmdno" 
          where[x]["field"] = "pispunish.#{where[x]["field"]}"
        when "codetrade", "recode", "provcode", "mrcode", "sex"
          where[x]["field"] = "pispersonel.#{where[x]["field"]}" 
      end
      if where[x]["field"] != "work_place"
        if where[x]["operator"] == "like"
          where[x]["id"] = "%#{where[x]["id"]}%"
          where[x]["field"] = where[x]["field"]+"::varchar"
        end
        if x == (where.length - 1)
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' "
        else
          tmp_where += " #{where[x]["field"]} #{where[x]["operator"]} '#{where[x]["id"]}' #{where[x]["operator2"]} "
        end
      else
        tmp_where2 = []
        keys = where[x]["id"].keys
        keys.each do |k|
          #tmp_where2.push(" pisj18.#{k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
          tmp_where2.push(" pisj18.#{(k == "mcode")? "mincode" : k} #{where[x]["operator"]} '#{where[x]["id"][k]}' ")
        end
        if x == (where.length - 1)
          tmp_where += " (#{tmp_where2.join(" and ")}) "
        else
          tmp_where += " (#{tmp_where2.join(" and ")}) #{where[x]["operator2"]} "
        end
      end
    }
    search_wp = []
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search_wp.push( " pisj18.#{k} = '#{val}' " )
    end 
    if tmp_where == ""
      tmp_where = " pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    else
      tmp_where = " (#{tmp_where}) and pisj18.flagupdate = '1'  and (#{search_wp.join(" and ")}) "
    end 
    str_join = " inner join pispersonel on pispunish.id = pispersonel.id "
    str_join += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    rs = Pispunish.select("pispersonel.*,pispunish.*,pisj18.*").joins(str_join)
    rs = rs.find(:all,:conditions => tmp_where, :order => "pisj18.posid")
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
        :fname => (u.fname.to_s == "")? "ตำแหน่งว่าง" : u.fname ,
        :lname => (u.lname.to_s == "")? "ตำแหน่งว่าง" : u.lname,
        :minname => begin Cministry.find(u.mincode).minname rescue "" end ,
        :division => begin Cdivision.find(u.dcode).full_name rescue "" end ,
        :deptname => begin Cdept.find(u.deptcode).deptname rescue "" end ,
        :subdeptname => begin Csubdept.find(u.sdcode).full_name rescue "" end ,
        :secname => begin Csection.find(u.seccode).full_name rescue "" end ,
        :jobname => begin Cjob.find(u.jobcode).jobname rescue "" end ,
        :posname => begin Cposition.find(u.poscode).full_name rescue "" end ,
        :exname => begin Cexecutive.find(u.excode).full_name rescue "" end ,
        :expert => begin Cexpert.find(u.epcode).full_name rescue "" end ,
        :ptname => begin Cpostype.find(u.ptcode).ptname rescue "" end ,
        :salary  => u.salary,
        :posid => u.posid,
        :appointdate => begin render_date(u.appointdate.to_date) rescue "" end,
        :birthdate => begin render_date(u.birthdate.to_date)  rescue "" end,
        :retiredate => begin render_date(u.retiredate.to_date)  rescue "" end,
        :age => age,
        :ageappoint => ageappoint
      }
    }   
  end

  
end
