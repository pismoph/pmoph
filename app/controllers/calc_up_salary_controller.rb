# coding: utf-8
class CalcUpSalaryController < ApplicationController
  before_filter :login_menu_command
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
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
        note1 = "null"
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
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}'"
        if maxsalary.to_i == v.salary.to_i
          note1 = "'เต็มขั้น'"
        end
        val += ",#{note1})"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order,note1"
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
        note1 = "null"
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
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}'"
        if maxsalary.to_i == v.salary.to_i
          note1 = "'เต็มขั้น'"
        end
        val += ",#{note1})"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order,note1"
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
    records1 = []
    records2 = []
    records3 = []
    records4 = []
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    total_n = 0
    total_sal = 0
    row_n = 0
    ################################################รพศ/รพท
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderrpt on COALESCE(t_incsalary.seccode,0) = corderrpt.seccode and COALESCE(t_incsalary.jobcode,0) = corderrpt.jobcode "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    search += " and t_incsalary.j18code in (1,2,3,4,5,6)  "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderrpt.seccode as odsec,corderrpt.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,corderrpt.sorder,t_incsalary.seccode,t_incsalary.jobcode")    
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records1.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records1.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    ################################################สสจ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    search += " and csubdept.sdtcode in (10) "
    search += " and t_incsalary.j18code in (1,2,3,4,5,6)  "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,corderssj.sorder,t_incsalary.seccode,t_incsalary.jobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records2.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records2.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    
    ################################################ รพช
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    search += " and t_incsalary.j18code in (1,2,3,4,5,6)  "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,corderssj.sorder,t_incsalary.seccode,t_incsalary.jobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
        })         
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].provcode.to_s != rs[i - 1].provcode
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })          
        end
        
        
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records3.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end

    ################################################สสอ  สอ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    search += " and csubdept.sdtcode in (16,17,18)"
    search += " and t_incsalary.j18code in (1,2,3,4,5,6)  "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,corderssj.sorder,t_incsalary.seccode,t_incsalary.jobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
        })         
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].provcode.to_s != rs[i - 1].provcode
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })          
        end
        
        
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records4.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].sdcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    
    order_arr = [
      [2,3,4,5,6,7,8,9],
      [10],
      [11,12,13,14,15],
      [16,17,18]
    ]
    order_check = ""
    rs = Csubdept.find(@user_work_place[:sdcode])
    
    for i in 0...order_arr.length
      if order_arr[i].include?(rs.sdtcode.to_i)
        order_check = i + 1
      end
    end
    
    case order_check
      when 1
        @records += records1
      when 2
        @records += records2
      when 3
        @records += records3
      when 4
        @records += records4
    end
    
      
    if order_check != 1
      @records += records1
    end
    
    if order_check != 2
      @records += records2
    end
    
    if order_check != 3
      @records += records3
    end
    
    if order_check != 4
      @records += records4
    end
    
    @records.push({   
      :i => "",
      :posid => "รวมเงิน",
      :name => "รวมทั้งหมด = #{number_with_delimiter(total_n.to_i.ceil)}" ,
      :salary => "#{number_with_delimiter(total_sal.to_i.ceil)}",
      :clname => "",
      :gname => "",
      :posname => "",
    })
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
    records1 = []
    records2 = []
    records3 = []
    records4 = []
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    total_n = 0
    total_sal = 0
    row_n = 0
    ################################################รพศ/รพท
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderrpt on COALESCE(t_incsalary.wseccode,0) = corderrpt.seccode and COALESCE(t_incsalary.wjobcode,0) = corderrpt.jobcode "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderrpt.seccode as odsec,corderrpt.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,corderrpt.sorder,t_incsalary.wseccode,t_incsalary.wjobcode")    
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records1.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records1.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    ################################################สสจ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null "
    search += " and csubdept.sdtcode in (10) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records2.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records2.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    
    ################################################ รพช
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
        })         
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].provcode.to_s != rs[i - 1].provcode
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })          
        end
        
        
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records3.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end

    ################################################สสอ  สอ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null "
    search += " and csubdept.sdtcode in (16,17,18)"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode")
    for i in 0...rs.length
      row_n += 1
      subdeptname = "#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "#{rs[i].jobname}".strip
      if i == 0
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
        })         
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].provcode.to_s != rs[i - 1].provcode
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })          
        end
        
        
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].subdeptpre}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{secname if secname != ""}</u>",
            })
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records4.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => [rs[i].pospre.to_s,rs[i].posname].join("").strip,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
        end
        if rs[i].wsdcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].subdeptpre}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
        end
      end
    end
    
    order_arr = [
      [2,3,4,5,6,7,8,9],
      [10],
      [11,12,13,14,15],
      [16,17,18]
    ]
    order_check = ""
    rs = Csubdept.find(@user_work_place[:sdcode])
    
    for i in 0...order_arr.length
      if order_arr[i].include?(rs.sdtcode.to_i)
        order_check = i + 1
      end
    end
    
    case order_check
      when 1
        @records += records1
      when 2
        @records += records2
      when 3
        @records += records3
      when 4
        @records += records4
    end
    
      
    if order_check != 1
      @records += records1
    end
    
    if order_check != 2
      @records += records2
    end
    
    if order_check != 3
      @records += records3
    end
    
    if order_check != 4
      @records += records4
    end
    
    @records.push({   
      :i => "",
      :posid => "รวมเงิน",
      :name => "รวมทั้งหมด = #{number_with_delimiter(total_n.to_i.ceil)}" ,
      :salary => "#{number_with_delimiter(total_sal.to_i.ceil)}",
      :clname => "",
      :gname => "",
      :posname => "",
    })
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
    prawnto :prawn => {
        :top_margin => 80,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
end
