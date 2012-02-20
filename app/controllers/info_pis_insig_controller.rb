# coding: utf-8
class InfoPisInsigController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    i = start.to_i
    search = " id = '#{params[:id]}' "
    rs = Pisinsig.select("id,dccode,dcyear,poscode,c,excode,ptcode,epcode").find(:all, :conditions => search, :limit => limit, :offset => start, :order => "id,dccode,dcyear")
    return_data = Hash.new()
    return_data[:totalCount] = Pisinsig.count(:all , :conditions => search)
    return_data[:records]   = rs.collect{|u|
      i += 1
      {
        :id => u.id[0],
        :idp => i,
        :dccode => u.dccode,
        :dcname => (u.dccode.to_s == "")? "" : begin Cdecoratype.find(u.dccode).dcname rescue "" end,
        :dcyear => u.dcyear,
        :posname => (u.poscode.to_s == "")? "" : begin Cposition.find(u.poscode).full_name rescue "" end,
        :cname => (u.c.to_s == "" or u.c.to_i == 0)? "" : begin Cgrouplevel.find(u.c).cname rescue "" end,
        :exname => (u.excode.to_s == "")? "" : begin Cexecutive.find(u.excode).full_name rescue "" end,
        :ptname  => (u.ptcode.to_s == "")? "" : begin Cpostype.find(u.ptcode).ptname rescue "" end, 
        :expert  => (u.epcode.to_s == "")? "" : begin Cexpert.find(u.epcode).full_name rescue "" end
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  def create
    params[:pisinsig][:kitjadate] = to_date_db(params[:pisinsig][:kitjadate])
    params[:pisinsig][:recdate] = to_date_db(params[:pisinsig][:recdate])
    params[:pisinsig][:retdate] = to_date_db(params[:pisinsig][:retdate])
    params[:pisinsig][:billdate] = to_date_db(params[:pisinsig][:billdate])
    if QueryPis.insert_by_arg(params[:pisinsig],"pisinsig")
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
    rs = Pisinsig.find(params[:id].to_s,params[:dccode].to_i,params[:dcyear].to_i)
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pisinsig][:kitjadate] = to_date_db(params[:pisinsig][:kitjadate])
    params[:pisinsig][:recdate] = to_date_db(params[:pisinsig][:recdate])
    params[:pisinsig][:retdate] = to_date_db(params[:pisinsig][:retdate])
    params[:pisinsig][:billdate] = to_date_db(params[:pisinsig][:billdate])
    if QueryPis.update_by_arg(params[:pisinsig],"pisinsig","id = '#{params[:id]}' and dccode = #{params[:dccode]} and dcyear = #{params[:dcyear]}")
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
    if Pisinsig.delete_all("id = '#{params[:id]}' and dccode = #{params[:dccode]} and dcyear = #{params[:dcyear]}")
            render :text => "{success:true}"
    else
            render :text => "{success:false}"
    end    
  end
end
