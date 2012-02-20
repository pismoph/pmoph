# coding: utf-8
class CpositionController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("poscode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
    end
    rs = Cposition.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "poscode")
    return_data = Hash.new()
    return_data[:totalCount] = Cposition.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :poscode => u.poscode,
            :poscode_tmp => u.poscode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :posname => u.posname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["poscode_tmp"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["posname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cposition.count(:all, :conditions => "poscode = '#{records["poscode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cposition.new                            
                            store.poscode = records["poscode_tmp"]
                            store.shortpre = records["shortpre"]
                            store.longpre = records["longpre"]
                            store.posname = records["posname"]
                            store.use_status = records["use_status"]                            
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :poscode => store[:poscode],
                                      :poscode_tmp => store[:poscode],
                                      :shortpre => store[:shortpre],
                                      :longpre => store[:longpre],
                                      :posname => store[:posname],
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
            count_check = Cposition.count(:all , :conditions => "poscode = '#{records["poscode_tmp"]}' and poscode <> '#{records["poscode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update cposition set poscode = #{records["poscode_tmp"].to_s},shortpre = '#{records["shortpre"].to_s}',longpre = '#{records["longpre"].to_s}',posname = '#{records["posname"].to_s}',use_status = '#{records["use_status"]}' where poscode = #{records["poscode"].to_s}"
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :poscode => records["poscode_tmp"],
                              :poscode_tmp => records["poscode_tmp"],
                              :shortpre => records["shortpre"],
                              :longpre => records["longpre"],
                              :posname => records["posname"],
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
    poscode = ActiveSupport::JSON.decode(params[:records])
    if Cposition.delete(poscode)
            render :text => "{success:true, records:{poscode:#{poscode}}}"
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
            allfields.delete("poscode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cposition.find(:all, :conditions => case_search, :order => "poscode")
  end
end
