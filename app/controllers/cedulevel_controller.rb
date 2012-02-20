# coding: utf-8
class CedulevelController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("ecode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Cedulevel.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "ecode")
    return_data = Hash.new()
    return_data[:totalCount] = Cedulevel.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :ecode_tmp  => u.ecode,                       
            :ecode      => u.ecode,
            :edulevel    => u.edulevel,
            :use_status   => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["ecode_tmp"] == "" and records["ecode"] == "" and records["edulevel"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cedulevel.count(:all, :conditions => "ecode = '#{records["ecode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cedulevel.new
                            store.ecode = records["ecode_tmp"]
                            store.edulevel = records["edulevel"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :ecode_tmp => store[:ecode],
                                      :ecode => store[:ecode],
                                      :edulevel => store[:edulevel],
                                      :use_status => (store[:use_status] == 1) ? true : false
                              }
                              render :text => return_data.to_json, :layout => false
                            else
                              render :text => "{success:false,msg:'เกิดข้อผิดพลาดกรุุณาทำรายการใหม่อีกครั้ง'}"   
                            end
                    end
            end
    else
            render :text => "{success: false}"
    end
  end
	
  def update
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            count_check = Cedulevel.count(:all , :conditions => "ecode = '#{records["ecode_tmp"]}' and ecode <> '#{records["ecode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    sql = " update cedulevel set
                              ecode = #{records["ecode_tmp"]}
                              ,edulevel = '#{records["edulevel"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              ecode = #{records["ecode"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :ecode_tmp => records["ecode_tmp"],
                                    :ecode => records["ecode_tmp"],
                                    :edulevel => records["edulevel"],
                                    :use_status => (records["use_status"] == 1) ? true : false
                            }
                            render :text => return_data.to_json, :layout => false
                    else
                            render :text => "{success:false,msg:'เกิดข้อผิดพลาดกรุุณาทำรายการใหม่อีกครั้ง'}"   
                    end
            end
    else
            render :text => "{success:false}"
    end
  end
	
  def delete
    ecode = ActiveSupport::JSON.decode(params[:records])
    if Cedulevel.delete(ecode)
            render :text => "{success:true, records:{ecode:#{ecode}}}"
    else
            render :text => "{success:false}"
    end
  end
	
  def report
    data = ActiveSupport::JSON.decode(params[:data])
    search = Array.new
    case_search = ""
    if !(data["fields"].nil?) and !(data["query"].nil?) and data["query"] != "" and data["fields"] != ""
            allfields = ActiveSupport::JSON.decode(data["fields"])
            allfields.delete("ecode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cedulevel.find(:all, :conditions => case_search, :order => "ecode")
  end
end
