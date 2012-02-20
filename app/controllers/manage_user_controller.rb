# coding: utf-8
class ManageUserController < ApplicationController
  before_filter :login_menu_manage_user
  skip_before_filter :verify_authenticity_token
  layout "extjs_layout"
  def read
    limit = params[:limit].to_i
    start = params[:start].to_i
    guser = @current_user.group_user
    where = []
    where.push("mcode::varchar = '#{guser.mcode}'") if guser.mcode.to_s != ""
    where.push("deptcode::varchar = '#{guser.deptcode}'") if guser.deptcode.to_s != ""
    where.push("dcode::varchar = '#{guser.dcode}'") if guser.dcode.to_s != ""
    where.push("sdcode::varchar = '#{guser.sdcode}'") if guser.sdcode.to_s != ""
    where.push("seccode::varchar = '#{guser.seccode}'") if guser.seccode.to_s != ""
    where.push("jobcode::varchar  = '#{guser.jobcode}'") if guser.jobcode.to_s != ""
    where = where.join(" and ")
    rs = GroupUser.where(where).order("id").paginate:per_page => limit,:page => ((start / limit) + 1)
    return_data={}
    return_data[:totalCount] = GroupUser.where(where).count
    return_data[:records] = rs.collect{|v|
      work_place = []
      if v.mcode.to_s != ""
        begin
          work_place.push(Cministry.find(v.mcode).minname)
        end
      end
      
      if v.deptcode.to_s != ""
        begin
          work_place.push(Cdept.find(v.deptcode).deptname)
        end
      end
      
      if v.dcode.to_s != ""
        begin
          work_place.push(Cdivision.find(v.dcode).division)
        end
      end
      
      if v.sdcode.to_s != ""
        begin
          work_place.push(Csubdept.find(v.sdcode).full_name)
        end
      end
      
      if v.seccode.to_s != ""
        begin
          work_place.push(Csection.find(v.seccode).secname)
        end
      end
      
      if v.jobcode.to_s != ""
        begin
          work_place.push(Cjob.find(v.jobcode).jobname)
        end
      end
      {
        :id => v.id,
        :name => v.name,
        :menu_code => v.menu_code,
        :menu_manage_user => v.menu_manage_user,
        :menu_personal_info => v.menu_personal_info,
        :menu_report => v.menu_report,
        :menu_command => v.menu_command,
        :menu_search => v.menu_search,
        :admin => v.admin,
        :mcode => v.mcode,
        :deptcode => v.deptcode,
        :dcode => v.dcode,
        :sdcode => v.sdcode,
        :seccode => v.seccode,
        :jobcode => v.jobcode,
        :user_subdept_show => (v.sdcode.to_s == "")? "" : begin Csubdept.find(v.sdcode).full_name rescue "" end,
        :work_place_name => work_place.join("<br />")
      }  
    }
    render :text => return_data.to_json,:layout => false
  end

  def create
    rs = GroupUser.new(params[:group_user])
    if rs.save
      return_data = Hash.new()
      return_data[:success] = true            
      render :text => return_data.to_json, :layout => false
    else   
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "กรุณาลองตรวจสอบข้อมูลและลองใหม่อีกครั้ง"
      render :text => return_data.to_json, :layout => false
    end
  end
  
  def edit    
    rs = GroupUser.find(params[:id])
    if rs.update_attributes(params[:group_user])
    return_data = Hash.new()
      return_data[:success] = true            
      render :text => return_data.to_json, :layout => false
    else   
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "กรุณาลองตรวจสอบข้อมูลและลองใหม่อีกครั้ง"
      render :text => return_data.to_json, :layout => false
    end
  end
  
  ################################################################3
  
  def read_user
    limit = params[:limit].to_i
    start = params[:start].to_i
    rs = User.where(:group_user_id => params[:group_user_id]).order("id").paginate:per_page => limit,:page => ((start / limit) + 1)
    return_data={}
    return_data[:totalCount] =User.where(:group_user_id => params[:group_user_id]).count
    return_data[:records] = rs.collect{|v|{
      :id => v.id,
      :username => v.username,
      :email => v.email,
      :fname => v.fname,
      :lname => v.lname,
      :group_user_id => v.group_user_id
    }}
    render :text => return_data.to_json,:layout => false
  end  
  
  def create_user
    rs= User.new(params[:user])
    if rs.save
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
  
  def edit_user
    rs = User.find(params[:id])
    if rs.update_attributes(params[:user])
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
