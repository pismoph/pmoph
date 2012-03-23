# coding: utf-8
class InfoPersonalController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
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
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      user_search.push("pisj18.#{k} = '#{val}'")
    end    
    if user_search.length != 0
      if search == ""
        search = user_search.join(" and ")
      else
        search += " and " + user_search.join(" and ")
      end
    end
    rs = Pispersonel.joins(str_join).find(:all, :conditions => search, :limit => limit, :offset => start, :order => "pispersonel.id")
    return_data = {}
    return_data[:totalCount] = Pispersonel.joins(str_join).count(:all ,:conditions => search)
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
    select += ",cprovince.longpre as provpre,cprovince.provname"
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
    select = "pisj18.*,cgrouplevel.gname,cgrouplevel.clname,cposition.longpre as pospre,cposition.posname"
    select += ",cexecutive.shortpre as expre,cexecutive.exname"
    select += ",cexpert.prename as eppre,cexpert.expert"
    select += ",cpostype.ptname"
    select += ",csection.shortname as secshort,csection.secname"
    select += ",csubdept.longpre as sdpre,csubdept.subdeptname,csubdept.sdcode"
    @rs_pisj18 = Pisj18.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}' and posid = #{@rs_personel.posid}")[0]
    @title_sd_j18 = long_title_head_subdept(@rs_pisj18.sdcode)
    ###################################
    @rs_poshis = Pisposhis.find(:all,:conditions => "id = '#{params[:id]}'", :order => "historder")
    #################################
    str_join = " left join crelation on pisfamily.relcode = crelation.relcode "
    str_join += " left join cprefix on pisfamily.pcode = cprefix.pcode "
    select = "pisfamily.*,crelation.relname,cprefix.prefix"
    @rs_family = Pisfamily.select(select).joins(str_join).find(:all,:conditions => "id = '#{params[:id]}'")
    ################################
    respond_to do |format|
      format.pdf  {
        prawnto :prawn=>{
          #:page_layout=>:landscape,
          :top_margin => 15,
          :left_margin => 5,
          :right_margin => 5
        }
      }
    end

  end
end
