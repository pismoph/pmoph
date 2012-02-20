# coding: utf-8
class CamphurController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("amcode_tmp")
            allfields.delete("provcode")
            case_search = "(" + allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' " + ") and "
    end
    case_search = case_search + " provcode = #{params[:provcode]}"
    rs = Camphur.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "amcode")
    return_data = Hash.new()
    return_data[:totalCount] = Camphur.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :amcode_tmp => u.amcode,
            :amcode => u.amcode,
            :provcode => u.provcode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :amname => u.amname,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end


  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["amcode"] == "" and records["amcode_tmp"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["amname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Camphur.count(:all, :conditions => "amcode = #{records["amcode_tmp"]} and provcode = '#{records["provcode"]}' ")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Camphur.new                            
                            store.amcode = records["amcode_tmp"]
                            store.provcode = records["provcode"]
                            store.shortpre = records["shortpre"]
                            store.longpre = records["longpre"]
                            store.amname = records["amname"]
                            store.use_status = records["use_status"]                            
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :amcode_tmp => store[:amcode],
                                      :amcode => store[:amcode],
                                      :provcode => store[:provcode],
                                      :shortpre => store[:shortpre],
                                      :longpre => store[:longpre],
                                      :amname => store[:amname],
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
            count_check = Camphur.count(:all , :conditions => "(amcode = '#{records["amcode_tmp"]}' and provcode = #{records["provcode"].to_s}) and amcode <> '#{records["amcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update camphur set
                                amcode = #{records["amcode_tmp"].to_s},
                                shortpre = '#{records["shortpre"].to_s}',
                                longpre = '#{records["longpre"].to_s}',
                                amname = '#{records["amname"].to_s}',
                                use_status = '#{records["use_status"]}'
                            where amcode = #{records["amcode"].to_s} and provcode = #{records["provcode"].to_s} "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :amcode => records["amcode_tmp"],
                              :amcode_tmp => records["amcode_tmp"],
                              :provcode => records["provcode"],
                              :shortpre => records["shortpre"],
                              :longpre => records["longpre"],
                              :amname => records["amname"],
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
    amcode = ActiveSupport::JSON.decode(params[:records])
    if Camphur.delete_all("provcode = #{params[:provcode].to_s} and amcode = #{amcode}")
            render :text => "{success:true, records:{amcode:#{amcode}}}"
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
            allfields.delete("amcode_tmp")
            allfields.delete("provcode")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' and "
    end
    case_search +=  " provcode = #{data["provcode"]}"
    @province = Cprovince.find(data["provcode"]).provname
    @records = Camphur.find(:all, :conditions => case_search, :order => "amcode")
  end

end
