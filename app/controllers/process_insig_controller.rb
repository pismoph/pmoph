# coding: utf-8
class ProcessInsigController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  def check_count
    begin
      ################################################
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
      search = " pisj18.flagupdate = '1' and pstatus = '1' "
      if @current_user.group_user.type_group.to_s == "1"
        @user_work_place.each do |key,val|
          if key.to_s == "mcode"
            k = "mincode"
          else
            k = key
          end
          search += " and pisj18.#{k} = '#{val}'"
        end
      end
      if @current_user.group_user.type_group.to_s == "2"
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
      end
      sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
      ###############################################
      rs = TDgdcdcr.count(:conditions => "dcyear = #{params[:year]} and id in (#{sql_id})")
      render :text => "{success: true,count: #{rs.to_s}}"
    rescue
      render :text => "{success: false}" 
    end
  end
  def process_insig
    begin
      salary_51 = 10190
      salary_32 = 22140
      salary_33 = 53080
      posmny_35_1 = 13000
      posmny_35_2 = 15600
      salary_21 = 54090
      posmny_42_1 = 14500
      posmny_42_2 = 21000
      ################################################
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
      search = " pisj18.flagupdate = '1' and pstatus = '1' "
      if @current_user.group_user.type_group.to_s == "1"
        @user_work_place.each do |key,val|
          if key.to_s == "mcode"
            k = "mincode"
          else
            k = key
          end
          search += " and pisj18.#{k} = '#{val}'"
        end
      end
      if @current_user.group_user.type_group.to_s == "2"
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
      end
      sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
      ###############################################
      TDgdcdcr.delete_all("dcyear = #{params[:year]} and id in (#{sql_id})")
      sql = "
        select pispersonel.id,pisj18.posid,pisj18.poscode,pisj18.excode,pisj18.ptcode,pispersonel.appointdate,pispersonel.cdate,pisj18.c,pisj18.salary,pisj18.epcode,extract(year from date(pispersonel.retiredate)) as retire_year,pisj18.posmny,
          extract(year from age(date('#{params[:year].to_i - 543 }-10-05'),date(cdate) - interval '1 days')) as stay,
          extract(year from age(date('#{params[:year].to_i - 543 }-10-05'),date(appointdate) - interval '1 days')) as appoint_stay
        from pisj18 left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id 
        where  
          pispersonel.id in (#{sql_id}) and          
          pisj18.flagupdate = '1' and 
          pstatus = '1' and
          extract(year from age(date('#{params[:year].to_i - 543 }-10-05'),date(appointdate) - interval '1 days')) >= 5 and
          pispersonel.id not in (
            select pisj18.id
            from pisj18 left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id left join pisinsig on pispersonel.id = pisinsig.id
            where
              pispersonel.id in (#{sql_id}) and              
              pisj18.flagupdate = '1' and 
              pstatus = '1' and 
              ((pisj18.c = 51 and pisinsig.dccode = 4) or (pisj18.c = 52 and pisinsig.dccode = 6) or (pisj18.c = 53 and pisinsig.dccode = 8) or (pisj18.c = 54 and pisinsig.dccode = 11) or (pisj18.c = 31 and pisinsig.dccode = 5) or (pisj18.c = 32 and pisinsig.dccode = 8) or (pisj18.c = 33 and pisinsig.dccode = 9) or (pisj18.c = 34 and pisinsig.dccode = 11) or (pisj18.c = 35 and pisinsig.dccode = 12) or (pisj18.c = 21 and pisinsig.dccode = 9) or (pisj18.c = 22 and pisinsig.dccode = 11) or (pisj18.c = 41 and pisinsig.dccode = 11) or (pisj18.c = 42 and pisinsig.dccode = 12))
          ) 
      "
      id = []
      rs = TDgdcdcr.find_by_sql(sql)
      rs.each do |r|
        dcyear = Pisinsig.maximum(:dcyear,:conditions => "id = '#{r[:id]}'")
        ########################################## ccode = 51
        if r[:c].to_s == "51"
          dc = ""
          dccode = Pisinsig.find(:all,:conditions => "id = '#{r[:id]}' and dccode in (1,2,3,4) ").collect{|u| u.dccode.to_i}
          if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
            if r[:salary].to_i >= salary_51 and r[:stay].to_i >= 10 and !dccode.include?(4)
              dc = '4'
            end            
            if r[:salary].to_i >= salary_51 and r[:stay].to_i < 10 and !dccode.include?(3)
              dc = '3'
            end            
            if r[:salary].to_i < salary_51 and r[:stay].to_i >= 10 and !dccode.include?(2)
              dc = '2'
            end            
            if dc == '' and !dccode.include?(1)
              dc = '1'
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 52
        if r[:c].to_s == "52"
          dc = ""
          dccode = Pisinsig.find(:all,:conditions => "id = '#{r[:id]}' and dccode in (5,6) ").collect{|u| u.dccode.to_i}
          if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
            if r[:stay].to_i >= 5 and !dccode.include?(6)
              dc = '6'
            end
            if dc == '' and !dccode.include?(5)
              dc = '5'
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 53
        if r[:c].to_s == "53"
          dc = ""
          dccode = Pisinsig.find(:all,:conditions => "id = '#{r[:id]}' and dccode in (7,8) ").collect{|u| u.dccode.to_i}
          if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
            if r[:stay].to_i >= 5 and !dccode.include?(8)
              dc = '8'
            end
            if dc == '' and !dccode.include?(7)
              dc = '7'
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 54
        if r[:c].to_s == "54"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9,10,11) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
              if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 11
                dc = '11'
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i 
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 31
        if r[:c].to_s == "31"
          dc = ""
          dccode = Pisinsig.find(:all,:conditions => "id = '#{r[:id]}' and dccode = 5 ").collect{|u| u.dccode.to_i}
          if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and !dccode.include?(5)
            dc = '5'
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end            
          end
          
        end
        ########################################## ccode = 32
        if r[:c].to_s == "32"
          dc = ""
          dccode = Pisinsig.find(:all,:conditions => "id = '#{r[:id]}' and dccode in (6,7,8) ").collect{|u| u.dccode.to_i}
          if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
            if r[:salary].to_i >= salary_32 and r[:stay].to_i >= 5 and !dccode.include?(8)
              dc = '8'
            end
            if r[:salary].to_i >= salary_32 and r[:stay].to_i < 5 and !dccode.include?(7)
              dc = '7'
            end
            if dc == '' and !dccode.include?(6)
              dc = '6'
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end

          end
        end
        ########################################## ccode = 33
        if r[:c].to_s == "33"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
              if r[:salary].to_i >= salary_33 and rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 9
                dc = '9'
              end
            end
          end
          if dccode.nil?
            dc = '8'
          end
          if dc != ''
            id.push({
              :id => r[:id],
              :dccode => dc,
              :dcyear => params[:year],
              :poscode => r[:poscode],
              :excode => r[:excode],
              :epcode => r[:epcode],
              :c => r[:c],
              :entrydate => r[:appointdate],
              :leveldate => r[:cdate],
              :salary => r[:salary].to_s,
              :posid => r[:posid],
                :ptcode => r[:ptcode]
            })              
          end
        end
        ########################################## ccode = 34
        if r[:c].to_s == "34"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9,10,11) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
              if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 11
                dc = '11'
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 35
        if r[:c].to_s == "35"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (9,10,11,12) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if r[:posmny].to_i == posmny_35_1
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 12
                  dc = '12'
                end
              end              
              if r[:posmny].to_i == posmny_35_2
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 12
                  dc = '12'
                end
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i
              if r[:posmny].to_i == posmny_35_1
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
              end
              if r[:posmny].to_i == posmny_35_2
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 12
                  dc = '12'
                end
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end

          end
        end
        ########################################## ccode = 21
        if r[:c].to_s == "21"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 )
              if r[:salary].to_i >= salary_21 and rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
            end
          end
          if dccode.nil?
            dc = '8'
          end
          if dc != ''
            id.push({
              :id => r[:id],
              :dccode => dc,
              :dcyear => params[:year],
              :poscode => r[:poscode],
              :excode => r[:excode],
              :epcode => r[:epcode],
              :c => r[:c],
              :entrydate => r[:appointdate],
              :leveldate => r[:cdate],
              :salary => r[:salary].to_s,
              :posid => r[:posid],
                :ptcode => r[:ptcode]
            })              
          end
        end
        ########################################## ccode = 22
        if r[:c].to_s == "22"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9,10,11) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
              if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 11
                dc = '11'
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 41
        if r[:c].to_s == "41"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (8,9,10,11) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
              if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 11
                dc = '11'
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i
              if rs_insig[0].dccode.to_i == 8 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 9
                dc = '9'
              end
              if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                dc = '10'
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end
          end
        end
        ########################################## ccode = 42
        if r[:c].to_s == "42"
          dc = ""
          dccode = Pisinsig.maximum(:dccode,:conditions => "id = '#{r[:id]}' and dccode in (9,10,11,12) ")
          if !dccode.nil?
            rs_insig = Pisinsig.select("*, #{params[:year]} - dcyear as stay")
            rs_insig = rs_insig.where("id = '#{r[:id]}' and dccode = #{dccode} ")
            if dcyear.to_i != params[:year].to_i and dcyear.to_i != (params[:year].to_i - 1 ) and (r[:retire_year].to_i + 543) != params[:year].to_i
              if r[:posmny].to_i == posmny_42_1
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 5 and dccode.to_i != 12
                  dc = '12'
                end
              end              
              if r[:posmny].to_i == posmny_42_2
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 12
                  dc = '12'
                end
              end
            end
            if (r[:retire_year].to_i + 543) == params[:year].to_i
              if r[:posmny].to_i == posmny_42_1
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
              end
              if r[:posmny].to_i == posmny_42_2
                if rs_insig[0].dccode.to_i == 9 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 10
                  dc = '10'
                end
                if rs_insig[0].dccode.to_i == 10 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 11
                  dc = '11'
                end
                if rs_insig[0].dccode.to_i == 11 and rs_insig[0].stay.to_i >= 3 and dccode.to_i != 12
                  dc = '12'
                end
              end
            end
            if dc != ''
              id.push({
                :id => r[:id],
                :dccode => dc,
                :dcyear => params[:year],
                :poscode => r[:poscode],
                :excode => r[:excode],
                :epcode => r[:epcode],
                :c => r[:c],
                :entrydate => r[:appointdate],
                :leveldate => r[:cdate],
                :salary => r[:salary].to_s,
                :posid => r[:posid],
                :ptcode => r[:ptcode]
              })              
            end

          end
        end
      end
      val = []
      id.each do |d|
        val.push("(
          '#{d[:id]}',#{d[:dccode]},#{d[:dcyear]},#{d[:poscode]},#{(d[:excode].to_s == "")? 'null' : d[:excode]},
          #{(d[:epcode].to_s == "")? 'null' : d[:epcode]},#{(d[:c].to_s == "")? 'null' : d[:c]},'#{(d[:entrydate].to_s == "")? 'null' : d[:entrydate]}',
          '#{(d[:leveldate].to_s == "")? 'null' : d[:leveldate]}',#{(d[:salary].to_s == "")? 'null' : d[:salary]},
          #{(d[:ptcode].to_s == "")? 'null' : d[:ptcode]}
        )")
      end
      if val.length > 0
        sql = "insert into t_dgdcdcr(id,dccode,dcyear,poscode,excode,epcode,c,entrydate,leveldate,salary,ptcode) values#{val.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
  
  def read
    ################################################
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
      search = " pisj18.flagupdate = '1' and pstatus = '1' "
      if @current_user.group_user.type_group.to_s == "1"
        @user_work_place.each do |key,val|
          if key.to_s == "mcode"
            k = "mincode"
          else
            k = key
          end
          search += " and pisj18.#{k} = '#{val}'"
        end
      end
      if @current_user.group_user.type_group.to_s == "2"
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
      end
      sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
    ###############################################
    str_join = " left join pispersonel on t_dgdcdcr.id = pispersonel.id "
    str_join += " left join cprefix on cprefix.pcode = pispersonel.pcode " 
    rs = TDgdcdcr.select("pispersonel.sex,pispersonel.posid,t_dgdcdcr.*,cprefix.prefix,fname,lname,sex,pispersonel.id").joins(str_join)
    .find(:all,:conditions => "dcyear = #{params[:year]} and t_dgdcdcr.id in (#{sql_id})",:order => "pispersonel.posid")
    return_data = {}
    return_data[:totalCount] = TDgdcdcr.count(:all , :conditions => "dcyear = #{params[:year]} and id in (#{sql_id})")
    return_data[:records]   = rs.collect{|u| {
      :id => u.id,
      :posid => u.posid,
      :prefix => u.prefix,
      :fname => u.fname,
      :lname => u.lname,
      :sex => case u.sex.to_s
              when '1' then "ชาย"
              when '2' then "หญิง"
              else ""
              end
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def get_process_insig
    id = params[:id]
    str_join = " left join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " left join cprefix on cprefix.pcode = pispersonel.pcode " 
    select = "pisj18.posid,pisj18.poscode,pisj18.excode,pisj18.ptcode,pisj18.ptcode"
    select += ",pispersonel.appointdate,pispersonel.cdate,pisj18.c,pisj18.salary,pisj18.epcode,pisj18.id"
    select += ",fname,lname,prefix"
    rs = Pispersonel.select(select).joins(str_join).find(:all,:conditions => "pispersonel.id = '#{id}' and pisj18.flagupdate = '1' and pstatus = '1' ")
    return_data = {}
    return_data[:success] = true
    return_data[:records]   = rs.collect{|u| {
      :posid => u.posid,
      :poscode => u.poscode,
      :excode => u.excode,
      :ptcode => u.ptcode,
      :ptcode => u.ptcode,
      :entrydate => u.appointdate,
      :leveldate => u.cdate,
      :c => u.c,
      :salary => u.salary,
      :epcode => u.epcode,
      :id => u.id,
      :name => "#{u.prefix}#{u.fname}  #{u.lname}"
    }}
    render :text => return_data.to_json, :layout => false
  end

  def create
    chk = TDgdcdcr.count(:all,:conditions => "dcyear = #{params[:t_dgdcdcr][:dcyear]} and id = '#{params[:t_dgdcdcr][:id]}' ")
    if chk > 0
      render :text => "{success:false,msg: 'มีข้อมูลแล้วในปีที่ขอ'}"
    else
      rs = TDgdcdcr.new(params[:t_dgdcdcr])
      rs.id = params[:t_dgdcdcr][:id]
      rs.entrydate = to_date_db(params[:t_dgdcdcr][:entrydate])
      rs.leveldate = to_date_db(params[:t_dgdcdcr][:leveldate])
      rs.save
      render :text => "{success:true}",:layout => false      
    end
  end
  
  def delete
    begin
      TDgdcdcr.delete_all("dcyear= #{params[:year]} and id in (#{params[:id]})")
      render :text => "{success:true}",:layout => false      
    rescue
      render :text => "{success:false}",:layout => false      
    end
  end
  def get_edit_process_insig
    id = params[:id]
    year = params[:year]
    str_join = " left join pispersonel on t_dgdcdcr.id = pispersonel.id "
    str_join += " left join cprefix on cprefix.pcode = pispersonel.pcode " 
    rs = TDgdcdcr.select("t_dgdcdcr.*,posid,prefix,fname,lname").joins(str_join)
    .find(:all,:conditions => "dcyear = #{year} and t_dgdcdcr.id = '#{id}'")
    return_data = {}
    return_data[:success] = true
    return_data[:records]   = rs.collect{|u| {
      :posid => u.posid,
      :poscode => u.poscode,
      :excode => u.excode,
      :ptcode => u.ptcode,
      :ptcode => u.ptcode,
      :entrydate => u.entrydate,
      :leveldate => u.leveldate,
      :c => u.c,
      :salary => u.salary,
      :epcode => u.epcode,
      :id => u.id,
      :name => "#{u.prefix}#{u.fname}  #{u.lname}",
      :dccode => u.dccode,
      :note1 => u.note1,
      :note2 => u.note2      
    }}
    render :text => return_data.to_json, :layout => false
  end
  def update
    begin
      id = params[:t_dgdcdcr][:id]
      year = params[:t_dgdcdcr][:dcyear]
      params[:t_dgdcdcr][:entrydate] = to_date_db(params[:t_dgdcdcr][:entrydate])
      params[:t_dgdcdcr][:leveldate] = to_date_db(params[:t_dgdcdcr][:leveldate])
      params[:t_dgdcdcr][:poscode] = (params[:t_dgdcdcr][:poscode].to_s == "")? nil : params[:t_dgdcdcr][:poscode]
      params[:t_dgdcdcr][:c] = (params[:t_dgdcdcr][:c].to_s == "")? nil : params[:t_dgdcdcr][:c]
      params[:t_dgdcdcr][:excode] = (params[:t_dgdcdcr][:excode].to_s == "")? nil : params[:t_dgdcdcr][:excode]
      params[:t_dgdcdcr][:ptcode] = (params[:t_dgdcdcr][:ptcode].to_s == "")? nil : params[:t_dgdcdcr][:ptcode]
      params[:t_dgdcdcr][:epcode] = (params[:t_dgdcdcr][:epcode].to_s == "")? nil : params[:t_dgdcdcr][:epcode]
      params[:t_dgdcdcr][:salary] = (params[:t_dgdcdcr][:salary].to_s == "")? nil : params[:t_dgdcdcr][:salary]
      params[:t_dgdcdcr][:note1] = (params[:t_dgdcdcr][:note1].to_s == "")? nil : params[:t_dgdcdcr][:note1] 
      params[:t_dgdcdcr][:note2] = (params[:t_dgdcdcr][:note2].to_s == "")? nil : params[:t_dgdcdcr][:note2]
      TDgdcdcr.update_all(params[:t_dgdcdcr],"dcyear = #{year} and t_dgdcdcr.id = '#{id}'")
      render :text => "{success:true}",:layout => false
    rescue
      render :text => "{success: false}",:layout => false
    end
  end
  
  def report_down
      ################################################
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
      search = " pisj18.flagupdate = '1' and pstatus = '1' "
      if @current_user.group_user.type_group.to_s == "1"
        @user_work_place.each do |key,val|
          if key.to_s == "mcode"
            k = "mincode"
          else
            k = key
          end
          search += " and pisj18.#{k} = '#{val}'"
        end
      end
      if @current_user.group_user.type_group.to_s == "2"
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
      end
      sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
      ###############################################
      rs_subdept = Csubdept.find(@user_work_place[:sdcode])
      @subdeptname = "#{rs_subdept.shortpre}#{rs_subdept.subdeptname}"
      str_join = " left join pispersonel on t_dgdcdcr.id = pispersonel.id "
      str_join += " left join cprefix on cprefix.pcode = pispersonel.pcode "
      str_join += " left join cgrouplevel on t_dgdcdcr.c = cgrouplevel.ccode "
      str_join += " left join cposition on t_dgdcdcr.poscode = cposition.poscode "
      str_join += " left join cdecoratype on  t_dgdcdcr.dccode = cdecoratype.dccode "
      select = "t_dgdcdcr.*,fname,lname,prefix,gname,clname,posname,t_dgdcdcr.note1,t_dgdcdcr.note2,cdecoratype.shortname as dcname"
      @records = TDgdcdcr.select(select).joins(str_join).where("t_dgdcdcr.id in (#{sql_id}) and t_dgdcdcr.dcyear = #{params[:year]} and t_dgdcdcr.dccode in (1,2,3,4,5)").order("fname")
      prawnto :prawn=>{
        :page_layout=>:landscape,
        :top_margin =>172,
        :left_margin => 10,
        :right_margin => 10
      }
  end
  
  def report_up
      ################################################
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
      search = " pisj18.flagupdate = '1' and pstatus = '1' "
      if @current_user.group_user.type_group.to_s == "1"
        @user_work_place.each do |key,val|
          if key.to_s == "mcode"
            k = "mincode"
          else
            k = key
          end
          search += " and pisj18.#{k} = '#{val}'"
        end
      end
      if @current_user.group_user.type_group.to_s == "2"
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
      end
      sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
      ###############################################
      rs_subdept = Csubdept.find(@user_work_place[:sdcode])
      @subdeptname = "#{rs_subdept.shortpre}#{rs_subdept.subdeptname}"
      str_join = " left join pispersonel on t_dgdcdcr.id = pispersonel.id "
      str_join += " left join cprefix on cprefix.pcode = pispersonel.pcode "
      str_join += " left join cgrouplevel on t_dgdcdcr.c = cgrouplevel.ccode "
      str_join += " left join cposition on t_dgdcdcr.poscode = cposition.poscode "
      str_join += " left join cdecoratype on  t_dgdcdcr.dccode = cdecoratype.dccode "
      select = "t_dgdcdcr.*,fname,lname,prefix,gname,clname,posname,t_dgdcdcr.note1,t_dgdcdcr.note2,cdecoratype.shortname as dcname"
      @records = TDgdcdcr.select(select).joins(str_join).where("t_dgdcdcr.id in (#{sql_id}) and t_dgdcdcr.dcyear = #{params[:year]} and t_dgdcdcr.dccode >  5 and t_dgdcdcr.dccode <> 22").order("fname")
      prawnto :prawn=>{
        :page_layout=>:landscape,
        :top_margin =>172,
        :left_margin => 10,
        :right_margin => 10
      }
  end
  def approved
    begin
      year = params[:t_dgdcdcr][:dcyear]
      ################################################
        str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
        str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
        search = " pisj18.flagupdate = '1' and pstatus = '1' "
        if @current_user.group_user.type_group.to_s == "1"
          @user_work_place.each do |key,val|
            if key.to_s == "mcode"
              k = "mincode"
            else
              k = key
            end
            search += " and pisj18.#{k} = '#{val}'"
          end
        end
        if @current_user.group_user.type_group.to_s == "2"
          search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
        end
        sql_id = "select pisj18.id from pisj18 #{str_join} where #{search} "
      ###############################################
      val = []
      params[:t_dgdcdcr][:kitjadate] = to_date_db(params[:t_dgdcdcr][:kitjadate])
      TDgdcdcr.update_all(params[:t_dgdcdcr],"t_dgdcdcr.id in (#{sql_id}) and t_dgdcdcr.dcyear = #{year}")
      rs = TDgdcdcr.select("t_dgdcdcr.*").where("t_dgdcdcr.id in (#{sql_id}) and t_dgdcdcr.dcyear = #{year}")
      rs.each do |u|
        note = "#{u.note1} #{u.note2}".strip
        val.push("('#{u.id}',#{u.dccode},#{u.dcyear},'#{u.book}','#{u.section}','#{u.kitjadate}',#{(u.poscode.to_s == "")? "null" : u.poscode},#{(u.excode.to_s == "")? "null" : u.excode},#{(u.epcode.to_s == "")? "null" : u.epcode},#{(u.c.to_s == "")? "null" : u.c},#{(u.ptcode.to_s == "")? "null" : u.ptcode},#{(note.to_s == "")? "null" : "'#{note}'"})")
      end
      if val.length > 0
        sql = "insert into pisinsig(id,dccode,dcyear,book,section,kitjadate,poscode,excode,epcode,c,ptcode,note) values#{val.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
end
