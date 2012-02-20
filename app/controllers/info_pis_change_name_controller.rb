# coding: utf-8
class InfoPisChangeNameController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    rs = Pischgname.find(:all,:conditions => "id = '#{params[:id]}'", :order => "chgno")
    return_data = {}
    return_data[:totalCount] = Pischgname.count(:conditions => "id = '#{params[:id]}'")
    return_data[:records]   = rs.collect{|u|
      {
        :chgno => u.chgno,
        :id => u.id[0],
        :chgdate => render_date(u.chgdate),
        :prefix => (u.pcode.to_s == "")? "" : begin Cprefix.find(u.pcode).prefix rescue "" end,
        :fname => u.fname,
        :lname => u.lname,
        :ref => u.ref,
        :chgname => (u.chgcode.to_s == "" or u.chgcode.to_i == 0)? "" : begin Cchangename.find(u.chgcode).chgname rescue "" end
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def add
    params[:pischgname][:chgdate] = to_date_db(params[:pischgname][:chgdate])
    chgno = Pischgname.select("max(chgno) as n").where("id='#{params[:pischgname][:id]}'")
    params[:pischgname][:chgno] = chgno[0].n.to_i+1
    if QueryPis.insert_by_arg(params[:pischgname],"pischgname")
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
    rs = Pischgname.find(params[:id],params[:chgno].to_i)
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pischgname][:chgdate] = to_date_db(params[:pischgname][:chgdate])
    rs = Pischgname.find(params[:pischgname][:id],params[:pischgname][:chgno].to_i)
    if rs.update_attributes(params[:pischgname])
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
    if Pischgname.delete_all("id = '#{params[:id]}' and chgno = #{params[:chgno]}")
            render :text => "{success:true}"
    else
            render :text => "{success:false}"
    end    
  end
end
