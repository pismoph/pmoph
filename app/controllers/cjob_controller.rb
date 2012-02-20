# coding: utf-8
class CjobController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("jobcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cjob.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "jobcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cjob.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :jobcode_tmp => u.jobcode,
            :jobcode => u.jobcode,
            :jobname => u.jobname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["jobcode_tmp"] == "" and records["jobcode"] == "" and records["jobname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cjob.count(:all, :conditions => "jobcode = '#{records["jobcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cjob.new
                            store.jobcode = records["jobcode_tmp"]
                            store.jobname = records["jobname"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :jobcode_tmp => store[:jobcode],
                                      :jobcode => store[:jobcode],
                                      :jobname => store[:jobname],
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
            count_check = Cjob.count(:all , :conditions => "jobcode = '#{records["jobcode_tmp"]}' and jobcode <> '#{records["jobcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cjob set
                                jobcode = #{records["jobcode_tmp"].to_s}
                                ,jobname = '#{records["jobname"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where jobcode = #{records["jobcode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :jobcode => records["jobcode_tmp"],
                              :jobcode_tmp => records["jobcode_tmp"],
                              :jobname => records["jobname"],
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
    jobcode = ActiveSupport::JSON.decode(params[:records])
    if Cjob.delete(jobcode)
            render :text => "{success:true, records:{jobcode:#{jobcode}}}"
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
            allfields.delete("jobcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cjob.find(:all, :conditions => case_search, :order => "jobcode")
  end
end
