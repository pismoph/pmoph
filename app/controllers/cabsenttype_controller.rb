# coding: utf-8
class CabsenttypeController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("abcode_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Cabsenttype.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "abcode")
    return_data = Hash.new()
    return_data[:totalCount] = Cabsenttype.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :abcode_tmp => u.abcode,
            :abcode => u.abcode,
            :abtype => u.abtype,
            :abquota => u.abquota,
            :chk => (u.chk == '1') ? true : false ,
            :cnt => (u.cnt == '1') ? true : false ,
            :use_status => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["abcode_tmp"] == "" and records["abcode"] == "" and records["abtype"] == "" and records["abquota"].to_s == ""  and records["chk"].to_s == ""  and records["cnt"].to_s == ""  and records["use_status"].to_s == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Cabsenttype.count(:all, :conditions => "abcode = '#{records["abcode_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            records["chk"] = (records["chk"] == true) ? 1 : 0
                            records["cnt"] = (records["cnt"] == true) ? 1 : 0
                            store = Cabsenttype.new
                            store.abcode = records["abcode_tmp"]
                            store.abtype = records["abtype"]
                            store.abquota = records["abquota"]
                            store.chk = records["chk"]
                            store.cnt = records["cnt"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :abcode_tmp => store[:abcode],
                                      :abcode => store[:abcode],
                                      :abtype => store[:abtype],
                                      :chk => (store[:chk] == 1) ? true : false ,
                                      :cnt => (store[:cnt] == 1) ? true : false ,
                                      :abquota => store[:abquota],
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
            count_check = Cabsenttype.count(:all , :conditions => "abcode = '#{records["abcode_tmp"]}' and abcode <> '#{records["abcode"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    records["chk"] = (records["chk"] == true) ? 1 : 0
                    records["cnt"] = (records["cnt"] == true) ? 1 : 0
                    sql = " update cabsenttype set
                              abcode = #{records["abcode_tmp"]}
                              ,abtype = '#{records["abtype"]}'
                              ,chk = '#{records["chk"]}'
                              ,cnt = '#{records["cnt"]}'
                              ,abquota = '#{records["abquota"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              abcode = #{records["abcode"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :abcode_tmp => records["abcode_tmp"],
                                    :abcode => records["abcode_tmp"],
                                    :abtype => records["abtype"],
                                    :chk => (records["chk"] == 1) ? true : false ,
                                    :cnt => (records["cnt"] == 1) ? true : false ,
                                    :abquota => records["abquota"],
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
    abcode = ActiveSupport::JSON.decode(params[:records])
    if Cabsenttype.delete(abcode)
            render :text => "{success:true, records:{abcode:#{abcode}}}"
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
            allfields.delete("abcode_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Cabsenttype.find(:all, :conditions => case_search, :order => "abcode")
  end



end
