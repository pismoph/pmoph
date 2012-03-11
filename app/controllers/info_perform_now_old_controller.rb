# coding: utf-8
class InfoPerformNowOldController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def search_edit
    id = params[:id]
    str_join = " left join pisj18 on pisj18.posid = pispersonel.posid "
    rs = Pispersonel.select("pispersonel.*,pisj18.poscode as poscodej18,pispersonel.salary as salaryj18,pisj18.sdcode as sdcodej18").joins(str_join).find(id)
    rs[:now_subdept_show] = (rs.sdcode.to_s == "")? "" : begin Csubdept.find(rs.sdcode).full_name rescue "" end
    rs[:posnamej18] = (rs.poscodej18.to_s == "")? "" : begin Cposition.find(rs.poscodej18).full_name rescue "" end
    rs[:sdnamej18] = (rs.sdcodej18.to_s == "")? "" : begin Csubdept.find(rs.sdcodej18).full_name rescue "" end
    rs[:salaryj18] = rs.salaryj18
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
    params[:pispersonel][:quitdate] = to_date_db(params[:pispersonel][:quitdate])
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
