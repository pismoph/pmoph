# coding: utf-8
class CareaController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("acode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Carea.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "acode")
    return_data = Hash.new()
    return_data[:totalCount] = Carea.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :acode_tmp => u.acode,
            :acode => u.acode,
            :aname => u.aname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["acode_tmp"] == "" and records["acode"] == "" and records["aname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Carea.count(:all, :conditions => "acode = '#{records["acode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Carea.new
                            store.acode = records["acode_tmp"]
                            store.aname = records["aname"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :acode_tmp => store[:acode],
                                      :acode => store[:acode],
                                      :aname => store[:aname],
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
            count_check = Carea.count(:all , :conditions => "acode = '#{records["acode_tmp"]}' and acode <> '#{records["acode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Carea set
                                acode = #{records["acode_tmp"].to_s}
                                ,aname = '#{records["aname"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where acode = #{records["acode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :acode => records["acode_tmp"],
                              :acode_tmp => records["acode_tmp"],
                              :aname => records["aname"],
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
    acode = ActiveSupport::JSON.decode(params[:records])
    if Carea.delete(acode)
            render :text => "{success:true, records:{acode:#{acode}}}"
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
            allfields.delete("acode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Carea.find(:all, :conditions => case_search, :order => "acode")
  end
end
