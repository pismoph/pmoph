# coding: utf-8
class CpunishController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("pncode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Cpunish.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "pncode")
    return_data = Hash.new()
    return_data[:totalCount] = Cpunish.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :pncode_tmp  => u.pncode,                       
            :pncode      => u.pncode,
            :pnname    => u.pnname,
            :use_status   => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["pncode_tmp"] == "" and records["pncode"] == "" and records["pnname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cpunish.count(:all, :conditions => "pncode = '#{records["pncode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cpunish.new
                            store.pncode = records["pncode_tmp"]
                            store.pnname = records["pnname"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :pncode_tmp => store[:pncode],
                                      :pncode => store[:pncode],
                                      :pnname => store[:pnname],
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
            count_check = Cpunish.count(:all , :conditions => "pncode = '#{records["pncode_tmp"]}' and pncode <> '#{records["pncode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    sql = " update Cpunish set
                              pncode = #{records["pncode_tmp"]}
                              ,pnname = '#{records["pnname"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              pncode = #{records["pncode"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :pncode_tmp => records["pncode_tmp"],
                                    :pncode => records["pncode_tmp"],
                                    :pnname => records["pnname"],
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
    pncode = ActiveSupport::JSON.decode(params[:records])
    if Cpunish.delete(pncode)
            render :text => "{success:true, records:{pncode:#{pncode}}}"
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
            allfields.delete("pncode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cpunish.find(:all, :conditions => case_search, :order => "pncode")
  end
end
