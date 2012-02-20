# coding: utf-8
class Cj18statusController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("j18code_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Cj18status.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "j18code")
    return_data = Hash.new()
    return_data[:totalCount] = Cj18status.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :j18code_tmp  => u.j18code,                       
            :j18code      => u.j18code,
            :j18status    => u.j18status,
            :use_status   => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["j18code_tmp"] == "" and records["j18code"] == "" and records["j18status"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cj18status.count(:all, :conditions => "j18code = '#{records["j18code_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cj18status.new
                            store.j18code = records["j18code_tmp"]
                            store.j18status = records["j18status"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :j18code_tmp => store[:j18code],
                                      :j18code => store[:j18code],
                                      :j18status => store[:j18status],
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
            count_check = Cj18status.count(:all , :conditions => "j18code = '#{records["j18code_tmp"]}' and j18code <> '#{records["j18code"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    sql = " update cj18status set
                              j18code = #{records["j18code_tmp"]}
                              ,j18status = '#{records["j18status"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              j18code = #{records["j18code"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :j18code_tmp => records["j18code_tmp"],
                                    :j18code => records["j18code_tmp"],
                                    :j18status => records["j18status"],
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
    j18code = ActiveSupport::JSON.decode(params[:records])
    if Cj18status.delete(j18code)
            render :text => "{success:true, records:{j18code:#{j18code}}}"
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
            allfields.delete("j18code_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cj18status.find(:all, :conditions => case_search, :order => "j18code")
  end

end
