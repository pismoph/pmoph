# coding: utf-8
class PutPositionController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def process_put_position
    sql = []
    err = []
    params[:cmd][:forcedate] = to_date_db(params[:cmd][:forcedate])
    params[:pispersonel][:birthdate] = to_date_db(params[:pispersonel][:birthdate])
    params[:pispersonel][:appointdate] = to_date_db(params[:pispersonel][:appointdate])
    params[:pispersonel][:deptdate] = to_date_db(params[:pispersonel][:deptdate])
    params[:pispersonel][:cdate] = to_date_db(params[:pispersonel][:cdate])
    params[:pispersonel][:reentrydate] = to_date_db(params[:pispersonel][:reentrydate])
    params[:pispersonel][:attenddate] = to_date_db(params[:pispersonel][:attenddate])
    params[:pispersonel][:getindate] = to_date_db(params[:pispersonel][:getindate])
    params[:pispersonel][:quitdate] = to_date_db(params[:pispersonel][:quitdate])
    params[:pispersonel][:retiredate] = to_date_db(params[:pispersonel][:retiredate])
    params[:pispersonel][:pstatus] = '1'
    params[:pispersonel][:posid] = params[:pisj18][:posid]
    params[:pispersonel][:kbk] = params[:kbk]
    if params[:pispersonel][:id].to_s == ""
      cn = Pispersonel.count(:conditions => "pid = '#{params[:pispersonel][:pid]}'")
      if cn > 0
        err.push("เลขบัตรประชาชนมีแล้วในระบบ")
      else
        id_max = Pispersonel.maximum(:id).to_i + 1
        params[:pispersonel][:id] = id_max
        val = []
        k = []
        params[:pispersonel].keys.each {|u|
          v = to_data_db(params[:pispersonel][u])
          val.push("#{v}")
          k.push("#{u}")
        }
        
        params[:pisj18].keys.each {|u|
          if ["poscode","c","salary","epcode","ptcode"].include?(u.to_s)
            v = to_data_db(params[:pisj18][u])
            val.push("#{v}")
            k.push("#{u}")
          end
        }
        
        sql.push("insert into pispersonel(#{k.join(",")}) values(#{val.join(",")})")
      end
    else
      val = []
      params[:pispersonel].keys.each {|u|
        v = to_data_db(params[:pispersonel][u])
        val.push("#{u.to_s} = #{v}")
      }
      
      params[:pisj18].keys.each {|u|
        if ["poscode","c","salary","epcode","ptcode"].include?(u.to_s)
          v = to_data_db(params[:pisj18][u])
          val.push("#{u.to_s} = #{v}")
        end
      }
      val.push("exitdate = null")
      sql.push("update pispersonel set #{val.join(",")} where id = '#{params[:pispersonel][:id]}'")
    end
    if err.length > 0
      render :text => "{success: false,msg: '#{err.join(",")}'}"
    else
      params[:pisj18][:id] = params[:pispersonel][:id]
      #begin
        Pisj18.transaction do
          #---------------------------------------------------------------------------
          
          rs_pisj18 = Pisj18.find(params[:pisj18][:posid])
          if rs_pisj18.nowsal.to_i > params[:pisj18][:salary].to_i
            params[:pisj18][:nowsalasb] = params[:pisj18][:salary]
          end
          if rs_pisj18.nowsal.to_i < params[:pisj18][:salary].to_i
            params[:pisj18][:nowsal] = params[:pisj18][:salary]
          end
          
          if rs_pisj18.nowc.to_i > params[:pisj18][:c].to_i
            params[:pisj18][:nowcasb] = params[:pisj18][:c]
          end
          if rs_pisj18.nowc.to_i < params[:pisj18][:c].to_i
            params[:pisj18][:nowc] = params[:pisj18][:c]
          end
          
          params[:pisj18][:emptydate] = ''
          val = []
          params[:pisj18].keys.each {|u|
            v = to_data_db(params[:pisj18][u])
            val.push("#{u.to_s} = #{v}")
          }
          
          Pisj18.update_all(val.join(","),"posid = #{params[:pisj18][:posid]}")
          #---------------------------------------------------------------------------
          sql.each do |s|
            ActiveRecord::Base.connection.execute(s)
          end
          #--------------------------------------------------------------------------
          rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:pisj18][:id]}'")
          params[:cmd][:historder] = rs_order[0].historder.to_i + 1
          val = []
          k = []
          params[:pisj18].keys.each {|u|
            if u.to_s != "emptydate" and u.to_s != "nowsalasb" and u.to_s != "nowsal" and u.to_s != "nowcasb" and u.to_s != "nowc"
              v = to_data_db(params[:pisj18][u])
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
        end    
        render :text => "{success: true}"
      #rescue
      #  render :text => "{success: false,msg: 'เกิดความผิดพลาดลองใหม่อีกครั้ง'}"
      #end    
    end
  end
  
end
