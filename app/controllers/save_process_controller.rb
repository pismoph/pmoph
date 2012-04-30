# coding: utf-8
#require "spreadsheet/excel"
class SaveProcessController < ApplicationController
  #include Spreadsheet
  include ActionView::Helpers::NumberHelper
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def formula
    tmp = []
    return_data = {}
    return_data[:records] = []
    if params[:formula].to_s == "1"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "1",:e_name => "พอใช้",:e_begin => "60.00",:e_end => "69.99",:up => "2",:idx => 2 })
      tmp.push({:dno => "2",:e_name => "ดี",:e_begin => "70.00",:e_end => "79.99",:up => "3",:idx => 3 })
      tmp.push({:dno => "3",:e_name => "ดีมาก",:e_begin => "80.00",:e_end => "89.99",:up => "4",:idx => 4 })
      tmp.push({:dno => "4",:e_name => "ดีเด่น",:e_begin => "90.00",:e_end => "100",:up => "5",:idx => 5 })      
    end
    if params[:formula].to_s == "2"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "11",:e_name => "พอใช้ 1",:e_begin => "60.00",:e_end => "63.99",:up => "1",:idx => 2 })
      tmp.push({:dno => "12",:e_name => "พอใช้ 2",:e_begin => "64.00",:e_end => "66.99",:up => "1.5",:idx => 3 })
      tmp.push({:dno => "13",:e_name => "พอใช้ 3",:e_begin => "67.00",:e_end => "69.99",:up => "1.7",:idx => 4 })
      tmp.push({:dno => "21",:e_name => "ดี 1",:e_begin => "70.00",:e_end => "73.99",:up => "2",:idx => 5 })
      tmp.push({:dno => "22",:e_name => "ดี 2",:e_begin => "74.00",:e_end => "76.99",:up => "2.2",:idx => 6 })
      tmp.push({:dno => "23",:e_name => "ดี 3",:e_begin => "77.00",:e_end => "79.99",:up => "2.7",:idx => 7 })
      tmp.push({:dno => "31",:e_name => "ดีมาก 1",:e_begin => "80.00",:e_end => "83.99",:up => "3",:idx => 8 })
      tmp.push({:dno => "32",:e_name => "ดีมาก 2",:e_begin => "84.00",:e_end => "86.99",:up => "3.3",:idx => 9 })
      tmp.push({:dno => "33",:e_name => "ดีมาก 3",:e_begin => "87.00",:e_end => "89.99",:up => "3.6",:idx => 10 })
      tmp.push({:dno => "41",:e_name => "ดีเด่น 1",:e_begin => "90.00",:e_end => "93.99",:up => "3.9",:idx => 11 })
      tmp.push({:dno => "42",:e_name => "ดีเด่น 2",:e_begin => "94.00",:e_end => "96.99",:up => "4.2",:idx => 12 })
      tmp.push({:dno => "43",:e_name => "ดีเด่น 3",:e_begin => "97.00",:e_end => "100",:up => "4.5",:idx => 13 })
    end
    if params[:formula].to_s == "3"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "11",:e_name => "พอใช้ 1",:e_begin => "60.00",:e_end => "65.99",:up => "1",:idx => 2 })
      tmp.push({:dno => "12",:e_name => "พอใช้ 2",:e_begin => "66.00",:e_end => "69.99",:up => "1.5",:idx => 3 })
      tmp.push({:dno => "21",:e_name => "ดี 1",:e_begin => "70.00",:e_end => "75.99",:up => "2",:idx => 4 })
      tmp.push({:dno => "22",:e_name => "ดี 2",:e_begin => "76.00",:e_end => "79.99",:up => "2.2",:idx => 5 })      
      tmp.push({:dno => "31",:e_name => "ดีมาก 1",:e_begin => "80.00",:e_end => "85.99",:up => "3",:idx => 6 })
      tmp.push({:dno => "32",:e_name => "ดีมาก 2",:e_begin => "86.00",:e_end => "89.99",:up => "3.3",:idx => 7 })
      tmp.push({:dno => "41",:e_name => "ดีเด่น 1",:e_begin => "90.00",:e_end => "95.99",:up => "3.9",:idx => 8 })
      tmp.push({:dno => "42",:e_name => "ดีเด่น 2",:e_begin => "96.00",:e_end => "100",:up => "4.2",:idx => 9 })      
    end
    
    if params[:formula].to_s == ""
      i = 0
      year = params[:fiscal_year].to_s + params[:round]
      rs = TKs24usesubdetail.find(:all,:conditions => "year = #{year} and id = #{params[:id]}")
      tmp = rs.collect{|u|
        rs_inc = TIncsalary.select("sum(newsalary) as a,sum(salary) as b,sum(addmoney) as c,count(*) as cn")
        rs_inc = rs_inc.find(:all,:conditions => "year = #{u.year} and evalid1 = #{u.id} and evalno = #{u.dno} ")[0]
        i += 1
        {
          :dno => u.dno,
          :e_name => u.e_name,
          :e_begin => u.e_begin,
          :e_end => u.e_end,
          :up => u.up,
          :idx => i,
          :salary => rs_inc.a.to_f - rs_inc.b.to_f + rs_inc.c.to_f,
          :n => rs_inc.cn
        }
      }
    end
    return_data[:records] = tmp
    render :text => return_data.to_json,:layout => false
  end
  
  def read
    year = params[:fiscal_year].to_s + params[:round]
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and evalid1 = #{params[:id]} and flagcal = '1' and sdcode = '#{@user_work_place[:sdcode]}' "
    end
    
    if @current_user.group_user.type_group.to_s == "2"
      search_id = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
      sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search_id}" 
      sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search_id}"
      sql_id = "(#{sql_j18}) union (#{sql_person})"
      search = " year = #{year} and evalid1 = #{params[:id]} and flagcal = '1' and id in (#{sql_id}) "
    end    
    
    str_join = " left join cupdate on t_incsalary.updcode = cupdate.updcode"
    rs = TIncsalary.select("t_incsalary.*,cupdate.updname").joins(str_join).find(:all,:conditions => search,:order => :posid)
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    i = 0
    return_data = {}
    if params[:file].to_s == ""
      return_data[:records]   = rs.collect{|u|
        i += 1
        idx_p = arr_p.index(u.pcode.to_i)
        {
          :idx => i,
          :posid => u.posid,
          :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
          :salary => number_with_delimiter(u.salary.to_i),
          :midpoint => number_with_delimiter(u.midpoint.to_i),
          :score => u.score,
          :newsalary => number_with_delimiter(u.newsalary.to_i),
          :addmoney => number_with_delimiter(u.addmoney),
          :note1 => u.note1,
          :maxsalary => u.maxsalary,
          :id => u.id,
          :updname => u.updname
        }
      }
    else
      map_column = ActiveSupport::JSON.decode(params[:map_column])
      col_posid = ""
      col_score = ""
      col_note1 = ""
      posid = []
      score = []
      note1 = []
      map_column.each do |u|
        if u["col_name"].to_s == "posid"
          col_posid = u["config"].to_i
        end
        if u["col_name"].to_s == "score"
          col_score = u["config"].to_i
        end
        if u["col_name"].to_s == "note1"
          col_note1 = u["config"].to_i
        end
      end
      Spreadsheet.open(params[:file], "rb") do |book|
        sheet= book.worksheet(0)
        for i in 1...sheet.row_count
          posid.push(sheet[i,col_posid].to_i)
          score.push(sheet[i,col_score].to_i)
          note1.push(sheet[i,col_note1].to_s)
        end
        
        return_data[:records]   = rs.collect{|u|
          i += 1
          idx_p = arr_p.index(u.pcode.to_i)
          {
            :idx => i,
            :posid => u.posid,
            :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
            :salary => u.salary,
            :midpoint => u.midpoint,
            :score => begin score[posid.index(u.posid.to_i)] rescue "" end,
            :newsalary => "",
            :addmoney => "",
            :note1 => begin note1[posid.index(u.posid.to_i)] rescue "" end,
            :maxsalary => u.maxsalary,
            :id => u.id,
            :updname => u.updname
          }
        }
      end
      File.delete(params[:file]) 
    end
    render :text => return_data.to_json,:layout => false
  end
  
  def process_cal
    begin 
      year = params[:fiscal_year].to_s + params[:round]
      search_config = "year = #{year} and id = #{params[:id]}"
      search_user = " year = #{year} and evalid1 = #{params[:id]} and flagcal = '1' "
      data_user = ActiveSupport::JSON.decode(params[:data_user])
      data_config = ActiveSupport::JSON.decode(params[:data_config])
      val_config = []
      sql = ""
      pay =  0.0
      TIncsalary.transaction do
        ## t_ks24usesubdetail
        TKs24usesubdetail.delete_all(search_config)
        data_config.each do |u|
          val_config.push("(#{params[:id]},#{year},#{u["dno"]},'#{u["e_name"]}',#{u["e_begin"]},#{u["e_end"]},#{u["up"]})")
          #compare_config.push([u["e_begin"].to_f,u["e_end"].to_f,u["up"].to_f])
        end
        sql = "insert into t_ks24usesubdetail(id, year, dno, e_name, e_begin, e_end, up) values#{val_config.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
        ## TIncsalary
        data_user.each do |du|
          newsalary = "null"
          addmoney = "null"
          calpercent = "null"
          updcode = "null"
          evalno = "null"
          data_config.each do |dc|
            if dc["e_begin"].to_f <= du["score"].to_f and dc["e_end"].to_f >= du["score"].to_f
              evalno = dc["dno"]
              calpercent = dc["up"]
              newsalary = (dc["up"].to_f / 100.00)
              newsalary = newsalary * du["midpoint"].gsub(",","").to_f
              newsalary += du["salary"].gsub(",","").to_f
              if newsalary >= du["maxsalary"].gsub(",","").to_f
                addmoney = newsalary.to_f - du["maxsalary"].gsub(",","").to_f
                newsalary = du["maxsalary"].gsub(",","").to_f
                du["note1"] = "เต็มขั้น"
                updcode = 601
              else
                newsalary = ((newsalary/10).ceil)*10
                du["note1"] = ""
                updcode = 626
              end
              
              if du["score"].to_f <= 0
                du["note1"] = ""
                updcode = 600
              end
            end
            ########
          end
          sql = "update t_incsalary set "
          sql += " newsalary = #{(newsalary.to_s == "")? "null" : newsalary} "
          sql += " ,addmoney = #{(addmoney.to_s == "")? "null" : addmoney} "
          sql += " ,score = #{(du["score"].to_s == "")? "null" : du["score"]} "
          sql += " ,note1 = '#{(du["note1"].to_s == "")? "" : du["note1"]}' "
          sql += " ,calpercent = #{(calpercent.to_s == "")? "null" : calpercent} "
          sql += " ,updcode = #{(updcode.to_s == "")? "null" : updcode} "
          sql += " ,evalno = #{(evalno.to_s == "")? "null" : evalno} "
          sql += " where #{search_user} and id = '#{du["id"]}'"
          
          ActiveRecord::Base.connection.execute(sql)
          pay += (newsalary.to_f - du["salary"].gsub(",","").to_f).to_f + addmoney.to_f
        end
        ##############
        sql = "update t_ks24usesub set pay = #{pay} where year = #{year} and id = #{params[:id]} and officecode = '#{@user_work_place[:sdcode]}' "
        ActiveRecord::Base.connection.execute(sql)
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
  
  def report
    prefix_hospital_check = [2,3,4,5,6,7,8,9,11,12,13,14,15]
    prefix_province_check = [16,17,18]
    @records = []
    @year = params[:fiscal_year].to_s + params[:round].to_s
    year = params[:fiscal_year].to_s + params[:round].to_s
    records1 = []
    records2 = []
    records3 = []
    records4 = []
    records5 = []
    row_n = 0
    
    ####################################################
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    #sql_id = "(#{sql_j18}) union (#{sql_person})"
    sql_id = sql_j18   
    
    
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
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' "
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end    
    
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderrpt.seccode as odsec,corderrpt.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,corderrpt.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")    
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "งาน#{rs[i].jobname}".strip
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      
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
        :posname => pos,
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
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode and corderssj.sdtype = 1"
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' "
    search += " and csubdept.sdtcode in (10) "
    
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end
    
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "งาน#{rs[i].jobname}".strip
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      
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
        :posname => pos,
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
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode and corderssj.sdtype = 2"
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' "
    search += " and csubdept.sdtcode in (11,12,13,14,15)"
    
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end 
    
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "งาน#{rs[i].jobname}".strip
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
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
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
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
        :posname => pos,
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
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    #str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' "
    search += " and csubdept.sdtcode in (16,17,18)"
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end    
    
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,COALESCE(t_incsalary.wseccode,0) as odsec,COALESCE(t_incsalary.wjobcode,0) as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,t_incsalary.posid,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "งาน#{rs[i].jobname}".strip
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
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
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
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
        :posname => pos,
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
    
    ################################################ sdtcode > 18
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
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    #str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1' "
    search += " and csubdept.sdtcode > 18"
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end    
    
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,COALESCE(t_incsalary.wseccode,0) as odsec,COALESCE(t_incsalary.wjobcode,0) as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,t_incsalary.posid,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = "งาน#{rs[i].jobname}".strip
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      
      if i == 0
        records5.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{subdeptname if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
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
          records5.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{subdeptname if subdeptname != ""}</u>",
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
          records5.push({   
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
            records5.push({   
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
            records5.push({   
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
      records5.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => ["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
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
    @records += records5
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
  
  def upload
    begin
      t = Time.new
      data = {}
      file = Upload.save_process(params[:file],@current_user.id.to_s+"_#{t.to_i}")
      Spreadsheet.open(file[1], "rb") do |book|
        sheet= book.worksheet(0)
        data[:success] = true
        data[:column] = sheet.row(0)
        data[:file] = file[1].to_s
      end
      render :text => data.to_json,:layout => false
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาด'}",:layout => false
    end
  end
  
  def map_column
    tmp = []
    return_data = {}
    return_data[:records] = []
    tmp.push({:static => "เลขที่ตำแหน่ง",:col_name => "posid",:config => ""})
    tmp.push({:static => "คะแนน",:col_name => "score",:config => ""})
    tmp.push({:static => "หมายเหตุ",:col_name => "note1",:config => ""})
    return_data[:records] = tmp
    render :text => return_data.to_json,:layout => false
  end
  def report_limit
    year = params[:fiscal_year].to_s + params[:round].to_s
    
    ####################################################
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql_id = "(#{sql_j18}) union (#{sql_person})"
    
    @search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' and t_incsalary.flageval1 = '1' "
    
    @search += " and ((t_incsalary.newsalary - t_incsalary.salary) > 0 or t_incsalary.addmoney > 0)"
    
    if @current_user.group_user.type_group.to_s == "1"
      @search += " and t_incsalary.id in (#{sql_id}) "
    end
    if @current_user.group_user.type_group.to_s == "2"
      @search += " and t_incsalary.id in (#{sql_id})  "
    end
    
    
    type_title = head_subdept
    rs_subdept = Csubdept.find(@user_work_place[:sdcode])
    @subdeptname = rs_subdept.full_shortpre_name
    @title = ""
    type_title.each do|u|
      if !u[:arr].index(rs_subdept.sdtcode).nil?
        prov = begin
          Cprovince.find(rs_subdept.provcode)
        rescue
          ""
        end
        
        amp = begin
          Camphur.find(:all,:conditions => "amcode = '#{rs_subdept.amcode}' and provcode = '#{rs_subdept.provcode}'" )[0]
        rescue
          ""
        end
        address = "#{(prov == "")? "" : prov.provname}"
        address += " #{(amp == "")? "" : "#{amp.shortpre}#{amp.amname}"}"
        address += " #{(prov == "")? "" : "#{prov.shortpre}#{prov.provname}"}"
        @title = "#{u[:name]} #{address}"
      end
    end
    
    sql = "select cgrouplevel.gname,count(*) as n,sum(t_incsalary.newsalary) as a, sum(t_incsalary.salary) as b, sum(t_incsalary.addmoney) as c"
    sql += " from t_incsalary left join cgrouplevel on cgrouplevel.ccode = t_incsalary.level"
    sql += " where #{@search} "
    sql += " group by cgrouplevel.gname order by cgrouplevel.gname"
    @records1 = TIncsalary.find_by_sql(sql)
    @rs_ks24 = TKs24usesub.find(:all,:conditions => " officecode = '#{@user_work_place[:sdcode]}' and year = #{year} and id = #{params[:id]}")
    @rs_subdetail = TKs24usesubdetail.find(:all,:conditions => " year = #{year} and id = #{params[:id]} ",:order => "dno desc")
  end
  def report_excel
    year = params[:fiscal_year].to_s + params[:round].to_s
    
    ####################################################
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql_id = "(#{sql_j18}) union (#{sql_person})"
    
    
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' "
    search += " and t_incsalary.flageval1 = '1'  "
    
    if @current_user.group_user.type_group.to_s == "1"
      search += " and t_incsalary.id in (#{sql_id})  "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and t_incsalary.id in (#{sql_id})  "
    end
    
    
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
        :pid => "#{format_pid u.pid.to_s}",
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
    @subdeptname = Csubdept.find(@user_work_place[:sdcode]).short_name
    @usename = TKs24usesub.find(:all,:conditions => "year = #{year} and id = #{params[:id]}")[0].usename
    respond_to do |format|
      format.xls  { render :action => "report", :layout => false }
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
