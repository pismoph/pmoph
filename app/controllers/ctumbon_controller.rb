# coding: utf-8
class CtumbonController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    if params[:reset].to_s == ""
      limit = params[:limit]
      start = params[:start]
      search = Array.new
      case_search = ""
      if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
              allfields = ActiveSupport::JSON.decode(params[:fields])
              allfields.delete("tmcode_tmp")
              allfields.delete("amcode")
              allfields.delete("provcode")
              case_search = "(" + allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' " + ") and "
      end
      case_search = case_search + " provcode = #{params[:provcode]} and amcode = #{params[:amcode]}"
      rs = Ctumbon.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "tmcode")
      return_data = Hash.new()
      return_data[:totalCount] = Ctumbon.count(:all , :conditions => case_search)
      return_data[:records]   = rs.collect{|u| {
              :tmcode_tmp => u.tmcode,
              :tmcode => u.tmcode,
              :amcode => u.amcode,
              :provcode => u.provcode,
              :shortpre => u.shortpre,
              :longpre => u.longpre,
              :tmname => u.tmname,
              :use_status => (u.use_status == '1') ? true : false
      } }
      render :text => return_data.to_json, :layout => false
    else
      render :text => "{records: [],totalCount: 0}", :layout => false
    end
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["tmcode"] == "" and records["tmcode_tmp"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["tmname"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Ctumbon.count(:all, :conditions => "tmcode = #{records["tmcode_tmp"]} and amcode = #{records["amcode"]} and provcode = '#{records["provcode"]}' ")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Ctumbon.new                            
                            store.tmcode = records["tmcode_tmp"]
                            store.amcode = records["amcode"]
                            store.provcode = records["provcode"]
                            store.shortpre = records["shortpre"]
                            store.longpre = records["longpre"]
                            store.tmname = records["tmname"]
                            store.use_status = records["use_status"]                            
                            if store.save                             
                              return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :tmcode_tmp => store[:tmcode],
                                      :tmcode => store[:tmcode],
                                      :amcode => store[:amcode],
                                      :provcode => store[:provcode],
                                      :shortpre => store[:shortpre],
                                      :longpre => store[:longpre],
                                      :tmname => store[:tmname],
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
            count_check = Ctumbon.count(:all , :conditions => "(tmcode = '#{records["tmcode_tmp"]}' and
                                                                amcode = '#{records["amcode"]}' and
                                                                provcode = #{records["provcode"].to_s}) and
                                                                tmcode <> '#{records["tmcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true)? 1 : 0
                    sql = " update Ctumbon set
                                tmcode = #{records["tmcode_tmp"].to_s},
                                shortpre = '#{records["shortpre"].to_s}',
                                longpre = '#{records["longpre"].to_s}',
                                tmname = '#{records["tmname"].to_s}',
                                use_status = '#{records["use_status"]}'
                            where tmcode = #{records["tmcode"].to_s} and amcode = #{records["amcode"].to_s} and provcode = #{records["provcode"].to_s} "
                    if QueryPis.update_by_sql(sql)
                      return_data = Hash.new()
                      return_data[:success] = true
                      return_data[:records]= {
                              :tmcode => records["tmcode_tmp"],
                              :tmcode_tmp => records["tmcode_tmp"],
                              :amcode => records["amcode"],
                              :provcode => records["provcode"],
                              :shortpre => records["shortpre"],
                              :longpre => records["longpre"],
                              :tmname => records["tmname"],
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
    tmcode = ActiveSupport::JSON.decode(params[:records])
    if Ctumbon.delete_all("provcode = #{params[:provcode].to_s} and amcode = #{params[:amcode].to_s} and tmcode = #{tmcode}   ")
            render :text => "{success:true, records:{tmcode:#{tmcode}}}"
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
            allfields.delete("tmcode_tmp")
            allfields.delete("amcode")
            allfields.delete("provcode")
            case_search = "(" +allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%') and "
    end
    case_search = case_search + " provcode = #{data["provcode"]} and amcode = #{data["amcode"]}"
    @province = Cprovince.find(data["provcode"]).provname
    @amphur = Camphur.find(data["amcode"]).amname
    @records = Ctumbon.find(:all, :conditions => case_search, :order => "tmcode")
  end



end
