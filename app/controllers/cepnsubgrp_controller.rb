# coding: utf-8
class CepnsubgrpController < ApplicationController
        before_filter :login_menu_code
        skip_before_filter :verify_authenticity_token
        def read
                limit = params[:limit]
                start = params[:start]
                search = Array.new
                case_search = ""
                if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
                        allfields = ActiveSupport::JSON.decode(params[:fields])
                        allfields.delete("grpcode_tmp")
                        case_search = allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "
                end
                rs = Cepnsubgrp.find(:all, :conditions => case_search, :limit => limit, :offset => start, :order => "grpcode")
                return_data = Hash.new()
                return_data[:totalCount] = Cepnsubgrp.count(:all , :conditions => case_search)
                return_data[:records]   = rs.collect{|u| {
                        :grpcode_tmp => u.grpcode,
                        :grpcode => u.grpcode,
                        :grpnm => u.grpnm,
                        :use_status => (u.use_status == '1') ? true : false
                } }
                render :text => return_data.to_json, :layout => false
        end

        def create
                records = ActiveSupport::JSON.decode(params[:records])
                if records.type == Hash
                        if records["grpcode_tmp"] == "" and records["grpcode"] == "" and records["grpnm"] == "" and records["use_status"] == ""
                                return_data = Hash.new()
                                return_data[:success] = false
                                render :text => return_data.to_json, :layout => false
                        else
                                count_check = Cepnsubgrp.count(:all, :conditions => "grpcode = '#{records["grpcode_tmp"]}'")
                                if count_check > 0
                                        return_data = Hash.new()
                                        return_data[:success] = false
                                        return_data[:msg] = "มีรหัสตำแหน่งนี้แล้ว"
                                        render :text => return_data.to_json, :layout=>false
                                else
                                        records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                        store = Cepnsubgrp.new
                                        store.grpcode = records["grpcode_tmp"]
                                        store.grpnm = records["grpnm"]
                                        store.use_status = records["use_status"]
                                        if store.save
                                          return_data = Hash.new()
                                          return_data[:success] = true
                                          return_data[:records] = {
                                                  :grpcode_tmp => store[:grpcode],
                                                  :grpcode => store[:grpcode],
                                                  :grpnm => store[:grpnm],
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
                        count_check = Cepnsubgrp.count(:all , :conditions => "grpcode = '#{records["grpcode_tmp"]}' and grpcode <> '#{records["grpcode"]}' ")
                        if count_check > 0
                                return_data = Hash.new()
                                return_data[:success] = false
                                return_data[:msg] = "มีรหัสหมวดนี้แล้ว"
                                render :text => return_data.to_json, :layout=>false
                        else
                                records["use_status"] = (records["use_status"] == true) ? 1 : 0
                                sql = "update cepnsubgrp set
                                          grpcode = #{records["grpcode_tmp"]}
                                          ,grpnm = '#{records["grpnm"]}'
                                          ,use_status = '#{records["use_status"]}'
                                      where grpcode = #{records["grpcode"]}
                                "
                                if QueryPis.update_by_sql(sql)
                                        return_data = Hash.new()
                                        return_data[:success] = true
                                        return_data[:records]= {
                                                :grpcode_tmp => records["grpcode_tmp"],
                                                :grpcode => records["grpcode_tmp"],
                                                :grpnm => records["grpnm"],
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
                grpcode = ActiveSupport::JSON.decode(params[:records])
                if Cepnsubgrp.delete(grpcode)
                        render :text => "{success:true, records:{grpcode:#{grpcode}}}"
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
                        allfields.delete("grpcode_tmp")
                        case_search = allfields.join("::varchar like '%#{data["query"]}%' or ") + "::varchar like '%#{data["query"]}%' "
                end
                @records = Cepnsubgrp.find(:all, :conditions => case_search)
        end


end
