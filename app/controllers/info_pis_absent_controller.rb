# coding: utf-8
class InfoPisAbsentController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def genre_year_fiscal
    rs = Pisabsent.where("id = '#{params[:id]}' ").minimum("begindate")
    dt_max = Time.new
    dt_min = rs||dt_max
    dt_min = dt_min.year.to_s+"-"+dt_min.month.to_s+"-"+dt_min.day.to_s    
    dt_max = dt_max.year.to_s+"-"+dt_max.month.to_s+"-"+dt_max.day.to_s
    fiscal_min = year_fiscal_i(dt_min) - 10
    fiscal_max = year_fiscal_i(dt_max) + 10
    str = Array.new
    j = 0
    for i in fiscal_min..fiscal_max
      str[j] = "{year_en:#{i},year_th:#{i+543}}"
      j += 1 
    end    
    render :text => "{records:[#{str.join(",")}]}"
  end

  def read
    limit = params[:limit]
    start = params[:start]
    i = start.to_i
    search = " id = '#{params[:id]}' and begindate between '#{params[:year].to_i - 1}-10-01' and '#{params[:year]}-09-30'"
    rs = Pisabsent.find(:all, :conditions => search, :limit => limit, :offset => start, :order => "id, abcode, begindate")
    return_data = Hash.new()
    return_data[:totalCount] = Pisabsent.count(:all , :conditions => search)
    return_data[:records]   = rs.collect{|u|
      i += 1
      {
        :id => u.id[0],
        :idp => i,
        :abcode =>  u.abcode,
        :abtype => (u.abcode.to_s == "")? "" : begin Cabsenttype.find(u.abcode).abtype rescue "" end ,
        :begindate => render_date(u.begindate),
        :enddate => render_date(u.enddate),
        :amount => u.amount,
        :flagcount => render_flagcount(u.flagcount)
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  
  def create
    params[:pisabsent][:begindate] = to_date_db(params[:pisabsent][:begindate])
    params[:pisabsent][:enddate] = to_date_db(params[:pisabsent][:enddate])
    if QueryPis.insert_by_arg(params[:pisabsent],"pisabsent")
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
    rs = Pisabsent.find(params[:id].to_s,params[:abcode],to_date_db(params[:begindate]))
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    params[:pisabsent][:begindate] = to_date_db(params[:pisabsent][:begindate])
    params[:pisabsent][:enddate] = to_date_db(params[:pisabsent][:enddate])
    if QueryPis.update_by_arg(params[:pisabsent],"pisabsent","id = '#{params[:id]}' and abcode = #{params[:abcode]} and begindate = '#{to_date_db(params[:begindate])}'")
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
    if Pisabsent.delete_all("id = '#{params[:id]}' and abcode = '#{params[:abcode]}' and begindate = '#{to_date_db(params[:begindate])}'")
      render :text => "{success:true}"
    else
      render :text => "{success:false}"
    end    
  end
  
  
  def summary
    rs = Pisabsent.select("distinct abcode").where("id = '#{params[:id]}' and begindate between '#{params[:year].to_i - 1}-10-01' and '#{params[:year]}-09-30' ")
    i = 0
    return_data = {}
    return_data[:records]   = []
    rs.each do |r|
      i += 1
      return_data[:records].push({
        :id => i,
        :abtype => (r.abcode.to_s == "")? "" : begin Cabsenttype.find(r.abcode).abtype rescue "" end ,
        :amount => begin Pisabsent.sum("amount",:conditions => "id = '#{params[:id]}' and abcode = '#{r.abcode}' and begindate between '#{params[:year].to_i - 1}-10-01' and '#{params[:year]}-09-30'").to_f rescue "" end ,
        :flagcount => begin Pisabsent.count("flagcount",:conditions => "id = '#{params[:id]}' and abcode = '#{r.abcode}' and begindate between '#{params[:year].to_i - 1}-10-01' and '#{params[:year]}-09-30' and flagcount = '1' ").to_i rescue "" end ,
      })
    end
    
    render :text => return_data.to_json, :layout => false 
    
  end
end