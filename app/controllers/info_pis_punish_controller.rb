# coding: utf-8
class InfoPisPunishController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    i = start.to_i
    search = " id = '#{params[:id]}' "
    rs = Pispunish.find(:all, :conditions => search, :limit => limit, :offset => start, :order => "id,forcedate")
    return_data = Hash.new()
    return_data[:totalCount] = Pispunish.count(:all , :conditions => search)
    return_data[:records]   = rs.collect{|u|
      i += 1
      {
        :id => u.id[0],
        :idp => i,
        :forcedate => render_date(u.forcedate),
        :pnname => (u.pncode.to_s == "")? "" : begin Cpunish.find(u.pncode).pnname rescue "" end,
        :cmdno => u.cmdno
      }
    }
    render :text => return_data.to_json, :layout => false 
  end

  def create
    params[:pispunish][:forcedate] = to_date_db(params[:pispunish][:forcedate])
    if QueryPis.insert_by_arg(params[:pispunish],"pispunish")
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
    rs = Pispunish.find(params[:id].to_s,to_date_db(params[:forcedate]))
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pispunish][:forcedate] = to_date_db(params[:pispunish][:forcedate])
    if QueryPis.update_by_arg(params[:pispunish],"pispunish","id = '#{params[:id]}' and forcedate = '#{params[:forcedate]}'")
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
    if Pispunish.delete_all("id = '#{params[:id]}' and forcedate = '#{to_date_db(params[:forcedate])}'")
      render :text => "{success:true}"
    else
      render :text => "{success:false}"
    end    
  end
  
end
