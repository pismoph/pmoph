# coding: utf-8
class OutPositionController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def process_out_position
    params[:cmd][:forcedate] = to_date_db(params[:cmd][:forcedate])
    begin
      Pisposhis.transaction do
        rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:olded][:id]}'")
        params[:cmd][:historder] = rs_order[0].historder.to_i + 1
        params[:newed][:id] = params[:olded][:id]
        val = []
        k = []
        params[:newed].keys.each {|u|
          v = to_data_db(params[:newed][u])
          val.push("#{v}")
          if u.to_s == "mincode"
            k.push("mcode")
          else
            k.push("#{u}")
          end            
        }
        params[:cmd].keys.each {|u|
          v = to_data_db(params[:cmd][u])
          val.push("#{v}")
          k.push("#{u}")
        }
        sql = "insert into pisposhis(#{k.join(",")}) values(#{val.join(",")})"
        ActiveRecord::Base.connection.execute(sql)
        #-----------------------------------------------------------------------------------------------------------------------
        Pisj18.update_all("flagupdate = #{(params[:flagupdate].to_s == '1')? "0" : "1"}","posid = #{params[:olded][:posid]}")
        Pispersonel.update_all("pstatus = 0","id = '#{params[:olded][:id]}'")
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาดลองใหม่อีกครั้ง'}"
    end 
  end
end
