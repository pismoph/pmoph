# coding: utf-8
class CepnposworkController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("wrkcode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "                        
                end
                rs = Cepnposwork.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "wrkcode")
                return_data = Hash.new()
                return_data[:totalCount] = Cepnposwork.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :wrkcode_tmp => u.wrkcode,
                        :wrkcode => u.wrkcode,
                        :gcode => u.gcode,
                        :grpcode => u.grpcode,
                        :wrknm => u.wrknm,
                        :levels => u.levels,
                        :minwages => u.minwages,
                        :maxwages => u.maxwages,
                        :wrkatrb => u.wrkatrb,
                        :note => u.note,
                        :numcode => u.numcode,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["id"] == "" and records["wrkcode"] == "" and records["gcode"] == "" and records["grpcode"] == "" and records["wrknm"] == "" and records["levels"] == "" and records["minwages"] == "" and records["maxwages"] == "" and records["wrkatrb"] == "" and records["note"] == "" and records["numcode"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cepnposwork.count(:all, :conditions => "wrkcode = #{records["wrkcode_tmp"]}")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cepnposwork.new
                                        store.wrkcode = records["wrkcode_tmp"]
                                        store.gcode = records["gcode"]
                                        store.grpcode = records["grpcode"]
                                        store.wrknm = records["wrknm"]
                                        store.levels = records["levels"]
                                        store.minwages = records["minwages"]
                                        store.maxwages = records["maxwages"]
                                        store.wrkatrb = records["wrkatrb"]
                                        store.note = records["note"]
                                        store.numcode = records["numcode"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :wrkcode_tmp => store[:wrkcode],
                                                  :wrkcode => store[:wrkcode],
                                                  :gcode => store[:gcode],
                                                  :grpcode => store[:grpcode],
                                                  :wrknm => store[:wrknm],
                                                  :levels => store[:levels],
                                                  :minwages => store[:minwages],
                                                  :maxwages => store[:maxwages],
                                                  :wrkatrb => store[:wrkatrb],
                                                  :note => store[:note],
                                                  :numcode => store[:numcode],
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
                        count_check = Cepnposwork.count(:all , :conditions => "wrkcode = '#{records["wrkcode_tmp"]}' and wrkcode <> '#{records["wrkcode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = "update cepnposwork set
                                          wrkcode = #{records["wrkcode_tmp"]}
                                          ,gcode = #{records["gcode"]}
                                          ,grpcode = #{records["grpcode"]}
                                          ,wrknm = '#{records["wrknm"]}'
                                          ,levels = #{records["levels"]}
                                          ,minwages = #{records["minwages"]}
                                          ,maxwages = #{records["maxwages"]}
                                          ,wrkatrb = '#{records["wrkatrb"]}'
                                          ,note = '#{records["note"]}'
                                          ,numcode = #{records["numcode"]}
                                          ,use_status = '#{records["use_status"]}'
                                      where wrkcode = #{records["wrkcode"]}
                                "
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :wrkcode_tmp => records["wrkcode_tmp"],
                                                :wrkcode => records["wrkcode_tmp"],
                                                :gcode => records["gcode"],
                                                :grpcode => records["grpcode"],
                                                :wrknm => records["wrknm"],
                                                :levels => records["levels"],
                                                :minwages => records["minwages"],
                                                :maxwages => records["maxwages"],
                                                :wrkatrb => records["wrkatrb"],
                                                :note => records["note"],
                                                :numcode => records["numcode"],
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
                wrkcode = ActiveSupport::JSON.decode(params[:records])
                if Cepnposwork.delete(wrkcode)
                        render :text => "{success:true, records:{wrkcode:#{wrkcode}}}"
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
                        allfields.delete("wrkcode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cepnposwork.find(:all, :conditions => case_search)
        end

end
