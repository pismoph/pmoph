# coding: utf-8
class CprovinceController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("provcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cprovince.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "provcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cprovince.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :provcode => u.provcode,
            :provcode_tmp => u.provcode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :provname => u.provname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["provcode_tmp"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["provname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cprovince.count(:all, :conditions => "provcode = '#{records["provcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cprovince.new                            
                            store.provcode = records["provcode_tmp"]
                            store.shortpre = records["shortpre"]
                            store.longpre = records["longpre"]
                            store.provname = records["provname"]
                            store.use_status = records["use_status"]                            
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :provcode => store[:provcode],
                                      :provcode_tmp => store[:provcode],
                                      :shortpre => store[:shortpre],
                                      :longpre => store[:longpre],
                                      :provname => store[:provname],
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
            count_check = Cprovince.count(:all , :conditions => "provcode = '#{records["provcode_tmp"]}' and provcode <> '#{records["provcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cprovince set provcode = #{records["provcode_tmp"].to_s},shortpre = '#{records["shortpre"].to_s}',longpre = '#{records["longpre"].to_s}',provname = '#{records["provname"].to_s}',use_status = '#{records["use_status"]}' where provcode = #{records["provcode"].to_s}"
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :provcode => records["provcode_tmp"],
                              :provcode_tmp => records["provcode_tmp"],
                              :shortpre => records["shortpre"],
                              :longpre => records["longpre"],
                              :provname => records["provname"],
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
    provcode = ActiveSupport::JSON.decode(params[:records])
    if Cprovince.delete(provcode)
            render :text => "{success:true, records:{provcode:#{provcode}}}"
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
            allfields.delete("provcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cprovince.find(:all, :conditions => case_search, :order => "provcode")
  end
end
