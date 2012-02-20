# coding: utf-8
class CdeptController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("deptcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cdept.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "deptcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cdept.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :deptcode_tmp => u.deptcode,
            :deptcode => u.deptcode,
            :deptname => u.deptname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["deptcode_tmp"] == "" and records["deptcode"] == "" and records["deptname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cdept.count(:all, :conditions => "deptcode = '#{records["deptcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cdept.new
                            store.deptcode = records["deptcode_tmp"]
                            store.deptname = records["deptname"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :deptcode_tmp => store[:deptcode],
                                      :deptcode => store[:deptcode],
                                      :deptname => store[:deptname],
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
            count_check = Cdept.count(:all , :conditions => "deptcode = '#{records["deptcode_tmp"]}' and deptcode <> '#{records["deptcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cdept set
                                deptcode = #{records["deptcode_tmp"].to_s}
                                ,deptname = '#{records["deptname"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where deptcode = #{records["deptcode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :deptcode => records["deptcode_tmp"],
                              :deptcode_tmp => records["deptcode_tmp"],
                              :deptname => records["deptname"],
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
    deptcode = ActiveSupport::JSON.decode(params[:records])
    if Cdept.delete(deptcode)
            render :text => "{success:true, records:{deptcode:#{deptcode}}}"
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
            allfields.delete("deptcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cdept.find(:all, :conditions => case_search, :order => "deptcode")
  end
  
end
