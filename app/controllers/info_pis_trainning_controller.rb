# coding: utf-8
class InfoPisTrainningController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    search = " id = '#{params[:id]}' "
    rs = Pistrainning.select("id,tno,begindate,enddate,cocode,cource,institute").find(:all, :conditions => search, :order => "tno")
    return_data = Hash.new()
    return_data[:records]   = rs.collect{|u|
      {
        :id => u.id[0],
        :tno => u.tno,
        :begindate => render_date(u.begindate),
        :enddate => render_date(u.enddate),
        :coname => (u.cocode.to_s == "")? "" : begin Ccountry.find(u.cocode).coname rescue "" end,
        :cource => u.cource,
        :institute => u.institute
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  def create
    rs_order = Pistrainning.select("max(tno) as tno").find(:all,:conditions => "id = '#{params[:pistrainning][:id]}'")
    params[:pistrainning][:tno] = rs_order[0].tno.to_i + 1
    params[:pistrainning][:begindate] = to_date_db(params[:pistrainning][:begindate])
    params[:pistrainning][:enddate] = to_date_db(params[:pistrainning][:enddate])
    if QueryPis.insert_by_arg(params[:pistrainning],"pistrainning")
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
    rs = Pistrainning.find(params[:id].to_s,params[:tno].to_i)
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pistrainning][:begindate] = to_date_db(params[:pistrainning][:begindate])
    params[:pistrainning][:enddate] = to_date_db(params[:pistrainning][:enddate])
    rs = Pistrainning.find(params[:id].to_s,params[:tno].to_i)
    if rs.update_attributes(params[:pistrainning])
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
    if Pistrainning.delete_all("id = '#{params[:id]}' and tno = #{params[:tno]}")
      render :text => "{success:true}"
    else
      render :text => "{success:false}"
    end    
  end
  

end
