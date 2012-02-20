# coding: utf-8
class CgrouplevelController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("ccode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
                end
                rs = Cgrouplevel.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "ccode")
                return_data = Hash.new()
                return_data[:totalCount] = Cgrouplevel.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :ccode_tmp => u.ccode,
                        :ccode => u.ccode,
                        :cname => u.cname,
                        :scname => u.scname,
                        :minsal1 => u.minsal1,
                        :maxsal1 => u.maxsal1,
                        :gname => u.gname,
                        :clname => u.clname,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["ccode_tmp"] == "" and records["ccode"] == "" and records["cname"] == "" and records["scname"] == "" and records["minsal1"] == "" and records["maxsal1"] == "" and records["gname"] == "" and records["clname"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cgrouplevel.count(:all, :conditions => "ccode = '#{records["ccode_tmp"]}'")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cgrouplevel.new
                                        store.ccode = records["ccode_tmp"]
                                        store.cname = records["cname"]
                                        store.scname = records["scname"]
                                        store.minsal1 = records["minsal1"]
                                        store.maxsal1 = records["maxsal1"]
                                        store.gname = records["gname"]
                                        store.clname = records["clname"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :ccode_tmp => store[:ccode],
                                                  :ccode => store[:ccode],
                                                  :cname => store[:cname],
                                                  :scname => store[:scname],
                                                  :minsal1 => store[:minsal1],
                                                  :maxsal1 => store[:maxsal1],
                                                  :gname => store[:gname],
                                                  :clname => store[:clname],
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
                        count_check = Cgrouplevel.count(:all , :conditions => "ccode = '#{records["ccode_tmp"]}' and ccode <> '#{records["ccode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = "update cgrouplevel set
                                          ccode = #{records["ccode_tmp"]}
                                          ,cname = '#{records["cname"]}'
                                          ,scname = '#{records["scname"]}'
                                          ,minsal1 = #{records["minsal1"]}
                                          ,maxsal1 = #{records["maxsal1"]}
                                          ,gname = '#{records["gname"]}'
                                          ,clname = '#{records["clname"]}'
                                          ,use_status = #{records["use_status"]}
                                      where
                                          ccode = #{records["ccode"]}
                                "
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :ccode_tmp => records["ccode_tmp"],
                                                :ccode => records["ccode_tmp"],
                                                :cname => records["cname"],
                                                :scname => records["scname"],
                                                :minsal1 => records["minsal1"],
                                                :maxsal1 => records["maxsal1"],
                                                :gname => records["gname"],
                                                :clname => records["clname"],
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
                ccode = ActiveSupport::JSON.decode(params[:records])
                if Cgrouplevel.delete(ccode)
                        render :text => "{success:true, records:{ccode:#{ccode}}}"
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
                        allfields.delete("ccode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cgrouplevel.find(:all, :conditions => case_search)
        end         
end
