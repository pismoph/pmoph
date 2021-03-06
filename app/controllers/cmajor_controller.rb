# coding: utf-8
class CmajorController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("macode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Cmajor.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "macode")
    return_data = Hash.new()
    return_data[:totalCount] = Cmajor.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :macode_tmp  => u.macode,                       
            :macode      => u.macode,
            :major    => u.major,
            :use_status   => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["macode_tmp"] == "" and records["macode"] == "" and records["major"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cmajor.count(:all, :conditions => "macode = '#{records["macode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Cmajor.new
                            store.macode = records["macode_tmp"]
                            store.major = records["major"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :macode_tmp => store[:macode],
                                      :macode => store[:macode],
                                      :major => store[:major],
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
            count_check = Cmajor.count(:all , :conditions => "macode = '#{records["macode_tmp"]}' and macode <> '#{records["macode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    sql = " update cmajor set
                              macode = #{records["macode_tmp"]}
                              ,major = '#{records["major"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              macode = #{records["macode"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :macode_tmp => records["macode_tmp"],
                                    :macode => records["macode_tmp"],
                                    :major => records["major"],
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
    macode = ActiveSupport::JSON.decode(params[:records])
    if Cmajor.delete(macode)
            render :text => "{success:true, records:{macode:#{macode}}}"
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
            allfields.delete("macode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cmajor.find(:all, :conditions => case_search, :order => "macode")
  end
end
