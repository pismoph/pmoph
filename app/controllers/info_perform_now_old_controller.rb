# coding: utf-8
class InfoPerformNowOldController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def search_edit
    id = params[:id]
    str_join = " left join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " left join cgrouplevel on cgrouplevel.ccode = pisj18.c "
    str_join += " left join cpostype on cpostype.ptcode = pisj18.ptcode "
    str_join += " left join cexpert on cexpert.epcode = pisj18.epcode "
    
    select = "pispersonel.*,pisj18.poscode as poscodej18,pisj18.salary as salaryj18,pisj18.sdcode as sdcodej18,cgrouplevel.clname,cgrouplevel.cname,cpostype.ptname,cexpert.expert,cexpert.prename"
    select += ",pisj18.seccode as seccodej18,pisj18.jobcode as jobcodej18"
    rs = Pispersonel.select(select).joins(str_join).find(id)
    rs[:now_subdept_show] = (rs.sdcode.to_s == "")? "" : begin Csubdept.find(rs.sdcode).full_name rescue "" end
    rs[:posnamej18] = (rs.poscodej18.to_s == "")? "" : begin "#{Cposition.find(rs.poscodej18).full_name} #{rs.cname} #{"(#{rs.prename}#{rs.expert})" if rs.expert.to_s != ""}" rescue "" end
    
    sdnamej18 = begin Csubdept.find(rs.sdcodej18).full_name rescue "" end
    sdnamej18 += begin " #{Csection.find(rs.seccodej18).full_name}" rescue "" end
    sdnamej18 += begin " #{Cjob.find(rs.jobcodej18).jobname}" rescue "" end
    
    rs[:sdnamej18] = sdnamej18 
    rs[:salaryj18] = rs.salaryj18
    
    
    str_join = " left join cgrouplevel on cgrouplevel.ccode = pispersonel.c "
    str_join += " left join cpostype on cpostype.ptcode = pispersonel.ptcode "
    str_join += " left join cposition on cposition.poscode = pispersonel.poscode "
    str_join += " left join cexpert on cexpert.epcode = pispersonel.epcode "

    rs_tmp = Pispersonel.select("cgrouplevel.cname,cgrouplevel.clname,cpostype.ptname,cposition.longpre,cposition.posname,pispersonel.salary,cexpert.expert,cexpert.prename").joins(str_join).find(id)
    rs[:posnamenow] = "#{rs_tmp.longpre}#{rs_tmp.posname} #{rs_tmp.cname} #{"(#{rs_tmp.prename}#{rs_tmp.expert})" if rs_tmp.expert.to_s != ""}"
    rs[:salarynow] = rs_tmp.salary.to_i
    
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pispersonel][:birthdate] = to_date_db(params[:pispersonel][:birthdate])
    params[:pispersonel][:retiredate] = to_date_db(params[:pispersonel][:retiredate])
    params[:pispersonel][:appointdate] = to_date_db(params[:pispersonel][:appointdate])
    params[:pispersonel][:deptdate] = to_date_db(params[:pispersonel][:deptdate])
    params[:pispersonel][:attenddate] = to_date_db(params[:pispersonel][:attenddate])
    params[:pispersonel][:cdate] = to_date_db(params[:pispersonel][:cdate])
    params[:pispersonel][:getindate] = to_date_db(params[:pispersonel][:getindate])
    params[:pispersonel][:reentrydate] = to_date_db(params[:pispersonel][:reentrydate])
    params[:pispersonel][:exitdate] = to_date_db(params[:pispersonel][:exitdate])
    params[:pispersonel][:kbk] = params[:kbk]
    rs = Pispersonel.find(params[:id])
    if rs.update_attributes(params[:pispersonel])
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
end
