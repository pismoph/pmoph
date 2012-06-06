# coding: utf-8
class InfoPersonalController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  def read
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
    str_join = " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      for i in 0...allfields.length
        case allfields[i]
          when "fname","lname","pid","birthdate","sex","tel","posid"
            allfields[i] = "pispersonel.#{allfields[i]}"
          when "prefix"
            allfields[i] = "cprefix.#{allfields[i]}"
        end
      end
      search += " and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
    end
    user_search = []
    search_j18 = ""
    search_personel = ""
    if @current_user.group_user.type_group.to_s == "1"
      @user_work_place.each do |key,val|
        if key.to_s == "mcode"
          k = "mincode"
        else
          k = key
        end
        user_search.push("pisj18.#{k} = '#{val}'")
      end
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
    end
    if user_search.length != 0
      if search == ""
        search_j18 = user_search.join(" and ")
        search_personel = user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      else
        search_j18 += " and " + user_search.join(" and ")
        search_personel += " and " + user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      end
    end
    sql_j18 = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search} #{search_j18}"
    sql_personel = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search} #{search_personel}"
    sql = "(#{sql_j18}) union (#{sql_personel})"
    sql = sql_j18
    rs = Pispersonel.find_by_sql("#{sql} limit #{limit} offset #{start}")
    return_data = {}
    return_data[:totalCount] = Pispersonel.find_by_sql("select count(*) as n from (#{sql}) as pis")[0].n
    return_data[:records]   = rs.collect{|u|
      prefix = (u.pcode.to_s == "")? "" : begin u.cprefix.longprefix rescue "" end
      {
        :id => u.id,
        :sex => render_sex(u.sex),
        :prefix => prefix,
        :fname => u.fname,
        :lname => u.lname,
        :pid => u.pid,
        :birthdate => render_date(u.birthdate),
        :tel => u.tel,
        :name => ["#{prefix}#{u.fname}", u.lname].join(" "),
        :posid => u.posid
      }
    }
    render :text => return_data.to_json,:layout => false  
  end
  
  def search_edit
    rs = Pispersonel.find(params[:id])
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  def update
    params[:pispersonel][:birthdate] = to_date_db(params[:pispersonel][:birthdate])
    if !params[:picname].nil?
      t = Time.new
      upload = UploadPicPisPersonel.save(params[:picname],params[:id]+"_#{t.to_i}")
      params[:pispersonel][:picname] = upload
    end
    if QueryPis.update_by_arg(params[:pispersonel],"pispersonel","id = '#{params[:id]}' and pstatus = '1' ")
      return_data = {}
      return_data[:success] = true            
      render :text => return_data.to_json, :layout => false
    else
      return_data = {}
      return_data[:success] = false
      return_data[:msg] = "กรุณาลองตรวจสอบข้อมูลและลองใหม่อีกครั้ง"
      render :text => return_data.to_json, :layout => false
    end
  end
  
  def search_id
    rs = Pispersonel.find(params[:id])
    prefix = (rs.pcode.to_s == "")? "" : begin rs.cprefix.longprefix rescue "" end
    return_data = {}
    return_data[:data] = [
      {
          :id => rs.id,
          :posid => rs.posid,
          :name => ["#{prefix}#{rs.fname}", rs.lname].join(" "),
          :totalabsent => rs.totalabsent,
          :vac1oct => rs.vac1oct
      }
    ]
    return_data[:success] = true
    render :text => return_data.to_json, :layout => false
  end
  
  def search_posid
    begin 
      rs = Pispersonel.find(:all,:conditions => "posid = '#{params[:posid]}' and pstatus = '1' ")[0]
      return_data = {}
      return_data[:data] = [
        {
            :id => rs.id,
            :posid => rs.posid,
            :name => rs.full_name
        }
      ]
      return_data[:success] = true
      render :text => return_data.to_json, :layout => false
    rescue
      render :text => "{success: false}"
    end
  end
  def report
    dt = Date.today
    @dt = "#{dt.day} #{month_th_short[dt.mon.to_i]} #{dt.year + 543}"
    ###################################
    
    str_join = " left join cprefix on pispersonel.pcode = cprefix.pcode "
    str_join += " left join csection on pispersonel.seccode = csection.seccode"
    str_join += " left join csubdept on pispersonel.sdcode = csubdept.sdcode "
    str_join += " left join cqualify on pispersonel.qcode = cqualify.qcode "
    str_join += " left join cmajor on pispersonel.macode = cmajor.macode "
    str_join += " left join cmarital on pispersonel.mrcode = cmarital.mrcode "
    str_join += " left join creligion on pispersonel.recode = creligion.recode"
    str_join += " left join cprovince on pispersonel.provcode = cprovince.provcode"
    str_join += " left join cgrouplevel on pispersonel.c = cgrouplevel.ccode "
    str_join += " left join cministry on pispersonel.mincode = cministry.mcode "
    str_join += " left join cdept on pispersonel.deptcode = cdept.deptcode"
    select = "pispersonel.*,cprefix.prefix"
    select += ",EXTRACT(day from AGE(NOW(), birthdate - INTERVAL '1 days')) as age_day"
    select += ",EXTRACT(month from AGE(NOW(), birthdate - INTERVAL '1 days')) as age_month"
    select += ",EXTRACT(year from AGE(NOW(), birthdate - INTERVAL '1 days')) as age_year"
    select += ",EXTRACT(day from AGE(NOW(), appointdate - INTERVAL '1 days')) as appoint_day"
    select += ",EXTRACT(month from AGE(NOW(), appointdate - INTERVAL '1 days')) as appoint_month"
    select += ",EXTRACT(year from AGE(NOW(), appointdate - INTERVAL '1 days')) as appoint_year"
    select += ",EXTRACT(day from AGE(NOW(), deptdate - INTERVAL '1 days')) as dept_day"
    select += ",EXTRACT(month from AGE(NOW(), deptdate - INTERVAL '1 days')) as dept_month"
    select += ",EXTRACT(year from AGE(NOW(), deptdate - INTERVAL '1 days')) as dept_year"
    select += ",EXTRACT(day from AGE(NOW(), cdate - INTERVAL '1 days')) as c_day"
    select += ",EXTRACT(month from AGE(NOW(), cdate - INTERVAL '1 days')) as c_month"
    select += ",EXTRACT(year from AGE(NOW(), cdate - INTERVAL '1 days')) as c_year"
    select += ",csection.shortname as secshort,csection.secname"
    select += ",csubdept.longpre as sdpre,csubdept.subdeptname,csubdept.sdcode"
    select += ",cqualify.longpre as qpre,cqualify.qualify"
    select += ",cmajor.major,cmarital.marital,creligion.renname"
    select += ",cprovince.longpre as provpre,cprovince.provname,cgrouplevel.clname"
    select += ",cministry.minname,cdept.deptname"
    @rs_personel = Pispersonel.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")[0]
    bt = @rs_personel.birthdate
    @bt = ""
    if !bt.nil?
      @bt = "#{bt.day} #{month_th_short[bt.mon.to_i]} #{bt.year + 543}"
    end
    #############
    rt = retiredate(@rs_personel.birthdate)
    @rt = ""
    if rt.to_s != ""
      @rt = "#{rt.day} #{month_th_short[rt.mon.to_i]} #{rt.year + 543}"
    end
    ############
    getindate = @rs_personel.getindate
    @getindate = ""
    if getindate.to_s != ""
      @getindate = "#{getindate.day} #{month_th_short[getindate.mon.to_i]} #{getindate.year + 543}"
    end
    ##################
    @title_sd_personel = long_title_head_subdept(@rs_personel.sdcode)
     
    #################################
    str_join = " left join cgrouplevel on pisj18.c = cgrouplevel.ccode "
    str_join += " left join cposition on pisj18.poscode = cposition.poscode "
    str_join += " left join cexecutive on pisj18.excode = cexecutive.excode "
    str_join += " left join cexpert on pisj18.epcode = cexpert.epcode"
    str_join += " left join cpostype on pisj18.ptcode = cpostype.ptcode "
    str_join += " left join csection on pisj18.seccode = csection.seccode"
    str_join += " left join csubdept on pisj18.sdcode = csubdept.sdcode "
    str_join += " left join cministry on pisj18.mincode = cministry.mcode "
    str_join += " left join cdept on pisj18.deptcode = cdept.deptcode"
    select = "pisj18.*,cgrouplevel.gname,cgrouplevel.clname,cposition.longpre as pospre,cposition.posname"
    select += ",cexecutive.shortpre as expre,cexecutive.exname"
    select += ",cexpert.prename as eppre,cexpert.expert"
    select += ",cpostype.ptname"
    select += ",csection.shortname as secshort,csection.secname"
    select += ",csubdept.longpre as sdpre,csubdept.subdeptname,csubdept.sdcode"
    select += ",cministry.minname,cdept.deptname"
    @rs_pisj18 = Pisj18.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}' and posid = #{@rs_personel.posid}")[0]
    @title_sd_j18 = long_title_head_subdept(@rs_pisj18.sdcode)
    ###################################
    str_join = " left join cposition on pisposhis.poscode = cposition.poscode "
    str_join += " left join cministry on pisposhis.mcode = cministry.mcode "
    str_join += " left join cdept on pisposhis.deptcode = cdept.deptcode "
    str_join += " left join cupdate on pisposhis.updcode = cupdate.updcode "
    str_join += " left join cgrouplevel on pisposhis.c = cgrouplevel.ccode "
    str_join += " left join cjob on pisposhis.jobcode = cjob.jobcode "
    str_join += " left join csection on pisposhis.seccode = csection.seccode "
    str_join += " left join csubdept on pisposhis.sdcode = csubdept.sdcode "
    str_join += " left join cdivision on pisposhis.dcode = cdivision.dcode"
    select = "pisposhis.*"
    select += ",cposition.longpre as pospre,cposition.posname,cupdate.updname"
    select += ",cgrouplevel.gname,cgrouplevel.clname"    
    select += ",cministry.minname"
    select += ",cdept.deptname"
    select += ",cdivision.prefix as dpre,cdivision.division"
    select += ",csubdept.shortpre as sdpre,csubdept.subdeptname,csubdept.sdcode"
    select += ",csection.shortname as secshort,csection.secname"
    select += ",cjob.jobname"
    
    @rs_poshis = Pisposhis.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}' and forcedate >= '2008-12-11'", :order => "historder")
    ###################################
    @rs_poshis_old = Pisposhis.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}' and forcedate < '2008-12-11' ", :order => "historder")
    #################################
    str_join = " left join crelation on pisfamily.relcode = crelation.relcode "
    str_join += " left join cprefix on pisfamily.pcode = cprefix.pcode "
    select = "pisfamily.*,crelation.relname,cprefix.prefix"
    @rs_family = Pisfamily.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ################################
    str_join = " left join cprefix on pischgname.pcode = cprefix.pcode "
    select = "pischgname.*,cprefix.prefix"
    @rs_pischgname = Pischgname.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ###############################
    str_join = " left join cqualify on piseducation.qcode = cqualify.qcode "
    str_join += " left join cmajor on piseducation.macode = cmajor.macode "
    str_join += " left join ccountry on piseducation.cocode = ccountry.cocode"
    select = "piseducation.*,cqualify.qualify,cqualify.longpre as quapre,cmajor.major,ccountry.coname"
    @rs_education = Piseducation.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ##############################
    str_join = " left join cdecoratype on pisinsig.dccode = cdecoratype.dccode "
    str_join += " left join cposition on pisinsig.poscode = cposition.poscode "
    select = "pisinsig.*,cposition.longpre as pospre,cposition.posname"
    select += ",cdecoratype.dcname,cposition.longpre as pospre,cposition.posname"
    @rs_pisinsig = Pisinsig.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ############################
    str_join = " left join ccountry on pistrainning.cocode = ccountry.cocode"
    select = "pistrainning.*,ccountry.coname"
    @rs_pistrainning = Pistrainning.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ###############################
    str_join = " left join cpunish on pispunish.pncode = cpunish.pncode"
    select = "pispunish.*,cpunish.pnname"
    @rs_pispunish = Pispunish.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    respond_to do |format|
      format.pdf  {
        prawnto :prawn=>{
          #:page_layout=>:landscape,
          :top_margin => 50,
          :left_margin => 5,
          :right_margin => 5
        }
      }
    end

  end
  def read_all
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
    search_other = ""
    str_join = " left join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      for i in 0...allfields.length
        case allfields[i]
          when "fname","lname","pid","birthdate","sex","tel","posid"
            allfields[i] = "pispersonel.#{allfields[i]}"
          when "prefix"
            allfields[i] = "cprefix.#{allfields[i]}"
        end
      end
      search += " and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
      search_other += " ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
    end
    user_search = []
    search_j18 = ""
    search_personel = ""
    if @current_user.group_user.type_group.to_s == "1"
      @user_work_place.each do |key,val|
        if key.to_s == "mcode"
          k = "mincode"
        else
          k = key
        end
        user_search.push("pisj18.#{k} = '#{val}'")
      end
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
    end
    if user_search.length != 0
      if search == ""
        search_j18 = user_search.join(" and ")
        search_personel = user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      else
        search_j18 += " and " + user_search.join(" and ")
        search_personel += " and " + user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      end
    end
    sql_other = "select pispersonel.* from pispersonel left join cprefix on pispersonel.pcode = cprefix.pcode where (pispersonel.posid is null or pstatus != '1') #{(search_other != "")? " and #{search_other} " : ""}"
    sql_j18 = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where (#{search} #{search_j18}) "
    sql_personel = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where (#{search} #{search_personel}) "
    sql = "(#{sql_j18}) union (#{sql_personel}) union #{sql_other}"
    sql = "#{sql_j18} union #{sql_other}"
    
    rs = Pispersonel.find_by_sql("#{sql} limit #{limit} offset #{start}")
    return_data = {}
    return_data[:totalCount] = Pispersonel.find_by_sql("select count(*) as n from (#{sql}) as pis")[0].n
    return_data[:records]   = rs.collect{|u|
      prefix = (u.pcode.to_s == "")? "" : begin u.cprefix.longprefix rescue "" end
      {
        :id => u.id,
        :sex => render_sex(u.sex),
        :prefix => prefix,
        :fname => u.fname,
        :lname => u.lname,
        :pid => u.pid,
        :birthdate => render_date(u.birthdate),
        :tel => u.tel,
        :name => ["#{prefix}#{u.fname}", u.lname].join(" "),
        :posid => u.posid
      }
    }
    render :text => return_data.to_json,:layout => false  
  end
  
  def export_pispersonel
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.pis.txt\""
    headers['Cache-Control'] = ''
    rs = Pispersonel.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pispersonel' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  def export_pistrainning
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.train.txt\""
    headers['Cache-Control'] = ''
    rs = Pistrainning.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pistrainning' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  def export_pischgname
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.chgname.txt\""
    headers['Cache-Control'] = ''
    rs = Pischgname.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pischgname' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end  

  def export_piseducation
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.edu.txt\""
    headers['Cache-Control'] = ''
    rs = Piseducation.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'piseducation' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end  
  def export_pisfamily
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.family.txt\""
    headers['Cache-Control'] = ''
    rs = Pisfamily.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pisfamily' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  def export_pisinsig
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.insig.txt\""
    headers['Cache-Control'] = ''
    rs = Pisinsig.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pisinsig' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  def export_pispicturehis
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.picture.txt\""
    headers['Cache-Control'] = ''
    rs = Pispicturehis.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pispicturehis' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  def export_pisposhis
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.poshis.txt\""
    headers['Cache-Control'] = ''
    rs = Pisposhis.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pisposhis' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end
  
  def export_pispunish
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.punish.txt\""
    headers['Cache-Control'] = ''
    rs = Pispunish.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pispunish' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end 
  def export_pisabsent
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=\"#{params[:id]}.pis.absent.txt\""
    headers['Cache-Control'] = ''
    rs = Pisabsent.where("id = '#{params[:id]}'")
    sql = "select column_name as col from information_schema.columns where table_name = 'pisabsent' order by ordinal_position;"
    col = ActiveRecord::Base.connection.execute(sql)
    data = []
    rs.each do |r|
      row = []
      col.each do |c|
        if r[c["col"]].class.to_s == "Date" or r[c["col"]].class.to_s == "DateTime"
          row.push("#{to_date_export(r[c["col"]])}")
        else
          row.push("#{r[c["col"]]}")
        end
      end
      data.push(row.join("\t"))
    end
    render :text => data.join("\r\n")
  end 
  def import_data
    begin
      str = params[:file].read
      if str.encoding.name.to_s != "UTF-8"
        str = Iconv.conv("UTF-8", "", str)
      end
      rows = str.split("\r\n")
      ######################################
      table_name = params[:table_name]
      cols = []
      sql = "select column_name as col,data_type from information_schema.columns where table_name = '#{table_name}' order by ordinal_position;"
      col_dbs = ActiveRecord::Base.connection.execute(sql)      
      for i in 0...col_dbs.ntuples do
        cols.push(col_dbs[i]["col"].to_s)
      end
      vals = []
      rows.each do |r|
        row = r.split("\t")
        val = []
        for i in 0...col_dbs.ntuples do
          if row[i].to_s == ""
            val.push("NULL")
          else
            if col_dbs[i]["data_type"].include?("timestamp") or col_dbs[i]["data_type"].include?("date")
              val.push("'#{date_import(row[i].to_s)}'")
            else
              val.push("#{to_data_db(row[i].to_s)}")
            end            
          end
        end
        vals.push("(#{val.join(",")})")
      end
      sql = "insert into #{table_name}(#{cols.join(",")}) values#{vals.join(",")};"
      ActiveRecord::Base.connection.execute(sql)
      render :text => "{success: true}"
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาด'}"    
    end
    
  end

end






