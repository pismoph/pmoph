# coding: utf-8
class CalcUpSalaryController < ApplicationController
  before_filter :login_menu_command
  skip_before_filter :verify_authenticity_token
  def check_count
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} "
    cn = TIncsalary.count(:all,:conditions => search)
    render :text => {:cn => cn}.to_json, :layout => false  
  end
  
  def add
    begin
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
      @user_work_place.each do |key,val|
        if key.to_s == "mcode"
          k = "mincode"
        else
          k = key
        end
        search += " and pisj18.#{k} = '#{val}'"
      end
      column = "pisj18.posid,pisj18.poscode,pisj18.c as level,pisj18.salary"
      column += ",pisj18.sdcode,pisj18.seccode,pisj18.jobcode,pisj18.excode"
      column += ",pisj18.epcode,pispersonel.ptcode,pisj18.subdcode,pisj18.dcode"
      column += ",pispersonel.fname,pispersonel.lname,pispersonel.pcode"  
      column += ",pispersonel.dcode as wdcode,pispersonel.sdcode as wsdcode"
      column += ",pispersonel.seccode as wseccode,pispersonel.jobcode as wjobcode"
      column += ",pispersonel.subdcode as wsubdcode,pispersonel.j18code,pispersonel.id"
      column += ",'1' as flagcal,'N' as flag_inc"
      rs = Pisj18.select(column).joins(str_join).find(:all,:conditions => search)
      #เก็บ ค่า c ลง Array
      arr_c = []
      d_c = Pisj18.select(" distinct pisj18.c").joins(str_join).find(:all,:conditions => search).collect{|u| u.c }
      rs_c = Cgrouplevel.select("ccode,minsal1,maxsal1,minsal2,maxsal2,baselow,basehigh").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      #เก็บค่า order ลง Array j18
      arr_order = []
      d_wp = Pisj18.select(" distinct pisj18.seccode,pisj18.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] }
      for i in 0...d_wp.length
        rs_tmp = Corderrpt.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        if rs_tmp.length > 0
          arr_order.push({
            :sorder => rs_tmp[0].sorder,
            :seccode => rs_tmp[0].seccode,
            :jobcode => rs_tmp[0].jobcode
          })
        else
          arr_order.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })           
        end
      end
      #เก็บค่า order ลง Array ปฏิบัติงานจริง
      arr_orderwp = []
      d_wp2 = Pisj18.select(" distinct pispersonel.seccode,pispersonel.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] } 
      for i in 0...d_wp2.length
        rs_tmp2 = Corderrpt.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        if rs_tmp2.length > 0
          arr_orderwp.push({
            :sorder => rs_tmp2[0].sorder,
            :seccode => rs_tmp2[0].seccode,
            :jobcode => rs_tmp2[0].jobcode
          })
        else
          arr_orderwp.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })          
        end
      end
      #insert table
      vals = []
      rs.each do |v|
        idx_order = d_wp.index( [v.seccode.to_i,v.jobcode.to_i])
        idx_orderwp = d_wp2.index( [v.wseccode.to_i,v.wjobcode.to_i])
        idx_c = arr_c.index(v.level.to_i)
        midpoint = 0
        maxsalary  = 0
        if !idx_c.nil?
          case v.salary.to_f
            when rs_c[idx_c].minsal2.to_f..rs_c[idx_c].maxsal2.to_f
              midpoint = rs_c[idx_c].basehigh
              maxsalary  = rs_c[idx_c].maxsal2            
            when rs_c[idx_c].minsal1.to_f..rs_c[idx_c].maxsal1.to_f
              midpoint = rs_c[idx_c].baselow
              maxsalary  = rs_c[idx_c].maxsal1
          end
        end
        val = "('#{params[:fiscal_year].to_s + params[:round].to_s}'"
        val += ",'#{v.id}','#{v.posid}','#{v.poscode}','#{v.level}','#{v.salary}','#{v.sdcode}'"
        val += ",'#{(v.seccode.to_s == "")? 0 : v.seccode}','#{(v.jobcode.to_s == "")? 0 : v.jobcode}'"
        val += ",'#{v.excode}','#{v.fname}','#{v.lname}','#{v.pcode}','#{v.epcode}'"
        val += ",'#{v.ptcode}','#{v.flag_inc}','#{v.subdcode}','#{v.dcode}','#{v.wdcode}','#{v.wsdcode}'"
        val += ",'#{(v.wseccode.to_s == "")? 0 : v.wseccode}','#{(v.wjobcode.to_s == "")? 0 : v.wjobcode}'"
        val += ",'#{v.wsubdcode}','#{v.j18code}','#{v.flagcal}','#{midpoint}','#{maxsalary}'"
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}')"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order"
      if vals.length > 0
        QueryPis.insert_mass("t_incsalary",col,vals)
      end
      
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
    #########################################################################
  end
  
  def update
    begin
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1'"
      @user_work_place.each do |key,val|
        if key.to_s == "mcode"
          k = "mincode"
        else
          k = key
        end
        search += " and pisj18.#{k} = '#{val}'"
      end
      column = "pisj18.posid,pisj18.poscode,pisj18.c as level,pisj18.salary"
      column += ",pisj18.sdcode,pisj18.seccode,pisj18.jobcode,pisj18.excode"
      column += ",pisj18.epcode,pispersonel.ptcode,pisj18.subdcode,pisj18.dcode"
      column += ",pispersonel.fname,pispersonel.lname,pispersonel.pcode"  
      column += ",pispersonel.dcode as wdcode,pispersonel.sdcode as wsdcode"
      column += ",pispersonel.seccode as wseccode,pispersonel.jobcode as wjobcode"
      column += ",pispersonel.subdcode as wsubdcode,pispersonel.j18code,pispersonel.id"
      column += ",'1' as flagcal,'N' as flag_inc"
      rs = Pisj18.select(column).joins(str_join).find(:all,:conditions => search)
      #เก็บ ค่า c ลง Array
      arr_c = []
      d_c = Pisj18.select(" distinct pisj18.c").joins(str_join).find(:all,:conditions => search).collect{|u| u.c }
      rs_c = Cgrouplevel.select("ccode,minsal1,maxsal1,minsal2,maxsal2,baselow,basehigh").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      #เก็บค่า order ลง Array j18
      arr_order = []
      d_wp = Pisj18.select(" distinct pisj18.seccode,pisj18.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] }
      for i in 0...d_wp.length
        rs_tmp = Corderrpt.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        if rs_tmp.length > 0
          arr_order.push({
            :sorder => rs_tmp[0].sorder,
            :seccode => rs_tmp[0].seccode,
            :jobcode => rs_tmp[0].jobcode
          })
        else
          arr_order.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })           
        end
      end
      #เก็บค่า order ลง Array ปฏิบัติงานจริง
      arr_orderwp = []
      d_wp2 = Pisj18.select(" distinct pispersonel.seccode,pispersonel.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] } 
      for i in 0...d_wp2.length
        rs_tmp2 = Corderrpt.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        if rs_tmp2.length > 0
          arr_orderwp.push({
            :sorder => rs_tmp2[0].sorder,
            :seccode => rs_tmp2[0].seccode,
            :jobcode => rs_tmp2[0].jobcode
          })
        else
          arr_orderwp.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })          
        end
      end
      #insert table
      vals = []
      rs.each do |v|
        idx_order = d_wp.index( [v.seccode.to_i,v.jobcode.to_i])
        idx_orderwp = d_wp2.index( [v.wseccode.to_i,v.wjobcode.to_i])
        idx_c = arr_c.index(v.level.to_i)
        midpoint = 0
        maxsalary  = 0
        if !idx_c.nil?
          case v.salary.to_f
            when rs_c[idx_c].minsal2.to_f..rs_c[idx_c].maxsal2.to_f
              midpoint = rs_c[idx_c].basehigh
              maxsalary  = rs_c[idx_c].maxsal2            
            when rs_c[idx_c].minsal1.to_f..rs_c[idx_c].maxsal1.to_f
              midpoint = rs_c[idx_c].baselow
              maxsalary  = rs_c[idx_c].maxsal1
          end
        end
        val = "('#{params[:fiscal_year].to_s + params[:round].to_s}'"
        val += ",'#{v.id}','#{v.posid}','#{v.poscode}','#{v.level}','#{v.salary}','#{v.sdcode}'"
        val += ",'#{(v.seccode.to_s == "")? 0 : v.seccode}','#{(v.jobcode.to_s == "")? 0 : v.jobcode}'"
        val += ",'#{v.excode}','#{v.fname}','#{v.lname}','#{v.pcode}','#{v.epcode}'"
        val += ",'#{v.ptcode}','#{v.flag_inc}','#{v.subdcode}','#{v.dcode}','#{v.wdcode}','#{v.wsdcode}'"
        val += ",'#{(v.wseccode.to_s == "")? 0 : v.wseccode}','#{(v.wjobcode.to_s == "")? 0 : v.wjobcode}'"
        val += ",'#{v.wsubdcode}','#{v.j18code}','#{v.flagcal}','#{midpoint}','#{maxsalary}'"
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}')"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order"
      if vals.length > 0
        TIncsalary.transaction do
          search_del = "year = '#{params[:fiscal_year].to_s + params[:round].to_s}' "
          @user_work_place.each do |key,val|
            if key.to_s != "mcode" and key.to_s != "deptcode"
              search_del += " and t_incsalary.#{key} = '#{val}' " 
            end
          end
          TIncsalary.delete_all(search_del)
          QueryPis.insert_mass("t_incsalary",col,vals) 
        end        
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
    #########################################################################
  end
  
  
  def read
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} "
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
    
    rs = TIncsalary.find(:all,:conditions => search,:order => :posid)
    return_data = {}
    return_data[:totalCount] = TIncsalary.count(:all,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      idx_c = arr_c.index(u.level.to_i)
      idx_j18 = arr_j18.index(u.j18code.to_i)
      {
        :posid => u.posid,
        :fname => u.fname,
        :lname => u.lname,
        :cname => begin rs_c[idx_c].cname rescue "" end,
        :salary => u.salary,
        :j18status => begin rs_j18[idx_j18].j18status rescue "" end,
        :note1 => u.note1,
        :flagcal => (u.flagcal == '1') ? true : false,
        :midpoint => u.midpoint,
        :year => u.year,
        :id => u.id
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def update_table
    begin
     data = ActiveSupport::JSON.decode(params[:data])
     TIncsalary.transaction do
      data.each do |v|
        sql = "update t_incsalary set note1='#{v["note1"]}',flagcal=#{(v["flagcal"] == true)? 1 : 0} "
        sql += " where year = #{v["year"]} and id = '#{v["id"]}' and sdcode = #{@user_work_place[:sdcode]}"
        ActiveRecord::Base.connection.execute(sql)
      end       
     end
     render :text => "{success: true}"
    rescue
      render :text => "{success: false}"  
    end
    
  end
  
  def get_config
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} "
      return_data = {}
      return_data[:totalCount] = TKs24usemain.count(:all,:conditions => search)
      if return_data[:totalCount] > 0
        rs = TKs24usemain.find(:all,:conditions => search).first
        return_data[:data]   = {
          :salary => rs.salary,
          :calpercent => rs.calpercent,
          :ks24 => rs.ks24
        }
      end
      return_data[:success] = true
      render :text => return_data.to_json,:layout => false
    rescue
      render :text => "{success: false}"  
    end
  end
  
  def update_t_ks24usemain
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} "
    @user_work_place.each do |key,val|
      if key.to_s == "sdcode"
        search += " and #{key} = '#{val}' " 
      end
    end
    cn = TKs24usemain.count(:all,:conditions => search)
    if cn == 0
      rs = TKs24usemain.new(params[:config_cal])
      rs.year = year
      rs.sdcode = @user_work_place[:sdcode]
      if rs.save
        render :text => "{success:true}"
      else
        render :text => "{success:false,msg:'กรุณาลองใหม่อีกครั้ง'}"
      end
    else
      rs = TKs24usemain.find(:all,:conditions => search).first
      if rs.update_attributes(params[:config_cal])
        render :text => "{success:true}"
      else
        render :text => "{success:false,msg:'กรุณาลองใหม่อีกครั้ง'}"
      end
    end
    
  end
  
  def reportj18
    @records = []
    @year = params[:year]
    year = params[:year]
    search = " year = #{year} and flagcal = '1' and t_incsalary.j18code in (1,2,3,4,5,6) and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname "
    
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "rp_order,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode")
    
    for i in 0...rs.length
      @records.push({   
        :i => i+1,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => rs[i].salary,
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })       
    end
    prawnto :prawn => {
        :top_margin => 120,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def reportwork
    @records = []
    @year = params[:year]
    year = params[:year]
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null "
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname "
    
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "rp_order,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode")
    
    for i in 0...rs.length
      @records.push({   
        :i => i+1,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => rs[i].salary,
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })       
    end
    prawnto :prawn => {
        :top_margin => 120,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def reportnumber
    rs_subdept = Csubdept.find(@user_work_place[:sdcode])
    @subdeptname = "#{rs_subdept.shortpre}#{rs_subdept.subdeptname}"
    @search = " year = #{params[:year]} and sdcode = #{@user_work_place[:sdcode]} "
    prawnto :prawn => {
        :top_margin => 110,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def reportmoney
    rs_subdept = Csubdept.find(@user_work_place[:sdcode])
    @subdeptname = "<b>#{long_title_head_subdept}#{rs_subdept.shortpre}#{rs_subdept.subdeptname}</b>"
    @search = " year = #{params[:year]} and sdcode = #{@user_work_place[:sdcode]} "
    prawnto :prawn => {
        :top_margin => 80,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
end
