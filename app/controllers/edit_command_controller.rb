# coding: utf-8
class EditCommandController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token  
  def process_edit_command
    params[:pisposhis][:forcedate] = to_date_db(params[:pisposhis][:forcedate])
    #begin
      Pisposhis.transaction do
        val = []
        params[:pisposhis].keys.each {|u|
          v = to_data_db(params[:pisposhis][u])
          val.push("#{u.to_s} = #{v}")
        }
        sql = "update pisposhis set #{val.join(",")} where id = '#{params[:pisposhis][:id]}' and historder = #{params[:pisposhis][:historder]}"
        ActiveRecord::Base.connection.execute(sql)
        #--------------------------------------------------------------------------------------------------------------------------------------
        #ปรับปรุงข้อมูลตำแหน่ง(จ.18)...ถือจ่ายปัจจุบัน
        if params[:update_pisj18].to_s == '1'
          check = true
          if @current_user.group_user.type_group.to_s == "1"
            @user_work_place.each do |k,v|
              check = false if k.to_s == "mcode" and params[:pisposhis][:mcode].to_s != v.to_s
              check = false if k.to_s == "deptcode" and params[:pisposhis][:deptcode].to_s != v.to_s
              check = false if k.to_s == "dcode" and params[:pisposhis][:dcode].to_s != v.to_s
              check = false if k.to_s == "sdcode" and params[:pisposhis][:sdcode].to_s != v.to_s
              check = false if k.to_s == "seccode" and params[:pisposhis][:seccode].to_s != v.to_s
              check = false if k.to_s == "jobcode" and params[:pisposhis][:jobcode].to_s != v.to_s
            end
          end
          if @current_user.group_user.type_group.to_s == "2"
            search = "csubdept.provcode = #{@current_user.group_user.provcode} and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
            search += " and csubdept.sdcode = #{params[:pisposhis][:sdcode]}"
            cn = Csubdept.count(:conditions => search)
            @user_work_place.each do |k,v|
              check = false if k.to_s == "mcode" and params[:pisposhis][:mcode].to_s != v.to_s
              check = false if k.to_s == "deptcode" and params[:pisposhis][:deptcode].to_s != v.to_s
              check = false if k.to_s == "dcode" and params[:pisposhis][:dcode].to_s != v.to_s
              check = false if k.to_s == "sdcode" and cn == 0
              check = false if k.to_s == "seccode" and params[:pisposhis][:seccode].to_s != v.to_s
              check = false if k.to_s == "jobcode" and params[:pisposhis][:jobcode].to_s != v.to_s
            end
          end
          if check
            val = []
            params[:pisposhis].keys.each {|u|
              if !["refcmnd","historder","updcode","forcedate","uppercent","posmny","upsalary","spmny","note"].include?(u.to_s)
                v = to_data_db(params[:pisposhis][u])
                if u.to_s == "mcode"
                  val.push("mincode = #{v}")
                else
                  val.push("#{u.to_s} = #{v}")
                end
              end
            }
            sql = "update pisj18 set #{val.join(",")} where posid = #{params[:pisposhis][:posid]}"
            ActiveRecord::Base.connection.execute(sql)            
          end
        end
        #-------------------------------------------------------------------------------------------------------------------------------------
        #ปรับปรุงข้อมูลปฎิบัติราชการปัจจุบัน
        if params[:update_pispersonel].to_s == '1'
          val = []
          params[:pisposhis].keys.each {|u|
            if !["refcmnd","historder","updcode","forcedate","uppercent","posmny","upsalary","note"].include?(u.to_s)
              v = to_data_db(params[:pisposhis][u])
              if u.to_s == "mcode"
                val.push("mincode = #{v}")
              else
                val.push("#{u.to_s} = #{v}")
              end
            end
          }
          sql = "update pispersonel set #{val.join(",")} where id = '#{params[:pisposhis][:id]}'"
          ActiveRecord::Base.connection.execute(sql)          
        end
        
      end
      render :text => "{success: true}"
      
    #rescue
    #  render :text => "{success: false,msg: 'เกิดความผิดพลาดลองใหม่อีกครั้ง'}"
    #end       
  end
end
