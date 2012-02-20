# coding: utf-8
class CpostypeController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("ptcode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
                end
                rs = Cpostype.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "ptcode")
                return_data = Hash.new()
                return_data[:totalCount] = Cpostype.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :ptcode_tmp => u.ptcode,
                        :ptcode => u.ptcode,
                        :ptname => u.ptname,
                        :shortmn => u.shortmn,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["ptcode_tmp"] == "" and records["ptcode"] == "" and records["ptname"] == "" and records["shortmn"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cpostype.count(:all, :conditions => "ptcode = '#{records["ptcode_tmp"]}'")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสประเภทนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cpostype.new                                       
                                        store.ptcode = records["ptcode_tmp"]
                                        store.ptname = records["ptname"]
                                        store.shortmn = records["shortmn"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :ptcode_tmp => store[:ptcode],
                                                  :ptcode => store[:ptcode],
                                                  :ptname => store[:ptname],
                                                  :shortmn => store[:shortmn],
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
                        count_check = Cpostype.count(:all , :conditions => "ptcode = '#{records["ptcode_tmp"]}' and ptcode <> '#{records["ptcode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = "update cpostype set                                
                                                ptcode = #{records["ptcode_tmp"]}
                                                ,ptname = '#{records["ptname"]}'
                                                ,shortmn = '#{records["shortmn"]}'
                                                ,use_status = '#{records["use_status"]}'
                                        where ptcode = #{records["ptcode"]}
                                "                                
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :ptcode_tmp => records["ptcode_tmp"],
                                                :ptcode => records["ptcode_tmp"],
                                                :ptname => records["ptname"],
                                                :shortmn => records["shortmn"],
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
                ptcode = ActiveSupport::JSON.decode(params[:records])
                if Cpostype.delete(ptcode)
                        render :text => "{success:true, records:{ptcode:#{ptcode}}}"
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
                        allfields.delete("ptcode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cpostype.find(:all, :conditions => case_search)
        end
end
