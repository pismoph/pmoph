# coding: utf-8
class CprefixController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("pcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cprefix.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "pcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cprefix.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :pcode_tmp => u.pcode,
            :pcode => u.pcode,
            :prefix => u.prefix,
            :longprefix => u.longprefix,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["pcode_tmp"] == "" and records["pcode"] == "" and records["longprefix"] == "" and records["use_status"] == "" and records["prefix"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cprefix.count(:all, :conditions => "pcode = '#{records["pcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cprefix.new
                            store.pcode = records["pcode_tmp"]
                            store.prefix = records["prefix"]
                            store.longprefix = records["longprefix"]
                            store.use_status = records["use_status"]
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :pcode_tmp => store[:pcode],
                                      :pcode => store[:pcode],
                                      :prefix => store[:prefix],
                                      :longprefix => store[:longprefix],
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
            count_check = Cprefix.count(:all , :conditions => "pcode = '#{records["pcode_tmp"]}' and pcode <> '#{records["pcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Cprefix set
                                pcode = #{records["pcode_tmp"].to_s}
                                ,longprefix = '#{records["longprefix"].to_s}'
                                ,prefix = '#{records["prefix"].to_s}'
                                ,use_status = '#{records["use_status"]}'
                            where pcode = #{records["pcode"].to_s}
                    "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :pcode => records["pcode_tmp"],
                              :pcode_tmp => records["pcode_tmp"],
                              :prefix => records["prefix"],
                              :longprefix => records["longprefix"],
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
    pcode = ActiveSupport::JSON.decode(params[:records])
    if Cprefix.delete(pcode)
            render :text => "{success:true, records:{pcode:#{pcode}}}"
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
            allfields.delete("pcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cprefix.find(:all, :conditions => case_search, :order => "pcode")
  end  
end
