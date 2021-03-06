# coding: utf-8
class InfoPersonalOldController < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = " pispersonel.pstatus = '0' "
    str_join = " left join cprefix on pispersonel.pcode = cprefix.pcode "
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      for i in 0...allfields.length
        case allfields[i]
          when "fname","lname","pid","birthdate","sex","tel","posid"
            allfields[i] = "pispersonel.#{allfields[i]}"
          when "prefix"
            allfields[i] = "cprefix.#{allfields[i]}"
        end
      end
      search += " and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
    end
    rs = Pispersonel.joins(str_join).find(:all, :conditions => search, :limit => limit, :offset => start, :order => "pispersonel.id")
    return_data = {}
    return_data[:totalCount] = Pispersonel.joins(str_join).count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      prefix = (u.pcode.to_s == "")? "" : begin u.cprefix.longprefix rescue "" end
      {
        :id => u.id,
        :sex => render_sex(u.sex),
        :prefix => prefix,
        :fname => u.fname,
        :lname => u.lname,
        :pid => u.pid,
        :birthdate => render_date(u.birthdate),
        :tel => u.tel,
        :name => ["#{prefix}#{u.fname}", u.lname].join(" "),
        :posid => u.posid
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def search_edit
    rs = Pispersonel.find(params[:id])
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  def update
    params[:pispersonel][:birthdate] = to_date_db(params[:pispersonel][:birthdate])
    if !params[:picname].nil?
      t = Time.new
      upload = UploadPicPisPersonel.save(params[:picname],params[:id]+"_#{t.to_i}")
      params[:pispersonel][:picname] = upload
    end
    if QueryPis.update_by_arg(params[:pispersonel],"pispersonel","id = '#{params[:id]}' and pstatus = '0' ")
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
  
  def search_id
    rs = Pispersonel.find(params[:id])
    prefix = (rs.pcode.to_s == "")? "" : begin rs.cprefix.longprefix rescue "" end
    return_data = {}
    return_data[:data] = [
      {
          :id => rs.id,
          :posid => rs.posid,
          :name => ["#{prefix}#{rs.fname}", rs.lname].join(" "),
          :totalabsent => rs.totalabsent,
          :vac1oct => rs.vac1oct
      }
    ]
    return_data[:success] = true
    render :text => return_data.to_json, :layout => false
  end
  
  def search_posid
    begin 
      rs = Pispersonel.find(:all,:conditions => "posid = '#{params[:posid]}' and pstatus = '0' ")[0]
      return_data = {}
      return_data[:data] = [
        {
            :id => rs.id,
            :posid => rs.posid,
            :name => rs.full_name
        }
      ]
      return_data[:success] = true
      render :text => return_data.to_json, :layout => false
    rescue
      render :text => "{success: false}"
    end
  end
  
  def search_pid
    begin
      search = " pispersonel.pstatus = '0' "
      str_join = " left join cprefix on pispersonel.pcode = cprefix.pcode "
      if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
        allfields = ActiveSupport::JSON.decode(params[:fields])
        for i in 0...allfields.length
          case allfields[i]
            when "fname","lname","pid","birthdate","sex","tel","posid"
              allfields[i] = "pispersonel.#{allfields[i]}"
            when "prefix"
              allfields[i] = "cprefix.#{allfields[i]}"
          end
        end
        search += " and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
      end
      sql_id = "select pispersonel.id from pispersonel #{str_join} where #{search}"
      rs = Pispersonel.find(:all,:conditions => "(pid = '#{params[:pid]}' and pstatus = '0') and pispersonel.id in (#{sql_id}) ")[0]
      return_data = {}
      return_data[:data] = [{
            :id => rs.id,
            :pid => rs.pid
      }]
      return_data[:success] = true
      render :text => return_data.to_json, :layout => false
    rescue
      render :text => "{success: false}"
    end
  end    
end
