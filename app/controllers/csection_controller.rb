# coding: utf-8
class CsectionController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("seccode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Csection.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "seccode")
    return_data = Hash.new()
    return_data[:totalCount] = Csection.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :seccode_tmp => u.seccode,
            :seccode => u.seccode,
            :shortname => u.shortname,
            :secname => u.secname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["seccode_tmp"] == "" and records["seccode"] == "" and records["secname"] == "" and records["use_status"] == "" and records["shortname"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Csection.count(:all, :conditions => "seccode = '#{records["seccode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Csection.new
                            store.seccode = records["seccode_tmp"]
                            store.shortname = records["shortname"]
                            store.secname = records["secname"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :seccode_tmp => store[:seccode],
                                      :seccode => store[:seccode],
                                      :shortname => store[:shortname],
                                      :secname => store[:secname],
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
            count_check = Csection.count(:all , :conditions => "seccode = '#{records["seccode_tmp"]}' and seccode <> '#{records["seccode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Csection set
                                seccode = #{records["seccode_tmp"].to_s}
                                ,secname = '#{records["secname"].to_s}'
                                ,shortname = '#{records["shortname"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where seccode = #{records["seccode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :seccode => records["seccode_tmp"],
                              :seccode_tmp => records["seccode_tmp"],
                              :shortname => records["shortname"],
                              :secname => records["secname"],
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
    seccode = ActiveSupport::JSON.decode(params[:records])
    if Csection.delete(seccode)
            render :text => "{success:true, records:{seccode:#{seccode}}}"
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
            allfields.delete("seccode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Csection.find(:all, :conditions => case_search, :order => "seccode")
  end
end
