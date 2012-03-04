# coding: utf-8
class UpSalaryController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def read
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} and flagcal = '1' "
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    ##เก็บ j18status ลง array
    arr_j18 = []
    d_j18 = TIncsalary.select("distinct j18code").find(:all,:conditions => search).collect{|u| u.j18code }
    rs_j18 = Cj18status.select("j18code,j18status").where(:j18code => d_j18)
    for i in 0...rs_j18.length
      arr_j18.push(rs_j18[i].j18code.to_i)
    end
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => :posid)
    return_data = {}
    return_data[:totalCount] = TIncsalary.count(:all,:conditions => search)
    i = 0
    return_data[:records]   = rs.collect{|u|
      i += 1
      idx_c = arr_c.index(u.level.to_i)
      idx_j18 = arr_j18.index(u.j18code.to_i)
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      {
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :cname => begin rs_c[idx_c].cname rescue "" end,
        :salary => u.salary,
        :j18status => begin rs_j18[idx_j18].j18status rescue "" end,
        :midpoint => u.midpoint,
        :calpercent => u.calpercent,
        :score => u.score,
        :evalno => u.evalno,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :year => u.year,
        :id => u.id,
        :idx => i,
        :sdcode => u.sdcode
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def update
    begin
      data = ActiveSupport::JSON.decode(params[:data])
      data.each do |u|
        TIncsalary.transaction do
          val = []
          val.push("newsalary = #{ (u["newsalary"].to_s == "")? "null" : u["newsalary"] }")
          val.push("addmoney = #{ (u["addmoney"].to_s == "")? "null" : u["addmoney"] }")
          val.push("score = #{ (u["score"].to_s == "")? "null" : u["score"] }")
          val.push("note1 = '#{u["note1"]}'")
          val.push("calpercent = #{ (u["calpercent"].to_s == "")? "" : u["calpercent"] }")
          val.push("updcode = #{ (u["updcode"].to_s == "")? "null" : u["updcode"] }")
          val.push("evalno = #{ (u["evalno"].to_s == "")? "null" : u["evalno"] }")
          val = val.join(",")
          sql = "update t_incsalary set #{val} where year = #{u["year"]} and id = '#{u["id"]}' and sdcode = #{@user_work_place[:sdcode]} "
          ActiveRecord::Base.connection.execute(sql)
        end
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
  
  def approve
    sql = ""
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} and flagcal = '1' and level in #{params[:level]}"
      TIncsalary.transaction do
        rs_inc = TIncsalary.find(:all,:conditions => search)
        val_his = []
        rs_inc.each do |u|
          sql = " update t_incsalary set "
          sql += " flag_inc = 'Y' "
          sql += " ,cmdno = '#{params[:cmdno]}' "
          sql += " ,cmddate = '#{to_date_db(params[:cmddate])}' "
          sql += " where #{search} and id = '#{u.id}' "
          ActiveRecord::Base.connection.execute(sql)
          ########################
          search_pisj18 = " flagupdate = '1' and posid = #{u.posid} and id = '#{u.id}' "
          sql = " update pisj18 set "
          sql += " c = #{(u.level.to_s == "")? "null" : u.level} "
          sql += " ,salary = #{(u.newsalary.to_s == "")? "null" : u.newsalary} "
          sql += " ,nowc = #{(u.level.to_s == "")? "null" : u.level} "
          sql += " ,nowsal = #{(u.newsalary.to_s == "")? "null" : u.newsalary} "
          if params[:round].to_s == "2"
            sql += " ,lastc = nowc "				
            sql += " ,lastsal = nowsal "
          end
          sql += " where #{search_pisj18}"
          ActiveRecord::Base.connection.execute(sql)
          ########################
          search_pispersonel = " pstatus = '1' and posid = #{u.posid} and id = '#{u.id}' "
          sql = " update pispersonel set "
          sql += " c = #{(u.level.to_s == "")? "null" : u.level} "
          sql += " ,salary = #{(u.newsalary.to_s == "")? "null" : u.newsalary} "
          sql += " where #{search_pispersonel} "
          ActiveRecord::Base.connection.execute(sql)
          ########################
          th_date = ""
          if params[:cmddate] != ""
            dt = params[:cmddate].to_s.split("/")
            th_date = "#{dt[0].to_i} #{month_th_short[dt[1].to_i]} #{dt[2].to_s[2..3]}" 
          end
          max_his = Pisposhis.select("max(historder) as mx ").find(:all,:conditions => " id = '#{u.id}' ")[0].mx
          val_his.push("('#{params[:cmdno]} ลว. #{th_date}','#{u.id}',#{max_his.to_i + 1},'#{to_date_db(params[:forcedate])}',#{(u.poscode.to_s == "")? "null" : u.poscode},#{(u.excode.to_s == "")? "null" : u.excode},#{(u.epcode.to_s == "")? "null" : u.epcode},#{(@user_work_place[:mcode].to_s == "")? "null" : @user_work_place[:mcode]},#{(u.dcode.to_s == "")? "null" : u.dcode},#{(@user_work_place[:deptcode].to_s == "")? "null" : @user_work_place[:deptcode]},#{(u.sdcode.to_s == "")? "null" : u.sdcode},#{(u.seccode.to_s == "")? "null" : u.seccode},#{(u.jobcode.to_s == "")? "null" : u.jobcode},#{(u.updcode.to_s == "")? "null" : u.updcode},#{(u.posid.to_s == "")? "null" : u.posid},#{(u.level.to_s == "")? "null" : u.level},#{(u.newsalary.to_s == "")? "null" : u.newsalary},'#{u.note1}',#{(u.ptcode.to_s == "")? "null" : u.ptcode},#{(u.subdcode.to_s == "")? "null" : u.subdcode},#{(@user_work_place[:sdcode].to_s == "")? "null" : @user_work_place[:sdcode]},#{(u.calpercent.to_s == "")? "null" : u.calpercent},null,#{(u.score.to_s == "")? "null" : u.score})")
        end
        if val_his.length > 0
          sql = "insert into pisposhis(refcmnd,id,historder,forcedate,poscode,excode,epcode,mcode,dcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,note,ptcode,subdcode,officecode,uppercent,upsalary,score) "
          sql += " values#{val_his.join(",")}"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
       render :text => "{success: true}"
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาดกรุณาลองใหม่'}"
    end
  end
  
  def approve_special
    sql = ""
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} and flagcal = '1' and level in #{params[:level]} and addmoney != 0 and length(trim(addmoney::varchar)) != 0 "
      TIncsalary.transaction do
        rs_inc = TIncsalary.find(:all,:conditions => search)
        val_his = []
        rs_inc.each do |u|
          sql = " update t_incsalary set "
          sql += " flag_inc = 'Y' "
          sql += " ,cmdno = '#{params[:cmdno]}' "
          sql += " ,cmddate = '#{to_date_db(params[:cmddate])}' "
          sql += " where #{search} and id = '#{u.id}' "
          ActiveRecord::Base.connection.execute(sql)
          ########################
          th_date = ""
          if params[:cmddate] != ""
            dt = params[:cmddate].to_s.split("/")
            th_date = "#{dt[0].to_i} #{month_th_short[dt[1].to_i]} #{dt[2].to_s[2..3]}" 
          end
          max_his = Pisposhis.select("max(historder) as mx ").find(:all,:conditions => " id = '#{u.id}' ")[0].mx
          val_his.push("('#{params[:cmdno]} ลว. #{th_date}','#{u.id}',#{max_his.to_i + 1},'#{to_date_db(params[:forcedate])}',#{(u.poscode.to_s == "")? "null" : u.poscode},#{(u.excode.to_s == "")? "null" : u.excode},#{(u.epcode.to_s == "")? "null" : u.epcode},#{(@user_work_place[:mcode].to_s == "")? "null" : @user_work_place[:mcode]},#{(u.dcode.to_s == "")? "null" : u.dcode},#{(@user_work_place[:deptcode].to_s == "")? "null" : @user_work_place[:deptcode]},#{(u.sdcode.to_s == "")? "null" : u.sdcode},#{(u.seccode.to_s == "")? "null" : u.seccode},#{(u.jobcode.to_s == "")? "null" : u.jobcode},#{(u.updcode.to_s == "")? "null" : u.updcode},#{(u.posid.to_s == "")? "null" : u.posid},#{(u.level.to_s == "")? "null" : u.level},#{(u.newsalary.to_s == "")? "null" : u.newsalary},'#{u.note1}',#{(u.ptcode.to_s == "")? "null" : u.ptcode},#{(u.subdcode.to_s == "")? "null" : u.subdcode},#{(@user_work_place[:sdcode].to_s == "")? "null" : @user_work_place[:sdcode]},#{(u.calpercent.to_s == "")? "null" : u.calpercent},#{(u.addmoney.to_s == "")? "null" : u.addmoney},#{(u.score.to_s == "")? "null" : u.score})")
        end
        if val_his.length > 0
          sql = "insert into pisposhis(refcmnd,id,historder,forcedate,poscode,excode,epcode,mcode,dcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,note,ptcode,subdcode,officecode,uppercent,upsalary,score) "
          sql += " values#{val_his.join(",")}"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
       render :text => "{success: true}"
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาดกรุณาลองใหม่'}"
    end
  end

  def report1
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    @usesub_id = TKs24usesub.find(:all,:conditions => "officecode = #{@user_work_place[:sdcode]}",:order => "id").collect{|u| u.id }
  
    prawnto :prawn => {
        :top_margin => 80,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def report2
    year = params[:fiscal_year].to_s + params[:round].to_s
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บ pid ลง array
    arr_pid = []
    rs_pid = Pispersonel.find(:all,:select => "id,pid",:conditions => "id in (select t_incsalary.id from t_incsalary where #{search}) ")
    for i in 0...rs_pid.length
      arr_pid.push(rs_pid[i].id.to_s)
    end
    
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    ##เก็บ section ลง array
    arr_sec = []
    d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
    rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
    for i in 0...rs_sec.length
      arr_sec.push(rs_sec[i].seccode.to_i)
    end    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => "seccode,posid")
    
    i = 0
    @records = rs.collect{|u|
      i += 1
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pid = arr_pid.index(u.id.to_s)
      idx_c = arr_c.index(u.level.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      idx_sec = arr_sec.index(u.seccode.to_i)
      {
        :idx => i,
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :pid => begin rs_pid[idx_pid].pid rescue "" end,
        :salary => u.salary,
        :midpoint => u.midpoint,
        :score => u.score,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney.to_s,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :id => u.id,
        :clname => begin rs_c[idx_c].clname rescue "" end,
        :gname => begin rs_c[idx_c].gname rescue "" end,
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
        :seccode => u.seccode,
        :calpercent => u.calpercent
      }
    }
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    respond_to do |format|
      format.xls  { }
      format.pdf  {
        prawnto :prawn=>{
          :page_layout=>:landscape,
          :top_margin => 50,
          :left_margin => 5,
          :right_margin => 5
        }
      }
    end
  end
  
  def report3
    year = params[:fiscal_year].to_s + params[:round].to_s
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and t_incsalary.level in (34,35) "
    
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บ pid ลง array
    arr_pid = []
    rs_pid = Pispersonel.find(:all,:select => "id,pid",:conditions => "id in (select t_incsalary.id from t_incsalary where #{search}) ")
    for i in 0...rs_pid.length
      arr_pid.push(rs_pid[i].id.to_s)
    end
    
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    ##เก็บ section ลง array
    arr_sec = []
    d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
    rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
    for i in 0...rs_sec.length
      arr_sec.push(rs_sec[i].seccode.to_i)
    end    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => "seccode,posid")
    
    i = 0
    @records = rs.collect{|u|
      i += 1
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pid = arr_pid.index(u.id.to_s)
      idx_c = arr_c.index(u.level.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      idx_sec = arr_sec.index(u.seccode.to_i)
      {
        :idx => i,
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :pid => begin rs_pid[idx_pid].pid rescue "" end,
        :salary => u.salary,
        :midpoint => u.midpoint,
        :score => u.score,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney.to_s,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :id => u.id,
        :clname => begin rs_c[idx_c].clname rescue "" end,
        :gname => begin rs_c[idx_c].gname rescue "" end,
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
        :seccode => u.seccode,
        :calpercent => u.calpercent
      }
    }
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    respond_to do |format|
      format.xls  { }
      format.pdf  {
        prawnto :prawn=>{
          :page_layout=>:landscape,
          :top_margin => 50,
          :left_margin => 5,
          :right_margin => 5
        }
      }
    end
  end
  
  def report4
    year = params[:fiscal_year].to_s + params[:round].to_s
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and t_incsalary.level in (21,22) "
    
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บ pid ลง array
    arr_pid = []
    rs_pid = Pispersonel.find(:all,:select => "id,pid",:conditions => "id in (select t_incsalary.id from t_incsalary where #{search}) ")
    for i in 0...rs_pid.length
      arr_pid.push(rs_pid[i].id.to_s)
    end
    
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    ##เก็บ section ลง array
    arr_sec = []
    d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
    rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
    for i in 0...rs_sec.length
      arr_sec.push(rs_sec[i].seccode.to_i)
    end    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => "seccode,posid")
    
    i = 0
    @records = rs.collect{|u|
      i += 1
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pid = arr_pid.index(u.id.to_s)
      idx_c = arr_c.index(u.level.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      idx_sec = arr_sec.index(u.seccode.to_i)
      {
        :idx => i,
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :pid => begin rs_pid[idx_pid].pid rescue "" end,
        :salary => u.salary,
        :midpoint => u.midpoint,
        :score => u.score,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney.to_s,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :id => u.id,
        :clname => begin rs_c[idx_c].clname rescue "" end,
        :gname => begin rs_c[idx_c].gname rescue "" end,
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
        :seccode => u.seccode,
        :calpercent => u.calpercent
      }
    }
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    respond_to do |format|
      format.xls  { }
      format.pdf  {
        prawnto :prawn=>{
          :page_layout=>:landscape,
          :top_margin => 50,
          :left_margin => 5,
          :right_margin => 5
        }
      }
    end
  end
  
  def report5
    @year = params[:year]
    year = params[:year]
    search = " year = #{year} and flagcal = '1' and sdcode = #{@user_work_place[:sdcode]} and t_incsalary.j18code = 7"
    cn = TIncsalary.count(:all,:conditions => search)
    if cn > 0
      ##เก็บ pcode ลง array
      arr_p = []
      d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
      rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
      for i in 0...rs_p.length
        arr_p.push(rs_p[i].pcode.to_i)
      end
      ##เก็บ c ลง array
      arr_c = []
      d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
      rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      ##เก็บ section ลง array
      arr_sec = []
      d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
      rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
      for i in 0...rs_sec.length
        arr_sec.push(rs_sec[i].seccode.to_i)
      end      
      ##เก็บค่า position ลง array
      arr_pos = []
      d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
      rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
      for i in 0...rs_pos.length
        arr_pos.push(rs_pos[i].poscode.to_i)
      end
      rs = TIncsalary.find(:all,:conditions => search,:order => "rp_order,seccode")
      @records = []
      subdept_tmp = Csubdept.find(@user_work_place[:sdcode]).short_name
      for k in 0...(rs.length)
        u = rs[k]
        idx_c = arr_c.index(u.level.to_i)
        idx_p = arr_p.index(u.pcode.to_i)
        idx_sec = arr_sec.index(u.seccode.to_i)
        idx_pos = arr_pos.index(u.poscode.to_i)
        if k !=0
          if u.seccode != rs[k - 1].seccode         
            ###แสดงชื่อ กลุ่มงาน
            if u.seccode != ""
              @records.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :seccode => "",
                :secname => "",
                :posname => begin "<u>#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}</u>" rescue "" end,
                :midpoint => "",
                :calpercent => "",
                :newsalary => "",
                :diff => "",
                :note1 => ""
              })            
            end
          end
        else# == 0
            #แสดงชือหน่วยงาน
            @records.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :seccode => "",
              :secname => "",
              :posname => "<u>#{subdept_tmp}</u>",
              :midpoint => "",
              :calpercent => "",
              :newsalary => "",
              :diff => "",
              :note1 => ""
            })
            ###แสดงชื่อ กลุ่มงาน
            if u.seccode != ""
              @records.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :seccode => "",
                :secname => "",
                :posname => begin "<u>#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}</u>" rescue "" end,
                :midpoint => "",
                :calpercent => "",
                :newsalary => "",
                :diff => "",
                :note1 => ""
              }) 
            end
        end
        #แสดงรายการ แต่ละคน
        @records.push({   
          :i => k + 1,
          :posid => u.posid,
          :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
          :salary => u.salary,
          :clname => begin rs_c[idx_c].clname rescue "" end,
          :gname => begin rs_c[idx_c].gname rescue "" end,
          :seccode => u.seccode,
          :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
          :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
          :midpoint => u.midpoint,
          :calpercent => u.calpercent,
          :newsalary => u.newsalary,
          :diff => u.newsalary - u.salary,
          :note1 => u.note1
        })
      end
      prawnto :prawn => {
        #:page_layout=>:landscape,
        :top_margin => 120,
        :left_margin => 5,
        :right_margin => 5
      }
    end
  end
  
  def report6
    @year = params[:year]
    year = params[:year]
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    search += " and t_incsalary.level  in (31,32,33,51,52,53) "
    search += " and t_incsalary.updcode not in (600 ,601) "
    search += " and t_incsalary.j18code <> 7 "
    if year[4].to_s == '2'
      fiscal_year = "#{year[0..3].to_i - 543}-09-30"
      search += " and pispersonel.retiredate <> '#{fiscal_year}'"
    end
    
    cn = TIncsalary.count(:all,:conditions => search)
    if cn > 0
      ##เก็บ pcode ลง array
      arr_p = []
      d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
      rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
      for i in 0...rs_p.length
        arr_p.push(rs_p[i].pcode.to_i)
      end
      ##เก็บ c ลง array
      arr_c = []
      d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
      rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      ##เก็บ section ลง array
      arr_sec = []
      d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
      rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
      for i in 0...rs_sec.length
        arr_sec.push(rs_sec[i].seccode.to_i)
      end      
      ##เก็บค่า position ลง array
      arr_pos = []
      d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
      rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
      for i in 0...rs_pos.length
        arr_pos.push(rs_pos[i].poscode.to_i)
      end
      rs = TIncsalary.select("pispersonel.pid,t_incsalary.*").joins("left join pispersonel on pispersonel.id = t_incsalary.id").find(:all,:conditions => search,:order => "rp_order,seccode")
      @records = []
      subdept_tmp = Csubdept.find(@user_work_place[:sdcode]).short_name
      for k in 0...(rs.length)
        u = rs[k]
        idx_c = arr_c.index(u.level.to_i)
        idx_p = arr_p.index(u.pcode.to_i)
        idx_sec = arr_sec.index(u.seccode.to_i)
        idx_pos = arr_pos.index(u.poscode.to_i)
        if k !=0
          if u.seccode != rs[k - 1].seccode         
            ###แสดงชื่อ กลุ่มงาน
            if u.seccode != ""
              @records.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :seccode => "",
                :secname => "",
                :posname => begin "<u>#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}</u>" rescue "" end,
                :midpoint => "",
                :calpercent => "",
                :newsalary => "",
                :diff => "",
                :note1 => ""
              })            
            end
          end
        else# == 0
            #แสดงชือหน่วยงาน
            @records.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :seccode => "",
              :secname => "",
              :posname => "<u>#{subdept_tmp}</u>",
              :midpoint => "",
              :calpercent => "",
              :newsalary => "",
              :diff => "",
              :note1 => ""
            })
            ###แสดงชื่อ กลุ่มงาน
            if u.seccode != ""
              @records.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :seccode => "",
                :secname => "",
                :posname => begin "<u>#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}</u>" rescue "" end,
                :midpoint => "",
                :calpercent => "",
                :newsalary => "",
                :diff => "",
                :note1 => ""
              }) 
            end
        end
        #แสดงรายการ แต่ละคน
        @records.push({   
          :i => k + 1,
          :posid => u.posid,
          :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}<br />#{format_pid u.pid.to_s}",
          :salary => u.salary,
          :clname => begin rs_c[idx_c].clname rescue "" end,
          :gname => begin rs_c[idx_c].gname rescue "" end,
          :seccode => u.seccode,
          :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
          :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
          :midpoint => u.midpoint,
          :calpercent => u.calpercent,
          :newsalary => u.newsalary,
          :diff => u.newsalary - u.salary,
          :note1 => u.note1
        })
      end
      prawnto :prawn => {
        #:page_layout=>:landscape,
        :top_margin => 120,
        :left_margin => 5,
        :right_margin => 5
      }
    end
  end

  
end
