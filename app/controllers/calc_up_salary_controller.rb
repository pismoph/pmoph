# coding: utf-8
class CalcUpSalaryController < ApplicationController
  before_filter :login_menu_command
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  def check_count
    year = params[:fiscal_year].to_s + params[:round]
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    sql_j18 = "select t_incsalary.posid from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_personel = "select t_incsalary.posid from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql = "select count(*) as n from ((#{sql_j18}) union (#{sql_personel})) as pis"
    sql = "select count(*) as n from (#{sql_j18}) as pis"
    cn = TIncsalary.find_by_sql(sql)[0].n
    render :text => {:cn => cn}.to_json, :layout => false  
  end
  
  def add
    begin
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
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
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
      end
      column = "pisj18.posid,pisj18.poscode,pisj18.c as level,pisj18.salary"
      column += ",pisj18.sdcode,pisj18.seccode,pisj18.jobcode,pisj18.excode"
      column += ",pisj18.epcode,pispersonel.ptcode,pisj18.subdcode,pisj18.dcode"
      column += ",pispersonel.fname,pispersonel.lname,pispersonel.pcode"  
      column += ",pispersonel.dcode as wdcode,pispersonel.sdcode as wsdcode"
      column += ",pispersonel.seccode as wseccode,pispersonel.jobcode as wjobcode"
      column += ",pispersonel.subdcode as wsubdcode,pispersonel.j18code,pispersonel.id"
      column += ",'1' as flagcal,'N' as flag_inc"      
      sql_j18 = "select #{column} from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select #{column} from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      rs = Pisj18.find_by_sql(sql)
      #เก็บ ค่า c ลง Array
      arr_c = []
      sql_j18 = "select distinct pisj18.c from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pisj18.c from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_c = Pisj18.find_by_sql(sql).collect{|u| u.c }
      rs_c = Cgrouplevel.select("ccode,minsal1,maxsal1,minsal2,maxsal2,baselow,basehigh,spmin1,spmax1,spmin2,spmax2,spbase1,spbase2").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      #เก็บ ค่า ต่ำแหน่งพิเศษ
      arr_sp = []
      rs_sp = Cposspsal.where("use_status = '1'")
      for i in 0...rs_sp.length
        arr_sp.push([rs_sp[i].poscode.to_i,rs_sp[i].c.to_i])
      end
      #เก็บค่า order ลง Array j18
      arr_order = []
      sql_j18 = "select distinct pisj18.seccode,pisj18.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pisj18.seccode,pisj18.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_wp = Pisj18.find_by_sql(sql).collect{|u| [u.seccode.to_i,u.jobcode.to_i] }
      for i in 0...d_wp.length
        if @current_user.group_user.type_group.to_s == "1"
          rs_tmp = Corderrpt.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        end
        if @current_user.group_user.type_group.to_s == "2"
          rs_tmp = Corderssj.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        end
        if rs_tmp.length > 0
          arr_order.push({
            :sorder => rs_tmp[0].sorder,
            :seccode => rs_tmp[0].seccode,
            :jobcode => rs_tmp[0].jobcode
          })
        else
          arr_order.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })           
        end
      end     
      #เก็บค่า order ลง Array ปฏิบัติงานจริง
      arr_orderwp = []
      sql_j18 = "select distinct pispersonel.seccode,pispersonel.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pispersonel.seccode,pispersonel.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_wp2 = Pisj18.find_by_sql(sql).collect{|u| [u.seccode.to_i,u.jobcode.to_i] } 
      for i in 0...d_wp2.length
        if @current_user.group_user.type_group.to_s == "1"
          rs_tmp2 = Corderrpt.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        end
        if @current_user.group_user.type_group.to_s == "2"
          rs_tmp2 = Corderssj.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        end
        if rs_tmp2.length > 0
          arr_orderwp.push({
            :sorder => rs_tmp2[0].sorder,
            :seccode => rs_tmp2[0].seccode,
            :jobcode => rs_tmp2[0].jobcode
          })
        else
          arr_orderwp.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })          
        end
      end
      
      #insert table
      vals = []
      rs.each do |v|
        idx_order = d_wp.index( [v.seccode.to_i,v.jobcode.to_i])
        idx_orderwp = d_wp2.index( [v.wseccode.to_i,v.wjobcode.to_i])
        idx_c = arr_c.index(v.level.to_i)
        idx_sp = arr_sp.index([v.poscode.to_i,v.level.to_i])
        midpoint = 0
        maxsalary  = 0
        note1 = "null"
        if !idx_c.nil?
          if !idx_sp.nil?
            case v.salary.to_f
              when rs_c[idx_c].spmin2.to_f..rs_c[idx_c].spmax2.to_f
                midpoint = rs_c[idx_c].spbase2
                maxsalary  = rs_c[idx_c].spmax2            
              when rs_c[idx_c].spmin1.to_f..rs_c[idx_c].spmax1.to_f
                midpoint = rs_c[idx_c].spbase1
                maxsalary  = rs_c[idx_c].spmax1 
            end
          else
            case v.salary.to_f
              when rs_c[idx_c].minsal2.to_f..rs_c[idx_c].maxsal2.to_f
                midpoint = rs_c[idx_c].basehigh
                maxsalary  = rs_c[idx_c].maxsal2            
              when rs_c[idx_c].minsal1.to_f..rs_c[idx_c].maxsal1.to_f
                midpoint = rs_c[idx_c].baselow
                maxsalary  = rs_c[idx_c].maxsal1
            end
          end
        end
        val = "('#{params[:fiscal_year].to_s + params[:round].to_s}'"
        val += ",'#{v.id}','#{v.posid}','#{v.poscode}','#{v.level}','#{v.salary}','#{v.sdcode}'"
        val += ",'#{(v.seccode.to_s == "")? 0 : v.seccode}','#{(v.jobcode.to_s == "")? 0 : v.jobcode}'"
        val += ",'#{v.excode}','#{v.fname}','#{v.lname}','#{v.pcode}','#{v.epcode}'"
        val += ",'#{v.ptcode}','#{v.flag_inc}','#{v.subdcode}','#{v.dcode}','#{v.wdcode}','#{v.wsdcode}'"
        val += ",'#{(v.wseccode.to_s == "")? 0 : v.wseccode}','#{(v.wjobcode.to_s == "")? 0 : v.wjobcode}'"
        val += ",'#{v.wsubdcode}','#{v.j18code}','#{v.flagcal}','#{midpoint}','#{maxsalary}'"
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}'"
        if maxsalary.to_i == v.salary.to_i
          note1 = "'เต็มขั้น'"
        end
        val += ",#{note1})"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order,note1"
      if vals.length > 0
        QueryPis.insert_mass("t_incsalary",col,vals)
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
    #########################################################################
  end
  
  def update
    begin
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
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
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
      end
      column = "pisj18.posid,pisj18.poscode,pisj18.c as level,pisj18.salary"
      column += ",pisj18.sdcode,pisj18.seccode,pisj18.jobcode,pisj18.excode"
      column += ",pisj18.epcode,pispersonel.ptcode,pisj18.subdcode,pisj18.dcode"
      column += ",pispersonel.fname,pispersonel.lname,pispersonel.pcode"  
      column += ",pispersonel.dcode as wdcode,pispersonel.sdcode as wsdcode"
      column += ",pispersonel.seccode as wseccode,pispersonel.jobcode as wjobcode"
      column += ",pispersonel.subdcode as wsubdcode,pispersonel.j18code,pispersonel.id"
      column += ",'1' as flagcal,'N' as flag_inc"      
      sql_j18 = "select #{column} from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select #{column} from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      rs = Pisj18.find_by_sql(sql)
      #เก็บ ค่า c ลง Array
      arr_c = []
      sql_j18 = "select distinct pisj18.c from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pisj18.c from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_c = Pisj18.find_by_sql(sql).collect{|u| u.c }
      rs_c = Cgrouplevel.select("ccode,minsal1,maxsal1,minsal2,maxsal2,baselow,basehigh,spmin1,spmax1,spmin2,spmax2,spbase1,spbase2").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      #เก็บค่า order ลง Array j18
      arr_order = []
      sql_j18 = "select distinct pisj18.seccode,pisj18.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pisj18.seccode,pisj18.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_wp = Pisj18.find_by_sql(sql).collect{|u| [u.seccode.to_i,u.jobcode.to_i] }
      for i in 0...d_wp.length
        if @current_user.group_user.type_group.to_s == "1"
          rs_tmp = Corderrpt.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        end
        if @current_user.group_user.type_group.to_s == "2"
          rs_tmp = Corderssj.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        end
        if rs_tmp.length > 0
          arr_order.push({
            :sorder => rs_tmp[0].sorder,
            :seccode => rs_tmp[0].seccode,
            :jobcode => rs_tmp[0].jobcode
          })
        else
          arr_order.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })           
        end
      end     
      #เก็บค่า order ลง Array ปฏิบัติงานจริง
      arr_orderwp = []
      sql_j18 = "select distinct pispersonel.seccode,pispersonel.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search}"
      sql_person = "select distinct pispersonel.seccode,pispersonel.jobcode from pisj18 #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search}"
      sql = "(#{sql_j18}) union (#{sql_person})"
      sql = sql_j18
      d_wp2 = Pisj18.find_by_sql(sql).collect{|u| [u.seccode.to_i,u.jobcode.to_i] } 
      for i in 0...d_wp2.length
        if @current_user.group_user.type_group.to_s == "1"
          rs_tmp2 = Corderrpt.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        end
        if @current_user.group_user.type_group.to_s == "2"
          rs_tmp2 = Corderssj.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        end
        if rs_tmp2.length > 0
          arr_orderwp.push({
            :sorder => rs_tmp2[0].sorder,
            :seccode => rs_tmp2[0].seccode,
            :jobcode => rs_tmp2[0].jobcode
          })
        else
          arr_orderwp.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })          
        end
      end
      #เก็บ ค่า ต่ำแหน่งพิเศษ
      arr_sp = []
      rs_sp = Cposspsal.where("use_status = '1'")
      for i in 0...rs_sp.length
        arr_sp.push([rs_sp[i].poscode.to_i,rs_sp[i].c.to_i])
      end
      #insert table
      vals = []
      rs.each do |v|
        idx_order = d_wp.index( [v.seccode.to_i,v.jobcode.to_i])
        idx_orderwp = d_wp2.index( [v.wseccode.to_i,v.wjobcode.to_i])
        idx_c = arr_c.index(v.level.to_i)
        idx_sp = arr_sp.index([v.poscode.to_i,v.level.to_i])
        midpoint = 0
        maxsalary  = 0
        note1 = "null"
        if !idx_c.nil?
          if !idx_sp.nil?
            case v.salary.to_f
              when rs_c[idx_c].spmin2.to_f..rs_c[idx_c].spmax2.to_f
                midpoint = rs_c[idx_c].spbase2
                maxsalary  = rs_c[idx_c].spmax2            
              when rs_c[idx_c].spmin1.to_f..rs_c[idx_c].spmax1.to_f
                midpoint = rs_c[idx_c].spbase1
                maxsalary  = rs_c[idx_c].spmax1 
            end
          else
            case v.salary.to_f
              when rs_c[idx_c].minsal2.to_f..rs_c[idx_c].maxsal2.to_f
                midpoint = rs_c[idx_c].basehigh
                maxsalary  = rs_c[idx_c].maxsal2            
              when rs_c[idx_c].minsal1.to_f..rs_c[idx_c].maxsal1.to_f
                midpoint = rs_c[idx_c].baselow
                maxsalary  = rs_c[idx_c].maxsal1
            end
          end
        end
        val = "('#{params[:fiscal_year].to_s + params[:round].to_s}'"
        val += ",'#{v.id}','#{v.posid}','#{v.poscode}','#{v.level}','#{v.salary}','#{v.sdcode}'"
        val += ",'#{(v.seccode.to_s == "")? 0 : v.seccode}','#{(v.jobcode.to_s == "")? 0 : v.jobcode}'"
        val += ",'#{v.excode}','#{v.fname}','#{v.lname}','#{v.pcode}','#{v.epcode}'"
        val += ",'#{v.ptcode}','#{v.flag_inc}','#{v.subdcode}','#{v.dcode}','#{v.wdcode}','#{v.wsdcode}'"
        val += ",'#{(v.wseccode.to_s == "")? 0 : v.wseccode}','#{(v.wjobcode.to_s == "")? 0 : v.wjobcode}'"
        val += ",'#{v.wsubdcode}','#{v.j18code}','#{v.flagcal}','#{midpoint}','#{maxsalary}'"
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}'"
        if maxsalary.to_i == v.salary.to_i
          note1 = "'เต็มขั้น'"
        end
        val += ",#{note1})"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order,note1"
      if vals.length > 0
        TIncsalary.transaction do
          search_del = "year = '#{params[:fiscal_year].to_s + params[:round].to_s}' "
          if @current_user.group_user.type_group.to_s == "1"
            @user_work_place.each do |key,val|
              if key.to_s != "mcode" and key.to_s != "deptcode"
                search_del += " and t_incsalary.#{key} = '#{val}' " 
              end
            end
          end
          if @current_user.group_user.type_group.to_s == "2"
            sd_delete = Csubdept.find(:all, :conditions => "provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) ").collect{|u| u.sdcode}
            if sd_delete.length != 0
              search_del += " and ( sdcode in (#{sd_delete.join(",")}) or wsdcode in (#{sd_delete.join(",")}) ) "
            end
          end
          if search_del != "year = '#{params[:fiscal_year].to_s + params[:round].to_s}' "
            TIncsalary.delete_all(search_del)
            QueryPis.insert_mass("t_incsalary",col,vals) 
          end
        end        
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
    #########################################################################
  end
  
  
  def read
    year = params[:fiscal_year].to_s + params[:round]
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    str_join = "left join csubdept on t_incsalary.sdcode = csubdept.sdcode"
    ##เก็บ c ลง array
    arr_c = []
    sql_j18 = "select distinct level from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select distinct level from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql = "(#{sql_j18}) union (#{sql_person})"
    d_c = TIncsalary.find_by_sql(sql).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    ##เก็บ j18status ลง array
    arr_j18 = []
    sql_j18 = "select distinct j18code from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select distinct j18code from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql = "(#{sql_j18}) union (#{sql_person})"
    d_j18 = TIncsalary.find_by_sql(sql).collect{|u| u.j18code }
    rs_j18 = Cj18status.select("j18code,j18status").where(:j18code => d_j18)
    for i in 0...rs_j18.length
      arr_j18.push(rs_j18[i].j18code.to_i)
    end
    
    ##เก็บ prefix ลง array
    arr_prefix = []
    sql_prefix1 = "select distinct pcode from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_prefix2 = "select distinct pcode from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql = "(#{sql_prefix1}) union (#{sql_prefix2})"
    d_prefix = TIncsalary.find_by_sql(sql).collect{|u| u.pcode }
    rs_prefix = Cprefix.select("pcode,prefix").where(:pcode => d_prefix)
    for i in 0...rs_prefix.length
      arr_prefix.push(rs_prefix[i].pcode.to_i)
    end
    
    
    sql_j18 = "select * from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search} order by t_incsalary.posid"
    sql_person = "select * from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search} order by t_incsalary.posid"
    sql = "(#{sql_j18}) union (#{sql_person})"
    sql = sql_j18
    rs = TIncsalary.find_by_sql(sql)
    return_data = {}
    return_data[:totalCount] = TIncsalary.joins(str_join).count(:all,:conditions => search)
    return_data[:records]   = rs.collect{|u|
      idx_c = arr_c.index(u.level.to_i)
      idx_j18 = arr_j18.index(u.j18code.to_i)
      idx_prefix = arr_prefix.index(u.pcode.to_i)
      {
        :posid => u.posid,
        :fname => "#{begin rs_prefix[idx_prefix].prefix rescue "" end}#{u.fname}",
        :lname => u.lname,
        :cname => begin rs_c[idx_c].cname rescue "" end,
        :salary => number_with_delimiter(u.salary.to_i),
        :j18status => begin rs_j18[idx_j18].j18status rescue "" end,
        :note1 => u.note1,
        :flagcal => (u.flagcal == '1') ? true : false,
        :midpoint => number_with_delimiter(u.midpoint.to_i),
        :year => u.year,
        :id => u.id
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def update_table
    begin
     data = ActiveSupport::JSON.decode(params[:data])
     TIncsalary.transaction do
      data.each do |v|
        sql = "update t_incsalary set note1='#{v["note1"]}',flagcal=#{(v["flagcal"] == true)? 1 : 0} "
        #sql += " where year = #{v["year"]} and id = '#{v["id"]}' and sdcode = #{@user_work_place[:sdcode]}"
        sql += " where year = #{v["year"]} and id = '#{v["id"]}' "
        ActiveRecord::Base.connection.execute(sql)
      end       
     end
     render :text => "{success: true}"
    rescue
      render :text => "{success: false}"  
    end
  end
  
  def get_config
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search = " year = #{year} and sdcode = #{@user_work_place[:sdcode]} "
      return_data = {}
      return_data[:totalCount] = TKs24usemain.count(:all,:conditions => search)
      if return_data[:totalCount] > 0
        rs = TKs24usemain.find(:all,:conditions => search).first
        return_data[:data]   = {
          :salary => rs.salary,
          :calpercent => rs.calpercent,
          :ks24 => rs.ks24
        }
      end
      return_data[:success] = true
      render :text => return_data.to_json,:layout => false
    rescue
      render :text => "{success: false}"  
    end
  end
  
  def update_t_ks24usemain
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} "
    @user_work_place.each do |key,val|
      if key.to_s == "sdcode"
        search += " and #{key} = '#{val}' " 
      end
    end
    cn = TKs24usemain.count(:all,:conditions => search)
    if cn == 0
      rs = TKs24usemain.new(params[:config_cal])
      rs.year = year
      rs.sdcode = @user_work_place[:sdcode]
      if rs.save
        render :text => "{success:true}"
      else
        render :text => "{success:false,msg:'กรุณาลองใหม่อีกครั้ง'}"
      end
    else
      if TKs24usemain.update_all(params[:config_cal],search)
        render :text => "{success:true}"
      else
        render :text => "{success:false,msg:'กรุณาลองใหม่อีกครั้ง'}"
      end
    end
    
  end
  
  def reportj18
    prefix_hospital_check = [2,3,4,5,6,7,8,9,11,12,13,14,15]
    prefix_province_check = [16,17,18]
    @records = []
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    total_n = 0
    total_sal = 0
    row_n = 0
    ################################################รพศ/รพท
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderrpt on COALESCE(t_incsalary.seccode,0) = corderrpt.seccode and COALESCE(t_incsalary.jobcode,0) = corderrpt.jobcode "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and csubdept.provcode = '#{@current_user.group_user.provcode}'  and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9) and t_incsalary.j18code in (1,2,3,4,5,6) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderrpt.seccode as odsec,corderrpt.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,corderrpt.sorder,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level,t_incsalary.posid")    
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        records1.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records1.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    ################################################สสจ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode and corderssj.sdtype = 1"
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and csubdept.provcode = '#{@current_user.group_user.provcode}'  and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    search += " and csubdept.sdtcode in (10) and t_incsalary.j18code in (1,2,3,4,5,6) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,corderssj.sorder,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level,t_incsalary.posid")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        records2.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s 
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s 
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records2.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    
    ################################################ รพช
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode and corderssj.sdtype = 2"
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and csubdept.provcode = '#{@current_user.group_user.provcode}'  and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    search += " and csubdept.sdtcode in (11,12,13,14,15) and t_incsalary.j18code in (1,2,3,4,5,6) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,corderssj.sorder,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level,t_incsalary.posid")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })
        end
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s 
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s 
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        
        if rs[i].provcode.to_s != rs[i - 1].provcode
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
            })
          end
        end
        
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records3.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0  
        end
        if rs[i].sdcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0  
        end
      end
    end

    ################################################สสอ  สอ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.sdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.jobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.seccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    #str_join += " left join corderssj on COALESCE(t_incsalary.seccode,0) = corderssj.seccode and COALESCE(t_incsalary.jobcode,0) = corderssj.jobcode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.sdcode = #{@user_work_place[:sdcode]}  "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and csubdept.provcode = '#{@current_user.group_user.provcode}'  and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
    end
    search += " and csubdept.sdtcode in (16,17,18) and t_incsalary.j18code in (1,2,3,4,5,6) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.sdcode,t_incsalary.seccode,t_incsalary.jobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,COALESCE(t_incsalary.seccode,0) as odsec,COALESCE(t_incsalary.jobcode,0) as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.sdcode,cprovince.provcode,t_incsalary.posid,t_incsalary.seccode,t_incsalary.jobcode,t_incsalary.level,t_incsalary.posid")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })
        end
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s 
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s 
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        
        if rs[i].provcode.to_s != rs[i - 1].provcode
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
            })
          end
        end
        
        if rs[i].sdcode.to_s != rs[i - 1].sdcode.to_s          
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].sdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].seccode.to_s != rs[i - 1].seccode.to_s and rs[i].seccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].jobcode.to_s != rs[i - 1].jobcode.to_s and rs[i].jobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].seccode.to_s == rs[i - 1].seccode.to_s 
            
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records4.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].jobcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].seccode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].sdcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    
    order_arr = [
      [2,3,4,5,6,7,8,9],
      [10],
      [11,12,13,14,15],
      [16,17,18]
    ]
    order_check = ""
    rs = Csubdept.find(@user_work_place[:sdcode])
    
    for i in 0...order_arr.length
      if order_arr[i].include?(rs.sdtcode.to_i)
        order_check = i + 1
      end
    end
    
    case order_check
      when 1
        @records += records1
      when 2
        @records += records2
      when 3
        @records += records3
      when 4
        @records += records4
    end
    
      
    if order_check != 1
      @records += records1
    end
    
    if order_check != 2
      @records += records2
    end
    
    if order_check != 3
      @records += records3
    end
    
    if order_check != 4
      @records += records4
    end
    
    @records.push({   
      :i => "",
      :posid => "รวมเงิน",
      :name => "รวมทั้งหมด = #{number_with_delimiter(total_n.to_i.ceil)}" ,
      :salary => "#{number_with_delimiter(total_sal.to_i.ceil)}",
      :clname => "",
      :gname => "",
      :posname => "",
    })
    prawnto :prawn => {
        :top_margin => 120,
        :left_margin => 10,
        :right_margin => 10
    }
  end

  
  def reportwork
    prefix_hospital_check = [2,3,4,5,6,7,8,9,11,12,13,14,15]
    prefix_province_check = [16,17,18]
    @records = []
    @year = params[:year]
    year = params[:year]
    records1 = []
    records2 = []
    records3 = []
    records4 = []
    records5 = []
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    total_n = 0
    total_sal = 0
    row_n = 0
    ####################################################
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and t_incsalary.sdcode = #{@user_work_place[:sdcode]} and wsdcode is not null"
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) and wsdcode is not null"
    end
    sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search}"
    sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search}"
    sql_id = "(#{sql_j18}) union (#{sql_person})"
    sql_id =  sql_j18
    
    ################################################รพศ/รพท
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderrpt on COALESCE(t_incsalary.wseccode,0) = corderrpt.seccode and COALESCE(t_incsalary.wjobcode,0) = corderrpt.jobcode "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null"
    end
    
    search += " and csubdept.sdtcode in (2,3,4,5,6,7,8,9)"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname,cgrouplevel.ccode "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderrpt.seccode as odsec,corderrpt.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,corderrpt.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        records1.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records1.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records1.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records1.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != "0"
          records1.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    ################################################สสจ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode and corderssj.sdtype = 1"
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id})  and wsdcode is not null"
    end
    search += " and csubdept.sdtcode in (10) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        records2.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s 
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s 
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{"#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records2.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records2.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records2.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != "0"
          records2.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    
    ################################################ รพช
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode and corderssj.sdtype = 2"
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id})  and wsdcode is not null"
    end
    search += " and csubdept.sdtcode in (11,12,13,14,15) "
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,corderssj.seccode as odsec,corderssj.jobcode as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,corderssj.sorder,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })
        end
        records3.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else

        
        
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s 
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s 
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        
        if rs[i].provcode.to_s != rs[i - 1].provcode
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
            })
          end
        end
        
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records3.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records3.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records3.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0  
        end
        if rs[i].wsdcode.to_s != "0"
          records3.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0  
        end
      end
    end

    ################################################สสอ  สอ
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    #str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null"
    end
    search += " and csubdept.sdtcode in (16,17,18)"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,COALESCE(t_incsalary.wseccode,0) as odsec,COALESCE(t_incsalary.wjobcode,0) as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,t_incsalary.posid,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0
        if prefix_province_check.include?(rs[i].sdtcode.to_i)
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
          })
        end
        
        records4.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else

        
        
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s 
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s 
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end

        if rs[i].provcode.to_s != rs[i - 1].provcode
          if prefix_province_check.include?(rs[i].sdtcode.to_i)
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "#{rs[i].provpre}#{rs[i].provname}".strip,
            })
          end
        end
        
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{long_title_head_subdept(rs[i].wsdcode)}#{"<br />#{subdeptname}" if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records4.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records4.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records4.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != "0"
          records4.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    ################################################ sdtcode > 18
    sd_n = 0
    sec_n = 0
    job_n = 0
    sd_sal = 0
    sec_sal = 0
    job_sal = 0
    ################################################
    
    str_join = " left join pispersonel on t_incsalary.id = pispersonel.id "
    str_join += " left join csubdept on t_incsalary.wsdcode = csubdept.sdcode "
    str_join += " left join cprovince on csubdept.provcode = cprovince.provcode"
    str_join += " left join camphur on csubdept.amcode = camphur.amcode and csubdept.provcode = camphur.provcode  "
    str_join += " left join cjob on t_incsalary.wjobcode = cjob.jobcode "
    str_join += " left join cprefix on  t_incsalary.pcode = cprefix.pcode"
    str_join += " left join cgrouplevel on t_incsalary.level = cgrouplevel.ccode"
    str_join += " left join csection on t_incsalary.wseccode = csection.seccode "
    str_join += " left join cposition on t_incsalary.poscode = cposition.poscode "
    str_join += " left join cexpert on t_incsalary.epcode = cexpert.epcode "
    str_join += " left join cexecutive on t_incsalary.excode = cexecutive.excode "
    #str_join += " left join corderssj on COALESCE(t_incsalary.wseccode,0) = corderssj.seccode and COALESCE(t_incsalary.wjobcode,0) = corderssj.jobcode "
    if @current_user.group_user.type_group.to_s == "1"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null "
    end
    if @current_user.group_user.type_group.to_s == "2"
      search = " year = #{year} and flagcal = '1' and t_incsalary.id in (#{sql_id}) and wsdcode is not null"
    end
    search += " and csubdept.sdtcode > 18"
    select = " pispersonel.pid,t_incsalary.*,csubdept.sdtcode,csubdept.longpre as subdeptpre,csubdept.subdeptname ,cjob.jobname "
    select += " ,cprefix.prefix,cgrouplevel.cname,cgrouplevel.clname,cgrouplevel.gname "
    select += " ,csection.shortname as secshort,csection.secname"
    select += " ,cposition.shortpre  as pospre,cposition.posname,t_incsalary.wsdcode,t_incsalary.wseccode,t_incsalary.wjobcode"
    select += " ,cprovince.longpre as provpre,cprovince.provname,cprovince.provcode"
    select += " ,camphur.longpre as ampre,camphur.amname"
    select += " ,COALESCE(t_incsalary.wseccode,0) as odsec,COALESCE(t_incsalary.wjobcode,0) as odjob"
    select += " ,cexecutive.shortpre as expre,cexecutive.exname"
    select += " ,cexpert.prename as eppre,cexpert.expert"
    rs = TIncsalary.select(select).joins(str_join).find(:all,:conditions => search,:order => "t_incsalary.wsdcode,cprovince.provcode,t_incsalary.posid,t_incsalary.wseccode,t_incsalary.wjobcode,t_incsalary.level")
    for i in 0...rs.length
      subdeptpre1 = (prefix_hospital_check.include?(rs[i].sdtcode.to_i))? "โรงพยาบาล" : rs[i].subdeptpre
      subdeptpre2 = (prefix_hospital_check.include?(rs[i - 1].sdtcode.to_i))? "โรงพยาบาล" : rs[i - 1].subdeptpre
      row_n += 1
      subdeptname = "#{subdeptpre1}#{rs[i].subdeptname}".strip
      secname = "#{rs[i].secshort}#{rs[i].secname}".strip
      jobname = ""
      jobname = "งาน#{rs[i].jobname}".strip if rs[i].jobname.to_s != ""
      pos = ""
      if rs[i].exname.to_s == ""
          pos = "#{rs[i].pospre}#{rs[i].posname}"
          pos += "<br />(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
      else
          pos = "#{rs[i].expre}#{rs[i].exname}"
          pos += "<br />(#{rs[i].pospre}#{rs[i].posname}"
          pos += "(#{rs[i].eppre}#{rs[i].expert})" if rs[i].expert.to_s != ""
          pos += ")"
      end
      full_name = "#{["#{rs[i].prefix}#{rs[i].fname}",rs[i].lname].join(" ").strip}<br />#{format_pid rs[i].pid}"
      if i == 0        
        records5.push({   
          :i => "",
          :posid => "",
          :name => "" ,
          :salary => "",
          :clname => "",
          :gname => "",
          :posname => "<u>#{subdeptname if subdeptname != ""}#{"<br />#{secname}" if secname != ""}#{"<br />#{jobname}" if jobname != ""}</u>",
        })
      else

        
        
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s 
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม งาน#{"#{rs[i - 1].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s 
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i - 1].secshort}#{rs[i - 1].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre2}#{rs[i - 1].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        
        if rs[i].wsdcode.to_s != rs[i - 1].wsdcode.to_s          
          records5.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{subdeptname if subdeptname != ""}</u>",
          })          
        end
        if rs[i].wseccode.to_s != rs[i - 1].wseccode.to_s and rs[i].wseccode.to_s != ""
          records5.push({   
            :i => "",
            :posid => "",
            :name => "" ,
            :salary => "",
            :clname => "",
            :gname => "",
            :posname => "<u>#{secname if secname != ""}</u>",
          })
        end
        if rs[i].wjobcode.to_s != rs[i - 1].wjobcode.to_s and rs[i].wjobcode.to_s != ""
          if rs[i].odsec != 0 and rs[i].odjob != 0 and rs[i].wseccode.to_s == rs[i - 1].wseccode.to_s 
            
            records5.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })
          else
            records5.push({   
              :i => "",
              :posid => "",
              :name => "" ,
              :salary => "",
              :clname => "",
              :gname => "",
              :posname => "<u>#{jobname if jobname != ""}</u>",
            })            
          end
        end
      end
      records5.push({   
        :i => row_n,
        :posid => rs[i].posid,
        :name => full_name ,
        :salary => number_with_delimiter(rs[i].salary.to_i.ceil),
        :clname => rs[i].clname,
        :gname => rs[i].gname,
        :posname => pos,
      })
      sd_n += 1
      sec_n += 1
      job_n += 1
      sd_sal += rs[i].salary.to_i
      sec_sal += rs[i].salary.to_i
      job_sal += rs[i].salary.to_i
      total_n += 1
      total_sal += rs[i].salary.to_i
      if i == rs.length - 1
        if rs[i].wjobcode.to_s != "0"
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].jobname}".strip} = #{number_with_delimiter(job_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(job_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          job_n = 0
          job_sal = 0          
        end
        if rs[i].wseccode.to_s != "0"
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{rs[i].secshort}#{rs[i].secname}".strip} = #{number_with_delimiter(sec_n.to_i.ceil)}" ,
            :salary => "#{number_with_delimiter(sec_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
        if rs[i].wsdcode.to_s != "0"
          records5.push({   
            :i => "",
            :posid => "รวมเงิน",
            :name => "รวม #{"#{subdeptpre1}#{rs[i].subdeptname}".strip} = #{number_with_delimiter(sd_n)}" ,
            :salary => "#{number_with_delimiter(sd_sal.to_i.ceil)}",
            :clname => "",
            :gname => "",
            :posname => "",
          })
          sd_n = 0
          sd_sal = 0
          
          sec_n = 0
          sec_sal = 0
          
          job_n = 0
          job_sal = 0 
        end
      end
    end
    
        
    
    order_arr = [
      [2,3,4,5,6,7,8,9],
      [10],
      [11,12,13,14,15],
      [16,17,18]
    ]
    order_check = ""
    rs = Csubdept.find(@user_work_place[:sdcode])
    
    for i in 0...order_arr.length
      if order_arr[i].include?(rs.sdtcode.to_i)
        order_check = i + 1
      end
    end
    @records += records5
    case order_check
      when 1
        @records += records1
      when 2
        @records += records2
      when 3
        @records += records3
      when 4
        @records += records4
    end
    
      
    if order_check != 1
      @records += records1
    end
    
    if order_check != 2
      @records += records2
    end
    
    if order_check != 3
      @records += records3
    end
    
    if order_check != 4
      @records += records4
    end
    
    @records.push({   
      :i => "",
      :posid => "รวมเงิน",
      :name => "รวมทั้งหมด = #{number_with_delimiter(total_n.to_i.ceil)}" ,
      :salary => "#{number_with_delimiter(total_sal.to_i.ceil)}",
      :clname => "",
      :gname => "",
      :posname => "",
    })
    prawnto :prawn => {
        :top_margin => 120,
        :left_margin => 10,
        :right_margin => 10
    }
  end

  def reportnumber
    if @current_user.group_user.type_group.to_s == "1"
      rs_subdept = Csubdept.find(@user_work_place[:sdcode])
      @subdeptname = "#{rs_subdept.shortpre}#{rs_subdept.subdeptname}"
      
      @search = " year = #{params[:year]} and sdcode = #{@user_work_place[:sdcode]} "
    end
    if @current_user.group_user.type_group.to_s == "2"
      @subdeptname = "สสจ. #{Cprovince.find(@current_user.group_user.provcode).provname}"
      search = " year = #{params[:year]} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "     
      sql_id = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search} and flagcal = '1'" if params[:type] == '1'
      sql_id = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search} and flagcal = '1'" if params[:type] == '2'
      @search = " year = #{params[:year]} and t_incsalary.id in (#{sql_id})"
    end
    prawnto :prawn => {
        :top_margin => 110,
        :left_margin => 10,
        :right_margin => 10
    }
  end
  
  def reportmoney
    prawnto :prawn => {
        :top_margin => 80,
        :left_margin => 10,
        :right_margin => 10
    }
  end


  def update_data
    begin
      id = ActiveSupport::JSON.decode(params[:id])
      year = params[:fiscal_year].to_s + params[:round]
      TIncsalary.delete_all(:id => id,:year => year)
      
      str_join = " inner join pispersonel on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
      str_join += " LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode " 
      search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1'  and pispersonel.id in ('#{id.join("','")}')"
      
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
        search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
      end         
      
      column = "pisj18.posid,pisj18.poscode,pisj18.c as level,pisj18.salary"
      column += ",pisj18.sdcode,pisj18.seccode,pisj18.jobcode,pisj18.excode"
      column += ",pisj18.epcode,pispersonel.ptcode,pisj18.subdcode,pisj18.dcode"
      column += ",pispersonel.fname,pispersonel.lname,pispersonel.pcode"  
      column += ",pispersonel.dcode as wdcode,pispersonel.sdcode as wsdcode"
      column += ",pispersonel.seccode as wseccode,pispersonel.jobcode as wjobcode"
      column += ",pispersonel.subdcode as wsubdcode,pispersonel.j18code,pispersonel.id"
      column += ",'1' as flagcal,'N' as flag_inc"
      rs = Pisj18.select(column).joins(str_join).find(:all,:conditions => search)
      #เก็บ ค่า c ลง Array
      arr_c = []
      d_c = Pisj18.select(" distinct pisj18.c").joins(str_join).find(:all,:conditions => search).collect{|u| u.c }
      rs_c = Cgrouplevel.select("ccode,minsal1,maxsal1,minsal2,maxsal2,baselow,basehigh").where(:ccode => d_c)
      for i in 0...rs_c.length
        arr_c.push(rs_c[i].ccode.to_i)
      end
      #เก็บค่า order ลง Array j18
      arr_order = []
      d_wp = Pisj18.select(" distinct pisj18.seccode,pisj18.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] }
      for i in 0...d_wp.length
        rs_tmp = Corderrpt.find(:all,:conditions => "seccode = #{d_wp[i][0].to_i} and jobcode = #{d_wp[i][1].to_i}")
        if rs_tmp.length > 0
          arr_order.push({
            :sorder => rs_tmp[0].sorder,
            :seccode => rs_tmp[0].seccode,
            :jobcode => rs_tmp[0].jobcode
          })
        else
          arr_order.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })           
        end
      end
      #เก็บค่า order ลง Array ปฏิบัติงานจริง
      arr_orderwp = []
      d_wp2 = Pisj18.select(" distinct pispersonel.seccode,pispersonel.jobcode").joins(str_join).find(:all,:conditions => search).collect{|u| [u.seccode.to_i,u.jobcode.to_i] } 
      for i in 0...d_wp2.length
        rs_tmp2 = Corderrpt.find(:all,:conditions => "seccode = #{d_wp2[i][0].to_i} and jobcode = #{d_wp2[i][1].to_i}")
        if rs_tmp2.length > 0
          arr_orderwp.push({
            :sorder => rs_tmp2[0].sorder,
            :seccode => rs_tmp2[0].seccode,
            :jobcode => rs_tmp2[0].jobcode
          })
        else
          arr_orderwp.push({
            :sorder => 0,
            :seccode => 0,
            :jobcode => 0
          })          
        end
      end
      #insert table
      vals = []
      rs.each do |v|
        idx_order = d_wp.index( [v.seccode.to_i,v.jobcode.to_i])
        idx_orderwp = d_wp2.index( [v.wseccode.to_i,v.wjobcode.to_i])
        idx_c = arr_c.index(v.level.to_i)
        midpoint = 0
        maxsalary  = 0
        note1 = "null"
        if !idx_c.nil?
          case v.salary.to_f
            when rs_c[idx_c].minsal2.to_f..rs_c[idx_c].maxsal2.to_f
              midpoint = rs_c[idx_c].basehigh
              maxsalary  = rs_c[idx_c].maxsal2            
            when rs_c[idx_c].minsal1.to_f..rs_c[idx_c].maxsal1.to_f
              midpoint = rs_c[idx_c].baselow
              maxsalary  = rs_c[idx_c].maxsal1
          end
        end
        val = "('#{params[:fiscal_year].to_s + params[:round].to_s}'"
        val += ",'#{v.id}','#{v.posid}','#{v.poscode}','#{v.level}','#{v.salary}','#{v.sdcode}'"
        val += ",'#{(v.seccode.to_s == "")? 0 : v.seccode}','#{(v.jobcode.to_s == "")? 0 : v.jobcode}'"
        val += ",'#{v.excode}','#{v.fname}','#{v.lname}','#{v.pcode}','#{v.epcode}'"
        val += ",'#{v.ptcode}','#{v.flag_inc}','#{v.subdcode}','#{v.dcode}','#{v.wdcode}','#{v.wsdcode}'"
        val += ",'#{(v.wseccode.to_s == "")? 0 : v.wseccode}','#{(v.wjobcode.to_s == "")? 0 : v.wjobcode}'"
        val += ",'#{v.wsubdcode}','#{v.j18code}','#{v.flagcal}','#{midpoint}','#{maxsalary}'"
        val += ",'#{begin arr_orderwp[idx_orderwp][:sorder] rescue 0 end}','#{begin arr_order[idx_order][:sorder]  rescue 0 end}'"
        if maxsalary.to_i == v.salary.to_i
          note1 = "'เต็มขั้น'"
        end
        val += ",#{note1})"
        vals.push(val.gsub(/''/,"null"))
      end
      col = "year,id,posid,poscode,level,salary,sdcode,seccode,jobcode,excode,fname,lname,pcode,epcode"
      col += ",ptcode,flag_inc,subdcode,dcode,wdcode,wsdcode,wseccode,wjobcode,wsubdcode,j18code,flagcal"
      col += ",midpoint,maxsalary,rp_orderw,rp_order,note1"
      if vals.length > 0
        QueryPis.insert_mass("t_incsalary",col,vals)
      end
      render :text => "{success: true}",:layout => false
    rescue
      render :text => "{success: false}",:layout => false
    end
  end

  

end
