# coding: utf-8
class UpSalaryController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
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
        :sdcode => u.sdcode,
        :updcode => u.updcode
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
          val.push("calpercent = #{ (u["calpercent"].to_s == "")? "null" : u["calpercent"] }")
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
      search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} and flagcal = '1' and level in #{params[:level]} and addmoney > 0 and length(trim(addmoney::varchar)) != 0 "
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
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
    @usesub_id = TKs24usesub.find(:all,:conditions => "officecode = #{@user_work_place[:sdcode]}",:order => "id").collect{|u| u.id }
  
    prawnto :prawn => {
        :top_margin => 80,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def report2_excel
    year = params[:fiscal_year].to_s + params[:round].to_s
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "rp_order,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode")
    
    i = 0
    @records = rs.collect{|u|
      i += 1
      {
        :idx => i,
        :posid => u.posid,
        :name => ["#{u.prefix}#{u.fname}",u.lname].join(" ").strip,
        :pid => "#{format_pid u.pid}",
        :salary => u.salary,
        :midpoint => u.midpoint,
        :score => u.score,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney.to_s,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :id => u.id,
        :clname => u.clname,
        :gname => u.gname,
        :posname => [u.pospre.to_s,u.posname].join("").strip,
        :secname => [u.secshort.to_s,u.secname].join("").strip,
        :seccode => u.seccode,
        :calpercent => u.calpercent
      }
    }
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
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
  
  def report2
    @records = []
    @year = params[:fiscal_year].to_s + params[:round].to_s
    year = params[:fiscal_year].to_s + params[:round].to_s
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    prawnto :prawn => {
        :page_layout=>:landscape,
        :top_margin => 50,
        :left_margin => 5,
        :right_margin => 5
    }
  end
  
  
  def report3
    @records = []
    @year = params[:fiscal_year].to_s + params[:round].to_s
    year = params[:fiscal_year].to_s + params[:round].to_s
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.level in (34,35) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.level in (34,35) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.level in (34,35) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.level in (34,35) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    prawnto :prawn => {
        :page_layout=>:landscape,
        :top_margin => 50,
        :left_margin => 5,
        :right_margin => 5
    }
  end
  
  def report4
    @records = []
    @year = params[:fiscal_year].to_s + params[:round].to_s
    year = params[:fiscal_year].to_s + params[:round].to_s
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year}  "
    search += " and t_incsalary.level in (21,22) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null  "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year}  "
    search += " and t_incsalary.level in (21,22) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null  "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year}  "
    search += " and t_incsalary.level in (21,22) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null  "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year}  "
    search += " and t_incsalary.level in (21,22) and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' and wsdcode is not null  "
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    prawnto :prawn => {
        :page_layout=>:landscape,
        :top_margin => 50,
        :left_margin => 5,
        :right_margin => 5
    }
  end
  
  def report5
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.j18code = 7 and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.j18code = 7 and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.j18code = 7 and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.j18code = 7 and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    }
  end
  
  def report6
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    @province = Csubdept.find(@user_work_place[:sdcode]).provcode
    @province = begin
      Cprovince.find(@province).full_name
    rescue
      ""
    end
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    } 
  end

  def report7
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.addmoney > 0 "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.addmoney > 0 "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.addmoney > 0 "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.addmoney > 0 "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    @province = Csubdept.find(@user_work_place[:sdcode]).provcode
    @province = begin
      Cprovince.find(@province).full_name
    rescue
      ""
    end
    
    prawnto :prawn => {
      :page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    }  
  end

  def report8
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 )"
    search += " and t_incsalary.level in (31,32,33,51,52,53)"
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 )"
    search += " and t_incsalary.level in (31,32,33,51,52,53)"
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 )"
    search += " and t_incsalary.level in (31,32,33,51,52,53)"
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 )"
    search += " and t_incsalary.level in (31,32,33,51,52,53)"
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    @province = Csubdept.find(@user_work_place[:sdcode]).provcode
    @province = begin
      Cprovince.find(@province).full_name
    rescue
      ""
    end
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    } 
  end

  def report9
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode not in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    @province = Csubdept.find(@user_work_place[:sdcode]).provcode
    @province = begin
      Cprovince.find(@province).full_name
    rescue
      ""
    end
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    }    
  end

  def report10
    @records = []
    #@year = params[:fiscal_year].to_s + params[:round].to_s
    #year = params[:fiscal_year].to_s + params[:round].to_s
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records1.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    ################################################สสจ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (10) "
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
        })
      else
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records2.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end
    
    ################################################ รพช
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
            })
            records3.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
    end

    ################################################สสอ  สอ
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
    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.updcode in ( 600,601 ) "
    search += " and t_incsalary.level in (31,32,33,51,52,53) "
    search += " and pispersonel.retiredate between '#{year[0..3].to_i - 544}-10-01' and '#{year[0..3].to_i - 543}-09-30' "
    search += " and t_incsalary.j18code <> 7 "
    search += " and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    search += " and csubdept.sdtcode in (16,17,18)"
    
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
        })         
        records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
          })          
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
            :pid => "",
            :midpoint => "",
            :score => "",
            :newsalary => "",
            :addmoney => "",
            :note1 => "",
            :maxsalary => "",
            :id => "",
            :secname => "",
            :seccode => "",
            :calpercent => "",:diff =>""            
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
            })
            records4.push({   
                :i => "",
                :posid => "",
                :name => "" ,
                :salary => "",
                :clname => "",
                :gname => "",
                :posname => "<u>#{jobname if jobname != ""}</u>",
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""                
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
                :pid => "",
                :midpoint => "",
                :score => "",
                :newsalary => "",
                :addmoney => "",
                :note1 => "",
                :maxsalary => "",
                :id => "",
                :secname => "",
                :seccode => "",
                :calpercent => "",:diff =>""              
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
        :pid => "#{format_pid rs[i].pid}",
        :midpoint => number_with_delimiter(rs[i].midpoint.to_i.ceil),
        :score => rs[i].score,
        :newsalary => number_with_delimiter(rs[i].newsalary.to_i.ceil),
        :addmoney => (rs[i].addmoney.to_s == "")? "" : number_with_delimiter( "%.2f" % rs[i].addmoney),
        :note1 => rs[i].note1,
        :maxsalary => number_with_delimiter(rs[i].maxsalary.to_i.ceil),
        :id => rs[i].id,
        :secname => [rs[i].secshort.to_s,rs[i].secname].join("").strip,
        :seccode => rs[i].seccode,
        :calpercent => rs[i].calpercent,
        :diff => number_with_delimiter((rs[i][:newsalary].to_f - rs[i][:salary].to_f).to_i.ceil)
      })
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
    
    @province = Csubdept.find(@user_work_place[:sdcode]).provcode
    @province = begin
      Cprovince.find(@province).full_name
    rescue
      ""
    end
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 120,
      :left_margin => 5,
      :right_margin => 5
    }
  end

  def report11_1
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
    @t_ks24usemain = TKs24usemain.find(:all,:conditions => " sdcode = #{@user_work_place[:sdcode]} and year = #{params[:year]} ")
    year = params[:year]    
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.j18code in (1,2,3,4,5,6) "
    search += " and t_incsalary.updcode in (601,626) "
    search += " and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "    
    @rs_group = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs_group = @rs_group.select("gname,clname")
    @rs_group = @rs_group.find(:all ,:conditions => search,:group => "gname,clname",:order => "gname,clname")
    
    @rs1 = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs1 = @rs1.select("gname,clname,count(*) as cn,sum(t_incsalary.newsalary - t_incsalary.salary) as salary")
    @rs1 = @rs1.find(:all ,:conditions => "#{search} and (t_incsalary.newsalary - t_incsalary.salary) > 0 ",:group => "gname,clname",:order => "gname,clname")
    
    @rs2 = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs2 = @rs2.select("gname,clname,count(*) as cn,sum(t_incsalary.addmoney) as salary")
    @rs2 = @rs2.find(:all ,:conditions => "#{search} and addmoney > 0 ",:group => "gname,clname",:order => "gname,clname" )
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 188,
      :left_margin => 5,
      :right_margin => 5
    }
  end
  
  def report11_2
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
    @t_ks24usemain = TKs24usemain.find(:all,:conditions => " sdcode = #{@user_work_place[:sdcode]} and year = #{params[:year]} ")
    year = params[:year]
    search = " t_incsalary.year = #{year} "
    search += " and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.j18code in (1,2,7) "
    search += " and t_incsalary.updcode in (601,626) "
    #search += " and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    @rs_group = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs_group = @rs_group.select("gname,clname")
    @rs_group = @rs_group.find(:all ,:conditions => search,:group => "gname,clname",:order => "gname,clname")
    
    @rs1 = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs1 = @rs1.select("gname,clname,count(*) as cn,sum(t_incsalary.newsalary - t_incsalary.salary) as salary")
    @rs1 = @rs1.find(:all ,:conditions => "#{search} and (t_incsalary.newsalary - t_incsalary.salary) > 0 ",:group => "gname,clname",:order => "gname,clname")
    
    @rs2 = TIncsalary.joins("left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level ")
    @rs2 = @rs2.select("gname,clname,count(*) as cn,sum(t_incsalary.addmoney) as salary")
    @rs2 = @rs2.find(:all ,:conditions => "#{search} and addmoney > 0 ",:group => "gname,clname",:order => "gname,clname" )
    
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 188,
      :left_margin => 5,
      :right_margin => 5
    }
  end
  
  def report12
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_shortpre_name
    year = params[:year]
    sel = " t_ks24usesub.usename,t_ks24usesubdetail.e_name,t_ks24usesub.ks24,t_ks24usesubdetail.e_begin,t_ks24usesubdetail.e_end,t_ks24usesubdetail.up,sum(t_incsalary.newsalary) as a,sum(t_incsalary.salary) as b, sum(t_incsalary.addmoney) as c,count(*) as cn"
    str_j = " left join t_ks24usesub on t_ks24usesub.id = t_ks24usesubdetail.id and t_ks24usesub.year = t_ks24usesubdetail.year "
    str_j += " left join t_incsalary on t_ks24usesubdetail.id = t_incsalary.evalid1 and t_ks24usesubdetail.year = t_incsalary.year and t_ks24usesubdetail.dno = t_incsalary.evalno "
    
    where = " t_ks24usesub.year = #{year} and t_ks24usesub.officecode  = #{@user_work_place[:sdcode]} "
    where += " and t_ks24usesubdetail.year = #{year} and t_incsalary.year = #{year} "
    group_by = " t_ks24usesub.usename,t_ks24usesubdetail.e_name,t_ks24usesub.ks24,t_ks24usesubdetail.e_begin,t_ks24usesubdetail.e_end,t_ks24usesubdetail.up "
    @rs = TKs24usesubdetail.joins(str_j).select(sel).find(:all,:conditions => where,:group => group_by,:order => " t_ks24usesub.usename,t_ks24usesubdetail.e_name " )
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 90,
      :left_margin => 5,
      :right_margin => 5
    }
  end
  
  def personel_t_incsalary
    limit = params[:limit]
    start = params[:start]
    search = " t_incsalary.year = #{params[:year]} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and t_incsalary.flagcal = '1' "
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      for i in 0...allfields.length
        case allfields[i]
          when "fname","lname","posid"
            allfields[i] = "t_incsalary.#{allfields[i]}"
          when "prefix"
            allfields[i] = "cprefix.#{allfields[i]}"
        end
      end
      search += " and #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} "
    end
    str_join = " left join cprefix on cprefix.pcode = t_incsalary.pcode "
    rs = TIncsalary.select("t_incsalary.*,cprefix.prefix").joins(str_join).find(:all,:conditions => search, :limit => limit, :offset => start)
    return_data = {}
    return_data[:totalCount] = TIncsalary.joins(str_join).count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      {
        :id => u.id,
        :prefix => u.prefix,
        :fname => u.fname,
        :lname => u.lname,
        :posid => u.posid
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def report13
    search = " t_incsalary.year = #{params[:year]} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    @head_subdept = head_subdept
    if params[:id].to_s != ""
      search += " and t_incsalary.id = '#{params[:id]}' "
    end
    str_join = " left join cprefix on cprefix.pcode = t_incsalary.pcode "
    str_join += " left join cposition on cposition.poscode = t_incsalary.poscode"
    str_join += " left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level "
    str_join += " left join csection on csection.seccode = t_incsalary.seccode "
    str_join += " left join cjob on cjob.jobcode = t_incsalary.jobcode "
    str_join += " left join csubdept on csubdept.sdcode = t_incsalary.sdcode "
    str_join += " left join cprovince on cprovince.provcode = csubdept.provcode"
    str_join += " left join t_ks24usesubdetail on t_ks24usesubdetail.id = t_incsalary.evalid1 and t_ks24usesubdetail.year = t_incsalary.year and t_ks24usesubdetail.dno = t_incsalary.evalno "
    select = "cprefix.*,cposition.*,cgrouplevel.*,csubdept.longpre as longpre_subdept,csubdept,subdeptname,csubdept.sdtcode,cprovince.provname"
    select += ",csection.shortname||csection.secname as secname"
    select += ",cjob.jobname"
    select += ",t_incsalary.*"
    select += ",t_ks24usesubdetail.up"
    @rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search)
    prawnto :prawn => {
      #:page_layout=>:landscape,
      :top_margin => 100,
      :left_margin => 5,
      :right_margin => 5
    }
  end
  
  def report14
    year = params[:year]
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
    str_join = " left join cupdate on cupdate.updcode = t_incsalary.updcode "
    sel = "t_incsalary.*,cupdate.*"
    rs = TIncsalary.select(sel).joins(str_join).find(:all,:conditions => search,:order => "seccode,posid")
    
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
        :calpercent => u.calpercent,
        :rp_order => u.rp_order,
        :updname => u.updname,
        :level => u.level
      }
    }
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    respond_to do |format|
      format.xls  {  }
      format.pdf  {
        prawnto :prawn=>{
          :page_layout=>:landscape,
          :top_margin => 50,
          :left_margin => 5,
          :right_margin => 5
        }
        render :action => "report", :layout => false
      }
    end
  end


end
