# coding: utf-8
class CtradeController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = Array.new
    case_search = ""
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
            allfields = ActiveSupport::JSON.decode(params[:fields])
            allfields.delete("codetrade_tmp")
            case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
    end
    rs = Ctrade.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "codetrade")
    return_data = Hash.new()
    return_data[:totalCount] = Ctrade.count(:all , :conditions => case_search)
    return_data[:records]   = rs.collect{|u| {
            :codetrade_tmp  => u.codetrade,                       
            :codetrade      => u.codetrade,
            :trade    => u.trade,
            :use_status   => (u.use_status == '1') ? true : false
    } }
    render :text => return_data.to_json, :layout => false
  end

  def create
    records = ActiveSupport::JSON.decode(params[:records])
    if records.type == Hash
            if records["codetrade_tmp"] == "" and records["codetrade"] == "" and records["trade"] == "" and records["use_status"] == ""
                    return_data = Hash.new()
                    return_data[:success] = false
                    render :text => return_data.to_json, :layout => false
            else
                    count_check = Ctrade.count(:all, :conditions => "codetrade = '#{records["codetrade_tmp"]}'")
                    if count_check > 0
                            return_data = Hash.new()
                            return_data[:success] = false
                            return_data[:msg] = "มีรหัสนี้แล้ว"
                            render :text => return_data.to_json, :layout=>false
                    else
                            records["use_status"] = (records["use_status"] == true) ? 1 : 0
                            store = Ctrade.new
                            store.codetrade = records["codetrade_tmp"]
                            store.trade = records["trade"]
                            store.use_status = records["use_status"]
                            if store.save
                               return_data = Hash.new()
                              return_data[:success] = true
                              return_data[:records] = {
                                      :codetrade_tmp => store[:codetrade],
                                      :codetrade => store[:codetrade],
                                      :trade => store[:trade],
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
            count_check = Ctrade.count(:all , :conditions => "codetrade = '#{records["codetrade_tmp"]}' and codetrade <> '#{records["codetrade"]}' ")
            if count_check > 0
                    return_data = Hash.new()
                    return_data[:success] = false
                    return_data[:msg] = "มีรหัสนี้แล้ว"
                    render :text => return_data.to_json, :layout=>false
            else
                    records["use_status"] = (records["use_status"] == true) ? 1 : 0
                    sql = " update ctrade set
                              codetrade = #{records["codetrade_tmp"]}
                              ,trade = '#{records["trade"]}'
                              ,use_status = '#{records["use_status"]}'
                            where
                              codetrade = #{records["codetrade"]}
                    "
                    if QueryPis.update_by_sql(sql)
                            return_data = Hash.new()
                            return_data[:success] = true
                            return_data[:records]= {
                                    :codetrade_tmp => records["codetrade_tmp"],
                                    :codetrade => records["codetrade_tmp"],
                                    :trade => records["trade"],
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
    codetrade = ActiveSupport::JSON.decode(params[:records])
    if Ctrade.delete(codetrade)
            render :text => "{success:true, records:{codetrade:#{codetrade}}}"
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
            allfields.delete("codetrade_tmp")
            case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
    end
    @records = Ctrade.find(:all, :conditions => case_search, :order => "codetrade")
  end
end
