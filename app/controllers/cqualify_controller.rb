# coding: utf-8
class CqualifyController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("qcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cqualify.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "qcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cqualify.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :qcode => u.qcode,
            :qcode_tmp => u.qcode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :qualify => u.qualify,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["qcode_tmp"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["qualify"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cqualify.count(:all, :conditions => "qcode = '#{records["qcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cqualify.new                            
                            store.qcode = records["qcode_tmp"]
                            store.shortpre = records["shortpre"]
                            store.longpre = records["longpre"]
                            store.qualify = records["qualify"]
                            store.use_status = records["use_status"]                            
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :qcode => store[:qcode],
                                      :qcode_tmp => store[:qcode],
                                      :shortpre => store[:shortpre],
                                      :longpre => store[:longpre],
                                      :qualify => store[:qualify],
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
            count_check = Cqualify.count(:all , :conditions => "qcode = '#{records["qcode_tmp"]}' and qcode <> '#{records["qcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cqualify set qcode = #{records["qcode_tmp"].to_s},shortpre = '#{records["shortpre"].to_s}',longpre = '#{records["longpre"].to_s}',qualify = '#{records["qualify"].to_s}',use_status = '#{records["use_status"]}' where qcode = #{records["qcode"].to_s}"
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :qcode => records["qcode_tmp"],
                              :qcode_tmp => records["qcode_tmp"],
                              :shortpre => records["shortpre"],
                              :longpre => records["longpre"],
                              :qualify => records["qualify"],
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
    qcode = ActiveSupport::JSON.decode(params[:records])
    if Cqualify.delete(qcode)
            render :text => "{success:true, records:{qcode:#{qcode}}}"
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
            allfields.delete("qcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cqualify.find(:all, :conditions => case_search, :order => "qcode")
  end
end
