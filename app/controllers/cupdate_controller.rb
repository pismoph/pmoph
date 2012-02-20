# coding: utf-8
class CupdateController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("updcode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
                end
                rs = Cupdate.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "updcode")
                return_data = Hash.new()
                return_data[:totalCount] = Cupdate.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :updcode_tmp => u.updcode,
                        :updcode => u.updcode,
                        :updname => u.updname,
                        :updsort => u.updsort,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["updcode_tmp"] == "" and records["updcode"] == "" and records["updname"] == "" and records["updsort"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cupdate.count(:all, :conditions => "updcode = #{records["updcode_tmp"]}")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cupdate.new
                                        store.updcode = records["updcode_tmp"]
                                        store.updname = records["updname"]
                                        store.updsort = records["updsort"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :updcode_tmp => store[:updcode],
                                                  :updcode => store[:updcode],
                                                  :updname => store[:updname],
                                                  :updsort => store[:updsort],
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
                        count_check = Cupdate.count(:all , :conditions => "updcode = #{records["updcode_tmp"]} and updcode <> #{records["updcode"]} ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสการเคลื่อนไหวนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = " update cupdate set
                                          updcode = #{records["updcode_tmp"]}
                                          ,updname = '#{records["updname"]}'
                                          ,updsort = #{records["updsort"]}
                                          ,use_status = '#{records["use_status"]}'
                                        where
                                          updcode = #{records["updcode"]}
                                "
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :updcode_tmp => records["updcode_tmp"],
                                                :updcode => records["updcode_tmp"],
                                                :updname => records["updname"],
                                                :updsort => records["updsort"],
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
                updcode = ActiveSupport::JSON.decode(params[:records])
                if Cupdate.delete(updcode)
                        render :text => "{success:true, records:{updcode:#{updcode}}}"
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
                        allfields.delete("updcode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cupdate.find(:all, :conditions => case_search, :order => "updcode")
        end
        

end
