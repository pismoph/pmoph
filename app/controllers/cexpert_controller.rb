# coding: utf-8
class CexpertController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("epcode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
                end
                rs = Cexpert.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "epcode")
                return_data = Hash.new()
                return_data[:totalCount] = Cexpert.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :epcode_tmp => u.epcode,
                        :epcode => u.epcode,
                        :prename => u.prename,
                        :expert => u.expert,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["epcode_tmp"] == "" and records["epcode"] == "" and records["prename"] == "" and records["expert"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cexpert.count(:all, :conditions => "epcode = '#{records["epcode_tmp"]}'")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cexpert.new
                                        store.epcode = records["epcode_tmp"]
                                        store.prename = records["prename"]
                                        store.expert = records["expert"]
                                        store.use_status = records["use_status"]
                                        
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :epcode_tmp => store[:epcode],
                                                  :epcode => store[:epcode],
                                                  :prename => store[:prename],
                                                  :expert => store[:expert],
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
                        count_check = Cexpert.count(:all , :conditions => "epcode = '#{records["epcode_tmp"]}' and epcode <> '#{records["epcode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = "update cexpert set epcode = #{records["epcode_tmp"]} ,prename = '#{records["prename"]}' ,expert = '#{records["expert"]}' ,use_status = '#{records["use_status"]}' where epcode = #{records["epcode"]}"
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :epcode_tmp => records["epcode_tmp"],
                                                :epcode => records["epcode_tmp"],
                                                :prename => records["prename"],
                                                :expert => records["expert"],
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
                epcode = ActiveSupport::JSON.decode(params[:records])
                if Cexpert.delete(epcode)
                        render :text => "{success:true, records:{epcode:#{epcode}}}"
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
                        allfields.delete("epcode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cexpert.find(:all, :conditions => case_search)
        end

end
