# coding: utf-8
class CexecutiveController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("excode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
                end
                rs = Cexecutive.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "excode")
                return_data = Hash.new()
                return_data[:totalCount] = Cexecutive.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :excode_tmp => u.excode,
                        :excode => u.excode,
                        :shortpre => u.shortpre,
                        :longpre => u.longpre,
                        :exname => u.exname,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["excode_tmp"] == "" and records["excode"] == "" and records["shortpre"] == "" and records["longpre"] == "" and records["exname"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cexecutive.count(:all, :conditions => "excode = '#{records["excode_tmp"]}'")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cexecutive.new                                        
                                        store.excode = records["excode_tmp"]
                                        store.shortpre = records["shortpre"]
                                        store.longpre = records["longpre"]
                                        store.exname = records["exname"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :excode_tmp => store[:excode],
                                                  :excode => store[:excode],
                                                  :shortpre => store[:shortpre],
                                                  :longpre => store[:longpre],
                                                  :exname => store[:exname],
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
                        count_check = Cexecutive.count(:all , :conditions => "excode = '#{records["excode_tmp"]}' and excode <> '#{records["excode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = " update cexecutive set excode = #{records["excode_tmp"]},shortpre = '#{records["shortpre"]}',longpre = '#{records["longpre"]}' ,exname = '#{records["exname"]}',use_status = '#{records["use_status"]}' where excode = #{records["excode"]}"
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :excode_tmp => records["excode_tmp"],
                                                :excode => records["excode_tmp"],
                                                :shortpre => records["shortpre"],
                                                :longpre => records["longpre"],
                                                :exname => records["exname"],
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
                excode = ActiveSupport::JSON.decode(params[:records])
                if Cexecutive.delete(excode)
                        render :text => "{success:true, records:{excode:#{excode}}}"
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
                        allfields.delete("excode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cexecutive.find(:all, :conditions => case_search)
        end  
end
