# coding: utf-8
class GovActionController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def process_gov_action
    params[:cmd][:forcedate] = to_date_db(params[:cmd][:forcedate])
    begin
      Pisposhis.transaction do
        rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:pispersonel][:id]}'")
        params[:cmd][:historder] = rs_order[0].historder.to_i + 1
        val = []
        k = []
        params[:pispersonel].keys.each {|u|
          if u.to_s != "j18code"
            v = to_data_db(params[:pispersonel][u])
            val.push("#{v}")
            if u.to_s == "mincode"
              k.push("mcode")
            else
              k.push("#{u}")
            end                        
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
        val = []
        params[:pispersonel].keys.each {|u|
          v = to_data_db(params[:pispersonel][u])
          val.push("#{u.to_s} = #{v}")
        }
        sql = "update pispersonel set #{val.join(",")} where id = '#{params[:pispersonel][:id]}'"
        ActiveRecord::Base.connection.execute(sql)
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาดลองใหม่อีกครั้ง'}"
    end       
  end
end
