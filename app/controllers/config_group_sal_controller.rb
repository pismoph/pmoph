# coding: utf-8
class ConfigGroupSalController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token 
  def get_config
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search = " year = #{year} "
      @user_work_place.each do |key,val|
        if key.to_s == "sdcode"
          search += " and #{key} = '#{val}' " 
        end
      end
      rs = TKs24usemain.find(:all,:conditions => search).first
      return_data = {}
      return_data[:totalCount] = TKs24usemain.count(:all,:conditions => search)
      return_data[:data]   = {
        :salary => rs.salary,
        :calpercent => rs.calpercent,
        :ks24 => rs.ks24
      }
      return_data[:success] = true
      render :text => return_data.to_json,:layout => false
    rescue
      render :text => "{success: false}"  
    end
  end
  
  def create
    begin
      year = params[:fiscal_year].to_s + params[:round]
      rs = TKs24usesub.new(params[:field])
      rs.officecode = @user_work_place[:sdcode]
      rs.year = year
      if params[:field][:sdcode].to_s == ""
        rs.sdcode = @user_work_place[:sdcode]
      end
      rs.save
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
  
  def read
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} and officecode = '#{@user_work_place[:sdcode]}'"
    rs = TKs24usesub.find(:all, :conditions => search, :order => "id")
    return_data = {}
    return_data[:totalCount] =  TKs24usesub.find(:all, :conditions => search)
    return_data[:records]   = rs.collect{|u| {
        :usename => u.usename,
        :sdcode => begin Csubdept.find(u.sdcode).full_name rescue "" end,
        :etype => "#{render_etype  u.etype}",
        :salary => u.salary,
        :calpercent => u.calpercent,
        :ks24 => u.ks24,
        :pay => u.pay,
        :diff => (u.pay.to_s == "")? "" : (u.ks24.to_f - u.pay.to_f).to_s,
        :admin_id => begin Pispersonel.find(u.admin_id).full_name rescue "" end,
        :eval_id => begin Pispersonel.find(u.eval_id).full_name rescue "" end,
        :year => u.year,
        :id => u.id
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def search_edit
    begin
      year = params[:year]
      id = params[:id]
      rs = TKs24usesub.find(:all ,:conditions => "year = #{year} and id = #{id}")[0]
      return_data = {}
      return_data[:success] = true
      return_data[:data] = {
        :usename => rs.usename,
        :salary => rs.salary,
        :calpercent => rs.calpercent,
        :ks24 => rs.ks24,
        :admin_id => rs.admin_id,
        :admin_show => begin Pispersonel.find(rs.admin_id).full_name rescue "" end,
        :admin_posid => begin Pispersonel.find(rs.admin_id).posid rescue "" end,
        :eval_id => rs.eval_id,
        :eval_show => begin Pispersonel.find(rs.eval_id).full_name rescue "" end,
        :eval_posid => begin Pispersonel.find(rs.eval_id).posid rescue "" end,
        :etype => rs.etype,
        :sdcode => rs.sdcode,
        :sdcode_show => begin Csubdept.find(rs.sdcode).full_name rescue "" end,
        :seccode => rs.seccode,
        :jobcode => rs.jobcode
      }
      render :text => return_data.to_json,:layout => false
    rescue
      render :text => "{success: true}"
    end
  end
  def update
    year = params[:year]
    id = params[:id]
    rs = TKs24usesub.find(:all ,:conditions => "year = #{year} and id = #{id}")[0]
    if rs.update_attributes(params[:field])
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
