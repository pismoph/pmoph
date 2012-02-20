# coding: utf-8
class InfoPisposhisController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = " id = '#{params[:id]}' "
    rs = Pisposhis.select("id,historder,forcedate,posid,salary,poscode,updcode,c,refcmnd").find(:all, :conditions => search, :limit => limit, :offset => start, :order => "historder")
    return_data = Hash.new()
    return_data[:totalCount] = Pisposhis.count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      {
        :id => u.id[0],
        :historder => u.historder,
        :forcedate => render_date(u.forcedate),
        :posid => u.posid,
        :salary => u.salary,
        :posname => (u.poscode.to_s == "")? "" : begin Cposition.find(u.poscode).full_name rescue "" end,
        :cname => (u.c.to_s == "" or u.c.to_i == 0)? "" : begin Cgrouplevel.find(u.c).cname rescue "" end,
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
