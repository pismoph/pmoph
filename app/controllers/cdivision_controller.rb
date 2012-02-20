# coding: utf-8
class CdivisionController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("dcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cdivision.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "dcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cdivision.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :dcode_tmp => u.dcode,
            :dcode => u.dcode,
            :prefix => u.prefix,
            :division => u.division,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["dcode_tmp"] == "" and records["dcode"] == "" and records["division"] == "" and records["use_status"] == "" and records["prefix"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cdivision.count(:all, :conditions => "dcode = '#{records["dcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cdivision.new
                            store.dcode = records["dcode_tmp"]
                            store.prefix = records["prefix"]
                            store.division = records["division"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :dcode_tmp => store[:dcode],
                                      :dcode => store[:dcode],
                                      :prefix => store[:prefix],
                                      :division => store[:division],
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
            count_check = Cdivision.count(:all , :conditions => "dcode = '#{records["dcode_tmp"]}' and dcode <> '#{records["dcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cdivision set
                                dcode = #{records["dcode_tmp"].to_s}
                                ,division = '#{records["division"].to_s}'
                                ,prefix = '#{records["prefix"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where dcode = #{records["dcode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :dcode => records["dcode_tmp"],
                              :dcode_tmp => records["dcode_tmp"],
                              :prefix => records["prefix"],
                              :division => records["division"],
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
    dcode = ActiveSupport::JSON.decode(params[:records])
    if Cdivision.delete(dcode)
            render :text => "{success:true, records:{dcode:#{dcode}}}"
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
            allfields.delete("dcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cdivision.find(:all, :conditions => case_search, :order => "dcode")
  end
  
end
