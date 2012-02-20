# coding: utf-8
class InfoEducationController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    search = " id = '#{params[:id]}' "
    rs = Piseducation.select("id,eorder,ecode,enddate,flag,maxed,qcode,institute,cocode").find(:all, :conditions => search, :order => "eorder")
    return_data = Hash.new()
    return_data[:records]   = rs.collect{|u|
      {
        :id => u.id,
        :eorder => u.eorder,
        :edulevel => (u.ecode.to_s == "")? "" : begin Cedulevel.find(u.ecode).edulevel rescue "" end,
        :enddate => render_date(u.enddate),
        :flag => render_flag_education(u.flag),
        :maxed => render_maxed_education(u.maxed),
        :qualify => (u.qcode.to_s == "")? "" : begin Cqualify.find(u.qcode).qualify rescue "" end,
        :institute => u.institute,
        :coname => (u.cocode.to_s == "")? "" : begin Ccountry.find(u.cocode).coname rescue "" end
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  def create    
    rs_order = Piseducation.select("max(eorder) as eorder").find(:all,:conditions => "id = '#{params[:id]}'")
    params[:piseducation][:enddate] = to_date_db(params[:piseducation][:enddate])
    params[:piseducation][:id] = params[:id]
    params[:piseducation][:eorder] = rs_order[0].eorder.to_i + 1
    params[:piseducation][:status] = params[:status]
    begin
      Piseducation.transaction do
        rs_edu = Piseducation.new(params[:piseducation])
        rs_edu.save!
        if params[:piseducation][:flag].to_s == "1"
          rs_personel = Pispersonel.find(params[:id])
          rs_personel.macode = params[:piseducation][:macode]
          rs_personel.qcode = params[:piseducation][:qcode]
          rs_personel.save!
        end
      end
      return_data = Hash.new()
      return_data[:success] = true            
      render :text => return_data.to_json, :layout => false
    
    rescue
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "กรุณาลองตรวจสอบข้อมูลและลองใหม่อีกครั้ง"
      render :text => return_data.to_json, :layout => false      
    end
  end
  
  def search_edit
    rs = Piseducation.find(:all,:conditions=> "id = '#{params[:id]}' and eorder = #{params[:eorder]}")[0]
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false    
  end
  
  def edit
    params[:piseducation][:enddate] = to_date_db(params[:piseducation][:enddate])
    params[:piseducation][:status] = params[:status]
    begin
      Piseducation.transaction do
        Piseducation.update_all(params[:piseducation],"id = '#{params[:id]}' and eorder = #{params[:eorder]}")
        if params[:piseducation][:flag].to_s == "1"
          rs_personel = Pispersonel.find(params[:id])
          rs_personel.macode = params[:piseducation][:macode]
          rs_personel.qcode = params[:piseducation][:qcode]
          rs_personel.save!
        end
      end
      return_data = Hash.new()
      return_data[:success] = true            
      render :text => return_data.to_json, :layout => false
    
    rescue
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "กรุณาลองตรวจสอบข้อมูลและลองใหม่อีกครั้ง"
      render :text => return_data.to_json, :layout => false      
    end
  end
  
  def delete
    if Piseducation.delete_all("id = '#{params[:id]}' and eorder = #{params[:eorder]}")
      render :text => "{success:true}"
    else
      render :text => "{success:false}"
    end    
  end
  

end
