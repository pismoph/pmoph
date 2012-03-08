# coding: utf-8
class InfoPisJ18Controller < ApplicationController
  before_filter :login_menu_personal_info
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' "
    @user_work_place.each do |key,val|
      if key.to_s == "mcode"
        k = "mincode"
      else
        k = key
      end
      search += " and pisj18.#{k} = '#{val}'"
    end
    str_join = ""
    if params[:status].to_s != ""
      if params[:status].to_s == '0' #ว่าง
        search += " and (length(trim(pisj18.id))  = 0 or pisj18.id is null) "
      end
      if params[:status].to_s == '1' #มีคนครองตำแหน่ง
        str_join += " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
        search += " and pispersonel.pstatus = '1' "
      end
    end    
    str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
    str_join += " LEFT JOIN cdept ON cdept.deptcode = pisj18.deptcode "
    str_join += " LEFT JOIN cposition ON cposition.poscode = pisj18.poscode "
    str_join += " LEFT JOIN cgrouplevel ON cgrouplevel.ccode = pisj18.c "
    if params[:provcode].to_s != ""
      search += " and csubdept.provcode = '#{params[:provcode]}' "
    end
    if params[:amcode].to_s != ""
      search += " and csubdept.amcode = '#{params[:amcode]}' "
    end
    if params[:tmcode].to_s != ""
      search += " and csubdept.tmcode = '#{params[:tmcode]}' "
    end
    if params[:sdtcode].to_s != ""
      search += " and csubdept.sdtcode = '#{params[:sdtcode]}' "
    end
    if params[:sdcode].to_s != ""
      search += " and pisj18.sdcode = '#{params[:sdcode]}' "
    end
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      allfields.delete("status")
      for i in 0...allfields.length
        case allfields[i]
          when "posid","salary"
            allfields[i] = "pisj18.#{allfields[i]}"
          when "subdeptname"
            allfields[i] = "csubdept.#{allfields[i]}"
          when "deptname"
            allfields[i] = "cdept.#{allfields[i]}"
          when "posname"
            allfields[i] = "cposition.#{allfields[i]}"
          when "cname"
            allfields[i] = "cgrouplevel.#{allfields[i]}"
        end
      end
      rs_name_person = Pispersonel.joins(" inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id ")
      rs_name_person = rs_name_person.count("pispersonel.pstatus = '1' and pisj18.flagupdate = '1' and pispersonel.fname like '%#{params[:query]}%' ")
      search += "and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "}  "
      if rs_name_person.to_i > 0
        sql_name_person = " or pisj18.posid in (select pispersonel.posid from pispersonel "
        sql_name_person += " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
        sql_name_person += " where pispersonel.pstatus = '1' and pisj18.flagupdate = '1' and pispersonel.fname like '%#{params[:query]}%') "
        search += sql_name_person
      end
      search += " ) "
    end
    rs = Pisj18.joins(str_join)
    rs = rs.find(:all, :conditions => search, :limit => limit, :offset => start, :order => "pisj18.posid")
    return_data = {}
    return_data[:totalCount] = Pisj18.joins(str_join).count(:all ,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      rs_id = Pispersonel.select("id,fname,lname,pcode").where(:pstatus => "1",:id => u.id ,:posid => u.posid)
      {
        :id => (rs_id.count > 0)? rs_id[0][:id] : "",
        :posid => u.posid,
        :status => (rs_id.count > 0)? rs_id[0].full_name : "ตำแหน่่งว่าง",
        :posname => (u.poscode.to_s.strip != "")? begin Cposition.find(u.poscode).full_name rescue "" end : "",
        :cname => (u.c.to_s.strip != "")? begin Cgrouplevel.find(u.c).cname rescue "" end : "",
        :salary => u.salary,
        :subdeptname => (u.sdcode.to_s.strip != "")? begin Csubdept.find(u.sdcode).full_name rescue "" end : "",
        :deptname => (u.deptcode.to_s.strip != "")? begin Cdept.find(u.deptcode).deptname rescue "" end : ""
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def create
    count_check = Pisj18.count(:all, :conditions => "posid = '#{params[:pisj18][:posid]}' ")
    if count_check > 0
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
      render :text => return_data.to_json, :layout=>false
    else
      params[:pisj18][:flagupdate] = '1'
      params[:pisj18][:asbdate] = to_date_db(params[:pisj18][:asbdate])
       params[:pisj18][:emptydate] = to_date_db(params[:pisj18][:emptydate])
      if QueryPis.insert_by_arg(params[:pisj18],"pisj18")
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
  
  def search_edit
    str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    posid = params[:posid]
    rs = Pisj18.select("pisj18.*,pispersonel.fname,pispersonel.lname,pispersonel.pcode").joins(str_join).find(posid)
    prefix = (rs.pcode.to_s == "")? "" : begin Cprefix.find(rs.pcode).longprefix rescue "" end
    rs[:subdept_show] = (rs.sdcode.to_s == "")? "" : begin Csubdept.find(rs.sdcode).full_name rescue "" end
    rs[:fname_lname] = (rs.fname.to_s == "" and rs.lname.to_s == "")? "ว่าง" : ["#{prefix}#{rs.fname.to_s}",rs.lname.to_s].join(" ")
    return_data = {}
    return_data[:success] = true
    return_data[:data] = rs
    render :text => return_data.to_json, :layout => false
  end
  
  def edit
    count_check = Pisj18.count(:all, :conditions => "posid = '#{params[:pisj18][:posid]}' and posid != '#{params[:posid]}' ")
    if count_check > 0
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
      render :text => return_data.to_json, :layout=>false
    else
      params[:pisj18][:asbdate] = to_date_db(params[:pisj18][:asbdate])
       params[:pisj18][:emptydate] = to_date_db(params[:pisj18][:emptydate])
      if QueryPis.update_by_arg(params[:pisj18],"pisj18","posid = '#{params[:posid]}'")
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
  
  

end
