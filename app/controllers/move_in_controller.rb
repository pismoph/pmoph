# coding: utf-8
class MoveInController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  
  def set_left
    posid = params[:posid]
    records = {}
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
    rs_cn = Pispersonel.count(:all,:conditions => "pstatus = '1' and posid = #{posid} and id in (#{sql_id})")
    if rs_cn > 0
      search = " pisj18.flagupdate = '1' "
      search = " pisj18.posid = #{posid} "
      search += " and pispersonel.pstatus = '1' "
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id"
      str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
      str_join += " left join cposition on pisj18.poscode = cposition.poscode "
      str_join += " left join cgrouplevel on pisj18.c = cgrouplevel.ccode "
      str_join += " left join cexecutive on pisj18.excode = cexecutive.excode "
      str_join += " left join cexpert on pisj18.epcode = cexpert.epcode "
      str_join += " left join cpostype on pisj18.ptcode = cpostype.ptcode "
      str_join += " left join cdivision on pisj18.dcode = cdivision.dcode "
      str_join += " left join csubdept on pisj18.sdcode = csubdept.sdcode "
      str_join += " left join cdept on pisj18.deptcode = cdept.deptcode "
      str_join += " left join csection on pisj18.seccode = csection.seccode "
      str_join += " left join cjob on pisj18.jobcode = cjob.jobcode "
      
      select = "pisj18.posid,pispersonel.id,pispersonel.fname,pispersonel.lname,cprefix.prefix"
      select += ",pispersonel.id,cposition.shortpre as pospre,cposition.posname,cgrouplevel.cname"
      select += ",pisj18.salary,cexecutive.shortpre as expre,cexecutive.exname,cexpert.expert"
      select += ",cpostype.ptname,cdivision.division,cexpert,prename as eppre,cdivision.prefix as dpre"
      select += ",csubdept.subdeptname,csubdept.shortpre as sdpre,cdept.deptname,cjob.jobname,pispersonel.j18code"
      select += ",csection.shortname as secpre,csection.secname"
      select += ",pispersonel.deptcode as wdeptcode"
      select += ",pispersonel.dcode as wdcode"
      select += ",pispersonel.sdcode as wsdcode"
      select += ",pispersonel.seccode as wseccode"
      select += ",pispersonel.jobcode as wjobcode,pisj18.sdcode"
      
      rs = Pisj18.joins(str_join).select(select)
      rs = rs.where(search)
      records[:data] = rs.collect{|u|
        {
          :posid => u.posid,
          :id => u.id,
          :name => ("#{u.prefix}#{u.fname} #{u.lname}".strip == "")? "ตำแหน่งว่าง" : "#{u.prefix}#{u.fname} #{u.lname}".strip,
          :posname => "#{u.pospre}#{u.posname}".strip,
          :cname => "#{u.cname.to_s}",
          :salary => number_with_delimiter(u.salary.to_i),
          :exname => "#{u.expre.to_s}#{u.exname.to_s}".strip,
          :expert => "#{u.eppre.to_s}#{u.expert.to_s}".strip,
          :ptname => u.ptname.to_s,
          :division => "#{u.dpre.to_s}#{u.division.to_s}".strip,
          :subdeptname => begin Csubdept.find(u.sdcode).full_shortpre_name rescue "" end,
          :secname => "#{u.secpre}#{u.secname.to_s}",
          :jobname => u.jobname.to_s,
          :j18code => u.j18code,
          :wdeptname => begin Cdept.find(u.wdeptcode).deptname rescue "" end,
          :wdivision => begin Cdivision.find(u.wdcode).full_name rescue "" end,
          :wsubdeptname => begin Csubdept.find(u.wsdcode).full_shortpre_name rescue "" end,
          :wsecname => begin Csection.find(u.wseccode).full_name rescue "" end,
          :wjobname => begin Cjob.find(u.wjobcode).jobname rescue "" end
      }}
      records[:success] = true
    else
      records[:success] = false
      records[:msg] = "ไม่พบข้อมูล"
    end
    render :text => records.to_json
  end
  
  def set_right
    posid = params[:posid]
    records = {}
    ################################################
    str_join = " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode "
    search = " pisj18.flagupdate = '1' "
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
    sql_id = "select pisj18.posid from pisj18 #{str_join} where #{search} "
    ###############################################
    rs_cn = Pisj18.count(:all,:conditions => "posid in (#{sql_id}) and posid = #{posid}")
    if rs_cn > 0
      search = " pisj18.flagupdate = '1' "
      search += " and pisj18.posid = #{posid} "
      #search += " and pispersonel.pstatus = '1' "
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id and pispersonel.pstatus = '1' "
      str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
      
      select = "pisj18.*,pispersonel.fname,pispersonel.lname,cprefix.prefix,pispersonel.spmny"
      
      rs = Pisj18.joins(str_join).select(select)
      rs = rs.where(search)
      records[:data] = rs.collect{|u|
        {
          :posid => u.posid,
          :id => u.id.to_s,
          :name => ("#{u.prefix}#{u.fname} #{u.lname}".strip == "")? "ตำแหน่งว่าง" : "#{u.prefix}#{u.fname} #{u.lname}".strip,
          :poscode => u.poscode.to_s,
          :c => u.c.to_s,
          :uppercent => "",
          :upsalary => "",
          :salary => u.salary.to_i.to_s,
          :posmny => u.posmny.to_s,
          :excode => u.excode.to_s,
          :epcode => u.epcode.to_s,
          :ptcode => u.ptcode.to_s,
          :dcode => u.dcode.to_s,
          :sdcode => u.sdcode.to_s,
          :seccode => u.seccode.to_s,
          :jobcode => u.jobcode.to_s,
          :subdept_show => begin Csubdept.find(u.sdcode).full_shortpre_name rescue "" end,
          :spmny => u.spmny,
          :mincode => u.mincode,
          :deptcode => u.deptcode
      }}
      records[:success] = true
    else
      records[:success] = false
      records[:msg] = "ไม่พบข้อมูล"
    end
    render :text => records.to_json
  end
  
  def process_move_in
    ##ย้ายเลื่อนในตำแหน่งเดิม
    if params[:olded][:posid].to_s == params[:newed][:posid].to_s
        str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
        search = "pisj18.posid = #{params[:olded][:posid]} and pisj18.flagupdate = '1' "
        search += " and pispersonel.pstatus = '1' "
        rs_cn = Pisj18.joins(str_join).count(:all,:conditions => search)
        if rs_cn > 0
          rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
          #ถ้าระดับและเงินเดือนที่แต่งตั้ง มากกว่าระดับและเงินเดือนเดิม
          if params[:newed][:c].to_i > rs_old[0].c.to_i and params[:newed][:salary].to_i > rs_old[0].salary.to_i
            Pisj18.transaction do
              #update pisj18
              str_update = "sdcode = #{to_data_db(params[:newed][:sdcode])},"
              str_update += "dcode = #{to_data_db(params[:newed][:dcode])},"
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "nowc = #{to_data_db(params[:newed][:c])},"
              str_update += "nowsal = #{to_data_db(params[:newed][:salary])},"
              str_update += "posmny = #{to_data_db(params[:newed][:posmny])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])}"
              sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:newed][:posid]}"
              ActiveRecord::Base.connection.execute(sql)
              ###############################################################################
              #update pispersonel
              str_update = "cdate = '#{to_date_db(params[:cmd][:forcedate])}',"
              str_update += "sdcode = #{to_data_db(params[:newed][:sdcode])},"
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])},"
              str_update += "j18code = #{to_data_db(params[:bottom][:j18code])},"
              str_update += "spmny = #{to_data_db(params[:newed][:spmny])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])}"
              sql = "UPDATE pispersonel SET #{str_update} WHERE id = '#{params[:newed][:id]}'"
              ActiveRecord::Base.connection.execute(sql)
              ################################################################################
              #insert pisposhis
              rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
              rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:newed][:id]}'")
              str_insert = "(
                '#{params[:newed][:id]}',
                #{rs_order[0].historder.to_i + 1},
                '#{to_date_db(params[:cmd][:forcedate])}',
                #{to_data_db(params[:newed][:poscode])},
                #{to_data_db(params[:newed][:epcode])},
                #{to_data_db(rs_new[0].mincode)},
                #{to_data_db(rs_new[0].deptcode)},
                #{to_data_db(params[:newed][:sdcode])},
                #{to_data_db(params[:newed][:seccode])},
                #{to_data_db(params[:newed][:jobcode])},
                #{to_data_db(params[:cmd][:updcode])},
                #{to_data_db(params[:newed][:posid])},
                #{to_data_db(params[:newed][:c])},
                #{to_data_db(params[:newed][:salary])},
                #{to_data_db(params[:cmd][:refcmnd])},
                #{to_data_db(params[:cmd][:note])},
                #{to_data_db(params[:newed][:ptcode])}
              )"
              sql = "INSERT INTO pisposhis (id,historder,forcedate,poscode,epcode,mcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,refcmnd,note,ptcode)"
              sql += " VALUES#{str_insert}"
              ActiveRecord::Base.connection.execute(sql)
            end
            #####################
          end
          #######################################################################################################
          #ถ้าระดับและเงินเดือนที่แต่งตั้ง น้อยกว่าระดับและเงินเดือนเดิม
          if params[:newed][:c].to_i < rs_old[0].c.to_i and params[:newed][:salary].to_i < rs_old[0].salary.to_i
            Pisj18.transaction do
              ##UPDATE pisj18
              str_update = "sdcode = #{to_data_db(params[:newed][:sdcode])},"
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
              str_update += "dcode = #{to_data_db(params[:newed][:dcode])},"
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "nowcasb = #{to_data_db(params[:newed][:c])},"
              str_update += "nowsalasb = #{to_data_db(params[:newed][:salary])},"
              str_update += "posmny = #{to_data_db(params[:newed][:posmny])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])}"        
              sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:newed][:posid]}"
              ActiveRecord::Base.connection.execute(sql)
              ###############################################################################
              #update pispersonel
              str_update = "cdate = '#{to_date_db(params[:cmd][:forcedate])}',"
              str_update += "sdcode = #{to_data_db(params[:newed][:sdcode])},"
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])},"
              str_update += "j18code = #{to_data_db(params[:bottom][:j18code])},"
              str_update += "spmny = #{to_data_db(params[:newed][:spmny])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])}"
              sql = "UPDATE pispersonel SET #{str_update} WHERE id = '#{params[:newed][:id]}'"
              ActiveRecord::Base.connection.execute(sql)
              ################################################################################
              #insert pisposhis
              rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
              rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:newed][:id]}'")
              str_insert = "(
                '#{params[:newed][:id]}',
                #{rs_order[0].historder.to_i + 1},
                '#{to_date_db(params[:cmd][:forcedate])}',
                #{to_data_db(params[:newed][:poscode])},
                #{to_data_db(params[:newed][:epcode])},
                #{to_data_db(rs_new[0].mincode)},
                #{to_data_db(rs_new[0].deptcode)},
                #{to_data_db(params[:newed][:sdcode])},
                #{to_data_db(params[:newed][:seccode])},
                #{to_data_db(params[:newed][:jobcode])},
                #{to_data_db(params[:cmd][:updcode])},
                #{to_data_db(params[:newed][:posid])},
                #{to_data_db(params[:newed][:c])},
                #{to_data_db(params[:newed][:salary])},
                #{to_data_db(params[:cmd][:refcmnd])},
                #{to_data_db(params[:cmd][:note])},
                #{to_data_db(params[:newed][:ptcode])}
              )"
              sql = "INSERT INTO pisposhis (id,historder,forcedate,poscode,epcode,mcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,refcmnd,note,ptcode)"
              sql += " VALUES#{str_insert}"
              ActiveRecord::Base.connection.execute(sql)
            end
            #####################
          end
          #######################################################################################################
          #ถ้าระดับเท่าเดิม แต่และเงินเดือนที่แต่งตั้ง มากกว่าเงินเดือนเดิม
          if params[:newed][:c].to_i == rs_old[0].c.to_i and params[:newed][:salary].to_i > rs_old[0].salary.to_i
            Pisj18.transaction do
              if rs_old[0].nowsal.to_i > params[:newed][:salary].to_i
                ##UPDATE pisj18
                str_update = "sdcode = #{to_data_db(params[:newed][:sdcode])},"
                str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
                str_update += "dcode = #{to_data_db(params[:newed][:dcode])},"
                str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
                str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
                str_update += "excode = #{to_data_db(params[:newed][:excode])},"
                str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
                str_update += "posmny = #{to_data_db(params[:newed][:posmny])},"
                str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])},"
                str_update += "nowcasb = #{to_data_db(params[:newed][:c])},"
                str_update += "nowsalasb = #{to_data_db(params[:newed][:salary])},"
                str_update += "c = #{to_data_db(params[:newed][:c])},"
                str_update += "salary = #{to_data_db(params[:newed][:salary])}"
                sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:newed][:posid]}"
                ActiveRecord::Base.connection.execute(sql)
                ###############################################################################
              else
                ##UPDATE pisj18
                str_update = "sdcode = #{to_data_db(params[:newed][:sdcode])},"
                str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
                str_update += "dcode = #{to_data_db(params[:newed][:dcode])},"
                str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
                str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
                str_update += "excode = #{to_data_db(params[:newed][:excode])},"
                str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
                str_update += "posmny = #{to_data_db(params[:newed][:posmny])},"
                str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])},"
                str_update += "c = #{to_data_db(params[:newed][:c])},"
                str_update += "salary = #{to_data_db(params[:newed][:salary])},"
                str_update += "nowc = #{to_data_db(params[:newed][:c])},"
                str_update += "nowsal = #{to_data_db(params[:newed][:salary])},"
                str_update += "nowcasb = null,"
                str_update += "nowsalasb = null"                
                sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:newed][:posid]}"
                ActiveRecord::Base.connection.execute(sql)
                ###############################################################################
              end
              ###############################################################################
              #update pispersonel
              str_update = "cdate = '#{to_date_db(params[:cmd][:forcedate])}',"
              str_update += "sdcode = #{to_data_db(params[:newed][:sdcode])},"
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])},"
              str_update += "j18code = #{to_data_db(params[:bottom][:j18code])},"
              str_update += "spmny = #{to_data_db(params[:newed][:spmny])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])}"
              sql = "UPDATE pispersonel SET #{str_update} WHERE id = '#{params[:newed][:id]}'"
              ActiveRecord::Base.connection.execute(sql)
              ################################################################################
              #insert pisposhis
              rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
              rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:newed][:id]}'")
              str_insert = "(
                '#{params[:newed][:id]}',
                #{rs_order[0].historder.to_i + 1},
                '#{to_date_db(params[:cmd][:forcedate])}',
                #{to_data_db(params[:newed][:poscode])},
                #{to_data_db(params[:newed][:epcode])},
                #{to_data_db(rs_new[0].mincode)},
                #{to_data_db(rs_new[0].deptcode)},
                #{to_data_db(params[:newed][:sdcode])},
                #{to_data_db(params[:newed][:seccode])},
                #{to_data_db(params[:newed][:jobcode])},
                #{to_data_db(params[:cmd][:updcode])},
                #{to_data_db(params[:newed][:posid])},
                #{to_data_db(params[:newed][:c])},
                #{to_data_db(params[:newed][:salary])},
                #{to_data_db(params[:cmd][:refcmnd])},
                #{to_data_db(params[:cmd][:note])},
                #{to_data_db(params[:newed][:ptcode])}
              )"
              sql = "INSERT INTO pisposhis (id,historder,forcedate,poscode,epcode,mcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,refcmnd,note,ptcode)"
              sql += " VALUES#{str_insert}"
              ActiveRecord::Base.connection.execute(sql)
            end
            #####################
          end
          #######################################################################################################
        end
    end
    ##ย้ายเลื่อนในตำแหน่งใหม่
    if params[:olded][:posid].to_s != params[:newed][:posid].to_s
      str_join = " left join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      search = "pisj18.posid = #{params[:olded][:posid]} and pisj18.flagupdate = '1' "
      search += " and pispersonel.pstatus = '1' "
      rs_cn_old = Pisj18.joins(str_join).count(:all,:conditions => search)
      #####################################################################################################
      if rs_cn_old > 0
        #เงื่อนไข = ไม่มี
        if params[:type_action].to_s == "5"
          rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
          rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
          Pisj18.transaction do
            #update  pisj18 ของเลขตำแหน่งที่แต่งตั้ง  set ทุก field  = ข้อมูลตำแหน่งที่แต่งตั้ง
            #id = id ของคนในตำแหน่งเดิม
            val = []
            params[:newed].keys.each {|u|
              if u.to_s != "uppercent" and u.to_s != "upsalary" and u.to_s != "id" and u.to_s != "spmny"
                v = "null"
                v = "'#{params[:newed][u]}'" if params[:newed][u].to_s.strip != ""
                val.push("#{u.to_s} = #{v}")              
              end
            }
            val.push("id = '#{params[:olded][:id]}'")
            Pisj18.update_all(val.join(","),"posid = #{params[:newed][:posid]}")
            
            #Pispersonel.update_all("pstatus = 0,posid=null","posid = #{params[:newed][:posid]} and pstatus = '1'")
            sql = "
              UPDATE pispersonel SET
            "
            if params[:newed][:c].to_i != rs_old[0].c.to_i
                sql += "cdate = '#{to_date_db(params[:cmd][:forcedate])}' ,"
            end
            sql += "
                sdcode = #{to_data_db(params[:newed][:sdcode])},
                seccode = #{to_data_db(params[:newed][:seccode])},
                jobcode = #{to_data_db(params[:newed][:jobcode])},
                poscode = #{to_data_db(params[:newed][:poscode])},
                excode = #{to_data_db(params[:newed][:excode])},
                epcode = #{to_data_db(params[:newed][:epcode])},
                posid = #{to_data_db(params[:newed][:posid])},
                salary = #{to_data_db(params[:newed][:salary])},
                j18code = #{to_data_db(params[:bottom][:j18code])},
                spmny = #{to_data_db(params[:newed][:spmny])},
                c = #{to_data_db(params[:newed][:c])},
                ptcode = #{to_data_db(params[:newed][:ptcode])}
              WHERE id = '#{params[:olded][:id]}'
            "
            ActiveRecord::Base.connection.execute(sql)            
            #########################################################################################################
            #update  pisj18 ของเลขตำแหน่งเดิม  set ให้เป็นตำแหน่งว่าง(id=NULL)
            #emptydate =วันที่มีผลบังคับใช้
            Pisj18.update_all("id = null,emptydate='#{to_date_db(params[:cmd][:forcedate])}'","posid = #{params[:olded][:posid]}")
            #######################################################################################################################
            #insert pisposhis
            rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = '#{params[:olded][:id]}'")
            str_insert = "(
              '#{params[:olded][:id]}',
              #{rs_order[0].historder.to_i + 1},
              '#{to_date_db(params[:cmd][:forcedate])}',
              #{to_data_db(params[:newed][:poscode])},
              #{to_data_db(params[:newed][:epcode])},
              #{to_data_db(rs_new[0].mincode)},
              #{to_data_db(rs_new[0].deptcode)},
              #{to_data_db(params[:newed][:sdcode])},
              #{to_data_db(params[:newed][:seccode])},
              #{to_data_db(params[:newed][:jobcode])},
              #{to_data_db(params[:cmd][:updcode])},
              #{to_data_db(params[:newed][:posid])},
              #{to_data_db(params[:newed][:c])},
              #{to_data_db(params[:newed][:salary])},
              #{to_data_db(params[:cmd][:refcmnd])},
              #{to_data_db(params[:cmd][:note])},
              #{to_data_db(params[:newed][:ptcode])}
            )"                           
            sql = "INSERT INTO pisposhis (id,historder,forcedate,poscode,epcode,mcode,deptcode,sdcode,seccode,jobcode,updcode,posid,c,salary,refcmnd,note,ptcode)"
            sql += " VALUES#{str_insert}"
            ActiveRecord::Base.connection.execute(sql)
            
            ################################################################################
          end
          ####################
        end
        ####################################
        #เงื่อนไข = สับตรง
        if params[:type_action].to_s == "1"
          rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
          rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
          Pisj18.transaction do
            #update  pisj18 ของเลขตำแหน่งที่แต่งตั้ง  set ทุก field  = ข้อมูลตำแหน่งที่แต่งตั้ง
            val = []
            params[:newed].keys.each {|u|
              if u.to_s != "uppercent" and u.to_s != "upsalary" and u.to_s != "id" and u.to_s != "spmny"
                v = "null"
                v = "'#{params[:newed][u]}'" if params[:newed][u].to_s.strip != ""
                val.push("#{u.to_s} = #{v}")              
              end
            }
            Pisj18.update_all(val.join(","),"posid = #{params[:newed][:posid]}")
            ##############################################################################################
            #rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
            #rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
            ###################################################################################################
            str_update = "id = #{to_data_db(rs_old[0].id)},"
            str_update += "sdcode = #{to_data_db(params[:newed][:sdcode])},"
            str_update += "seccode = #{to_data_db(params[:newed][:seccode])},"
            str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])},"
            str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
            str_update += "excode = #{to_data_db(rs_old[0].excode)},"
            str_update += "epcode = #{to_data_db(rs_old[0].epcode)},"
            str_update += "lastc = #{to_data_db(rs_old[0].lastc)},"
            str_update += "lastsal = #{to_data_db(rs_old[0].lastsal)},"
            str_update += "nowc = #{to_data_db(rs_old[0].nowc)},"
            str_update += "nowsal = #{to_data_db(rs_old[0].nowsal)},"
            str_update += "lastcasb = #{to_data_db(rs_old[0].lastcasb)},"
            str_update += "lastsalasb = #{to_data_db(rs_old[0].lastsalasb)},"
            str_update += "nowcasb = #{to_data_db(rs_old[0].nowcasb)},"
            str_update += "nowsalasb = #{to_data_db(rs_old[0].nowsalasb)},"
            str_update += "posmny = #{to_data_db(params[:newed][:posmny])},"
            str_update += "ptcode = #{to_data_db(rs_old[0].ptcode)},"
            str_update += "c = #{to_data_db(rs_old[0].c)},"
            str_update += "salary = #{to_data_db(rs_old[0].salary)}"
            sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:newed][:posid]}"
            ActiveRecord::Base.connection.execute(sql)
            
            ##########################################################################
            str_update = "id = #{to_data_db(params[:newed][:id])},"
            str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
            str_update += "lastc = #{to_data_db(rs_new[0].lastc)},"
            str_update += "lastsal = #{to_data_db(rs_new[0].lastsal)},"
            str_update += "nowc = #{to_data_db(params[:newed][:c])},"
            str_update += "nowsal = #{to_data_db(params[:newed][:salary])},"
            str_update += "lastcasb = #{to_data_db(rs_new[0].lastcasb)},"
            str_update += "lastsalasb = #{to_data_db(rs_new[0].lastsalasb)},"
            str_update += "nowcasb = #{to_data_db(rs_new[0].nowcasb)},"
            str_update += "nowsalasb = #{to_data_db(rs_new[0].nowsalasb)},"
            str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])},"
            if params[:newed][:id].to_s.strip == ""
              str_update += "emptydate = '#{to_date_db(params[:cmd][:forcedate])}',"
            end
            str_update += "c = #{to_data_db(params[:newed][:c])},"
            str_update += "salary = #{to_data_db(params[:newed][:salary])}"
            sql = "UPDATE pisj18 SET #{str_update} WHERE posid = #{params[:olded][:posid]}"
            ActiveRecord::Base.connection.execute(sql)
            
            ##########################################################################
            #update pispersonel
            #rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
            #rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
            if params[:newed][:id].to_s != ""
              str_update = "sdcode = #{to_data_db(rs_old[0].sdcode)},"
              str_update += "seccode = #{to_data_db(rs_old[0].seccode)},"
              str_update += "jobcode = #{to_data_db(rs_old[0].jobcode)},"
              str_update += "poscode = #{to_data_db(rs_old[0].poscode)},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "posid = #{to_data_db(params[:olded][:posid])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])}"
              sql = "UPDATE pispersonel SET #{str_update} WHERE id = #{to_data_db(params[:newed][:id])} "
              ActiveRecord::Base.connection.execute(sql)
              
              #######################################################################################
              rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = #{to_data_db(params[:newed][:id])}")
              str_insert = "
              (
                #{to_data_db(params[:newed][:id])},
                #{rs_order[0].historder.to_i + 1},
                '#{to_date_db(params[:cmd][:forcedate])}',
                #{to_data_db(rs_old[0].poscode)},
                #{to_data_db(rs_old[0].epcode)},
                #{to_data_db(rs_old[0].mincode)},
                #{to_data_db(rs_old[0].deptcode)},
                #{to_data_db(rs_old[0].sdcode)},
                #{to_data_db(rs_old[0].seccode)},
                #{to_data_db(rs_old[0].jobcode)},
                #{to_data_db(params[:cmd][:updcode])},
                #{to_data_db(rs_old[0].posid)},
                #{to_data_db(params[:newed][:c])},
                #{to_data_db(params[:newed][:salary])},
                #{to_data_db(params[:cmd][:refcmnd])},
                #{to_data_db(params[:cmd][:note])},
                #{to_data_db(rs_old[0].ptcode)}
              )
              "
              sql = "INSERT INTO pisposhis ( id, historder, forcedate, poscode, epcode, mcode, deptcode, sdcode, seccode, jobcode, updcode, posid, c, salary, refcmnd, note, ptcode ) VALUES#{str_insert}"
              ActiveRecord::Base.connection.execute(sql)
              
            end
            ##################################################################################
            if params[:olded][:id].to_s != ""
              str_update = "cdate = '#{to_date_db(params[:cmd][:forcedate])}' ,"
              str_update += "sdcode = #{to_data_db(params[:newed][:sdcode])}, "
              str_update += "seccode = #{to_data_db(params[:newed][:seccode])}, "
              str_update += "jobcode = #{to_data_db(params[:newed][:jobcode])}, "
              str_update += "poscode = #{to_data_db(params[:newed][:poscode])},"
              str_update += "excode = #{to_data_db(params[:newed][:excode])},"
              str_update += "epcode = #{to_data_db(params[:newed][:epcode])},"
              str_update += "posid = #{to_data_db(params[:newed][:posid])},"
              str_update += "salary = #{to_data_db(params[:newed][:salary])},"
              str_update += "j18code = #{to_data_db(params[:bottom][:j18code])},"
              str_update += "spmny = #{to_data_db(params[:newed][:spmny])},"
              str_update += "c = #{to_data_db(params[:newed][:c])},"
              str_update += "ptcode = #{to_data_db(params[:newed][:ptcode])}"
              sql = "UPDATE pispersonel SET #{str_update} WHERE id = #{to_data_db(params[:olded][:id])} "
              ActiveRecord::Base.connection.execute(sql)
              
              #######################################################################################
              rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = #{to_data_db(params[:olded][:id])}")
              str_insert = "
                (
                  #{to_data_db(params[:olded][:id])},
                  #{rs_order[0].historder.to_i + 1},
                  '#{to_date_db(params[:cmd][:forcedate])}',
                  #{to_data_db(params[:newed][:poscode])},
                  #{to_data_db(rs_old[0].epcode)},
                  #{to_data_db(rs_new[0].mincode)},
                  #{to_data_db(rs_new[0].deptcode)},
                  #{to_data_db(params[:newed][:sdcode])},
                  #{to_data_db(params[:newed][:seccode])},
                  #{to_data_db(params[:newed][:jobcode])},
                  #{to_data_db(params[:cmd][:updcode])},
                  #{to_data_db(params[:newed][:posid])},
                  #{to_data_db(rs_old[0].c)},
                  #{to_data_db(rs_old[0].salary)},
                  #{to_data_db(params[:cmd][:refcmnd])},
                  #{to_data_db(params[:cmd][:note])},
                  #{to_data_db(rs_old[0].ptcode)}
                )
              "
              sql = "INSERT INTO pisposhis( id, historder, forcedate, poscode, epcode, mcode, deptcode, sdcode, seccode, jobcode, updcode, posid, c, salary, refcmnd, note, ptcode ) VALUES#{str_insert}"
              ActiveRecord::Base.connection.execute(sql)

            end
            ##################################################################################
          end
          #######################
        end
        ######################################################
        #เงื่อนไข = สับเปลี่ยนเงินเดือน
        if params[:type_action].to_s == "2"
          #rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
          #rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
          Pisj18.transaction do
            if [1201,1202,1203,1204,1205,1206,1207,1208].include?(params[:cmd][:updcode].to_i)
              rs_old = Pisj18.find(:all,:conditions => "posid = #{params[:olded][:posid]} and flagupdate = '1' ")
              rs_new = Pisj18.find(:all,:conditions => "posid = #{params[:newed][:posid]} and flagupdate = '1' ")
              Pisj18.transaction do
                sql = "UPDATE pisj18 SET id = NULL WHERE posid = #{params[:olded][:posid]}"
                ActiveRecord::Base.connection.execute(sql)
                #########################################################################
                sql = "
                UPDATE pisj18 SET
                  id = #{to_data_db(params[:olded][:id])},
                  sdcode = #{to_data_db(params[:newed][:sdcode])},
                  seccode = #{to_data_db(params[:newed][:seccode])},
                  jobcode = #{to_data_db(params[:newed][:jobcode])},
                  poscode = #{to_data_db(params[:newed][:poscode])},
                  excode = #{to_data_db(params[:newed][:excode])},
                  epcode = #{to_data_db(params[:newed][:epcode])},
                  lastc = #{to_data_db(rs_old[0].lastc)},
                  lastsal = #{to_data_db(rs_old[0].lastsal)},
                  nowc = #{to_data_db(params[:newed][:c])},
                  nowsal = #{to_data_db(params[:newed][:salary])},
                  lastcasb = #{to_data_db(rs_old[0].lastcasb)},
                  lastsalasb = #{to_data_db(rs_old[0].lastsalasb)},
                  nowcasb = #{to_data_db(rs_old[0].nowcasb)},
                  nowsalasb = #{to_data_db(rs_old[0].nowsalasb)},
                  posmny = #{to_data_db(params[:newed][:posmny])},
                  ptcode = #{to_data_db(params[:newed][:ptcode])},
                  c = #{to_data_db(params[:newed][:c])},
                  salary = #{to_data_db(params[:newed][:salary])}
                WHERE posid = #{params[:newed][:posid]} 
                "
                ActiveRecord::Base.connection.execute(sql)
                
                #########################################################################
                if params[:newed][:id].to_s != ""
                  sql = "UPDATE pispersonel SET posid = NULL WHERE id = #{to_data_db(params[:newed][:id])} "              
                  ActiveRecord::Base.connection.execute(sql)
                end
                #########################################################################
                sql = "
                UPDATE pispersonel SET
                  cdate = '#{to_date_db(params[:cmd][:forcedate])}' ,
                  sdcode = #{to_data_db(params[:newed][:sdcode])},
                  seccode = #{to_data_db(params[:newed][:seccode])},
                  jobcode = #{to_data_db(params[:newed][:jobcode])},
                  poscode = #{to_data_db(params[:newed][:poscode])},
                  excode = #{to_data_db(params[:newed][:excode])},
                  epcode = #{to_data_db(params[:newed][:epcode])},
                  posid = #{to_data_db(params[:newed][:posid])},
                  salary = #{to_data_db(params[:newed][:salary])},
                  j18code = #{to_data_db(params[:bottom][:j18code])},
                  spmny = #{to_data_db(params[:newed][:spmny])},
                  c = #{to_data_db(params[:newed][:c])},
                  ptcode = #{to_data_db(params[:newed][:ptcode])}
                WHERE id = #{to_data_db(params[:olded][:id])} 
                "
                ActiveRecord::Base.connection.execute(sql)
                
                #########################################################################
                rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = #{to_data_db(params[:olded][:id])}")
                sql = "
                INSERT INTO pisposhis ( id, historder, forcedate, poscode, excode, epcode, mcode, deptcode, sdcode, seccode, jobcode, updcode, posid, c, salary, refcmnd, note, ptcode ) VALUES
                (
                  #{to_data_db(params[:olded][:id])},
                  #{rs_order[0].historder.to_i + 1},
                  '#{to_date_db(params[:cmd][:forcedate])}' ,
                  #{to_data_db(params[:newed][:poscode])},
                  #{to_data_db(params[:newed][:excode])},
                  #{to_data_db(rs_old[0].epcode)},
                  #{to_data_db(rs_new[0].mincode)},
                  #{to_data_db(rs_new[0].deptcode)},
                  #{to_data_db(params[:newed][:sdcode])},
                  #{to_data_db(params[:newed][:seccode])},
                  #{to_data_db(params[:newed][:jobcode])},
                  #{to_data_db(params[:cmd][:updcode])},
                  #{to_data_db(params[:newed][:posid])},
                  #{to_data_db(rs_old[0].c)},
                  #{to_data_db(rs_old[0].salary)},
                  #{to_data_db(params[:cmd][:refcmnd])},
                  #{to_data_db(params[:cmd][:note])},
                  #{to_data_db(rs_old[0].ptcode)}
                )
                "
                ActiveRecord::Base.connection.execute(sql)
                
                #########################################################################
                rs_order = Pisposhis.select("max(historder) as historder").find(:all,:conditions => "id = #{to_data_db(params[:newed][:id])}")
                sql = "
                INSERT INTO pisposhis ( id, historder, forcedate, poscode, excode, epcode, mcode, deptcode, sdcode, seccode, jobcode, updcode, posid, c, salary, refcmnd, note, ptcode ) VALUES
                (
                  #{to_data_db(params[:newed][:id])},
                  #{rs_order[0].historder.to_i + 1},
                  '#{to_date_db(params[:cmd][:forcedate])}' ,
                  #{to_data_db(rs_old[0].poscode)},
                  #{to_data_db(rs_old[0].excode)},
                  #{to_data_db(rs_old[0].epcode)},
                  #{to_data_db(rs_old[0].mincode)},
                  #{to_data_db(rs_old[0].deptcode)},
                  #{to_data_db(rs_old[0].sdcode)},
                  #{to_data_db(rs_old[0].seccode)},
                  #{to_data_db(rs_old[0].jobcode)},
                  #{to_data_db(params[:cmd][:updcode])},
                  #{to_data_db(rs_old[0].posid)},
                  #{to_data_db(params[:newed][:c])},
                  #{to_data_db(params[:newed][:salary])},
                  #{to_data_db(params[:cmd][:refcmnd])},
                  #{to_data_db(params[:cmd][:note])},
                  #{to_data_db(rs_old[0].ptcode)}
                )
                "
                ActiveRecord::Base.connection.execute(sql)
                
                #########################################################################
              end
            end
          end
        end
        ###################################
      end
      ###################
    end
    ##############################################################
    render :text => "{ success: true }"
  end
    
end
