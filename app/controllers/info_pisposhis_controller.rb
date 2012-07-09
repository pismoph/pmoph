# coding: utf-8
class InfoPisposhisController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = " id = '#{params[:id]}' "
    
    
    str_join = " left join cministry on pisposhis.mcode = cministry.mcode "
    str_join += " left join cdept on pisposhis.deptcode = cdept.deptcode "
    str_join += " left join cjob on pisposhis.jobcode = cjob.jobcode "
    str_join += " left join csection on pisposhis.seccode = csection.seccode "
    str_join += " left join csubdept on pisposhis.sdcode = csubdept.sdcode "
    str_join += " left join cdivision on pisposhis.dcode = cdivision.dcode"
    str_join += " left join cposition on pisposhis.poscode = cposition.poscode "
    str_join += " left join cexpert on pisposhis.epcode = cexpert.epcode "
    str_join += " left join cgrouplevel on pisposhis.c = cgrouplevel.ccode "
    
    select = "pisposhis.id,pisposhis.historder,pisposhis.forcedate,pisposhis.posid"
    select += ",pisposhis.salary,pisposhis.poscode,pisposhis.updcode,pisposhis.c,pisposhis.refcmnd"
    select += ",cministry.minname"
    select += ",cdept.deptname"
    select += ",cdivision.prefix as dpre,cdivision.division"
    select += ",csubdept.shortpre as sdpre,csubdept.subdeptname,csubdept.sdcode"
    select += ",csection.shortname as secshort,csection.secname"
    select += ",cjob.jobname,cposition.longpre as pospre,cposition.posname,pisposhis.addsal"
    select += ",cexpert.expert,cexpert.prename,cgrouplevel.cname"
    
    rs = Pisposhis.select(select).joins(str_join).find(:all, :conditions => search, :limit => limit, :offset => start, :order => "historder")
    return_data = Hash.new()
    return_data[:totalCount] = Pisposhis.count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      posname = "#{[u.pospre,u.posname].join("")}"
      posname += "<br />#{u.cname}" if u.cname.to_s != ""
      posname += "(#{[u.prename,u.expert].join("")})" if u.expert.to_s != ""
      posname += "<br />#{u.jobname}" if u.jobname.to_s != ""
      posname += "<br />#{[u.secshort,u.secname].join("")}" if u.secname.to_s != ""
      
      posname += "<br />#{[u.sdpre,u.subdeptname].join("")}" if u.subdeptname.to_s != ""
      
      posname += "<br />#{[u.dpre,u.division].join("")}" if u.division.to_s != ""
      
      posname += "<br />#{u.deptname}" if u.deptname.to_s != ""
      
      posname += "<br />#{u.minname}" if u.minname.to_s != ""
      {
        :id => u.id[0],
        :historder => u.historder,
        :forcedate => render_date(u.forcedate),
        :posid => u.posid,
        :salary => u.salary,
        :posname => posname,
        :cname => "",
        :refcmnd => u.refcmnd,
        :updname => (u.updcode.to_s == "")? "" : begin Cupdate.find(u.updcode).updname rescue "" end
      }
    }
    render :text => return_data.to_json, :layout => false   
  end
  
  def create
    rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:id]}'")
    params[:pisposhis][:id] = params[:id]
    params[:pisposhis][:historder] = rs_order[0].historder.to_i + 1
    params[:pisposhis][:forcedate] = to_date_db(params[:pisposhis][:forcedate])
    if QueryPis.insert_by_arg(params[:pisposhis],"pisposhis")
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
  def search_edit
    rs = Pisposhis.find(params[:id].to_s,params[:historder].to_i)
    rs[:his_subdept_show] = (rs.sdcode.to_s == "")? "" : begin Csubdept.find(rs.sdcode).full_name rescue "" end
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  def edit
    params[:pisposhis][:forcedate] = to_date_db(params[:pisposhis][:forcedate])
    rs = Pisposhis.find(params[:id].to_s,params[:historder].to_i)
    if rs.update_attributes(params[:pisposhis])
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
  def delete
    if Pisposhis.delete_all("id = '#{params[:id]}' and historder = #{params[:historder]}")
            render :text => "{success:true}"
    else
            render :text => "{success:false}"
    end    
  end
  
end
