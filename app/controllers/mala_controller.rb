# coding: utf-8
class MalaController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  def person
    limit = params[:limit]
    start = params[:start]
    search = " pisj18.flagupdate = '1' and pispersonel.pstatus = '1' "
    str_join = " inner join pisj18 on pisj18.posid = pispersonel.posid and pisj18.id = pispersonel.id "
    str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
    if !(params[:fields].nil?) and !(params[:query].nil?) and params[:query] != "" and params[:fields] != ""
      allfields = ActiveSupport::JSON.decode(params[:fields])
      for i in 0...allfields.length
        case allfields[i]
          when "fname","lname","pid","birthdate","sex","tel","posid"
            allfields[i] = "pispersonel.#{allfields[i]}"
          when "prefix"
            allfields[i] = "cprefix.#{allfields[i]}"
        end
      end
      search += " and ( #{allfields.join("::varchar like '%#{params[:query]}%' or ") + "::varchar like '%#{params[:query]}%' "} ) "
    end
    user_search = []
    search_j18 = ""
    search_personel = ""
    if @current_user.group_user.type_group.to_s == "1"
      @user_work_place.each do |key,val|
        if key.to_s == "mcode"
          k = "mincode"
        else
          k = key
        end
        user_search.push("pisj18.#{k} = '#{val}'")
      end
    end
    if @current_user.group_user.type_group.to_s == "2"
      search += " and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9)"
    end
    #search += " and pispersonel.appointdate < date_part('year',now())-25||'1205'"
    search += " and EXTRACT(year from AGE(NOW(), appointdate - INTERVAL '1 days')) >= 25"
    if user_search.length != 0
      if search == ""
        search_j18 = user_search.join(" and ")
        search_personel = user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      else
        search_j18 += " and " + user_search.join(" and ")
        search_personel += " and " + user_search.join(" and ")#.to_s.gsub("pisj18","pispersonel")
      end
    end
    sql_j18 = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pisj18.sdcode where #{search} #{search_j18}"
    sql_personel = "select pispersonel.* from pispersonel #{str_join} LEFT JOIN csubdept ON csubdept.sdcode = pispersonel.sdcode where #{search} #{search_personel}"
    sql = "(#{sql_j18}) union (#{sql_personel})"
    sql = sql_j18
    rs = Pispersonel.find_by_sql("#{sql} order by pispersonel.posid limit #{limit} offset #{start} ")
    return_data = {}
    return_data[:totalCount] = Pispersonel.find_by_sql("select count(*) as n from (#{sql}) as pis")[0].n
    return_data[:records]   = rs.collect{|u|
      prefix = (u.pcode.to_s == "")? "" : begin u.cprefix.longprefix rescue "" end
      {
        :id => u.id,
        :sex => render_sex(u.sex),
        :prefix => prefix,
        :fname => u.fname,
        :lname => u.lname,
        :pid => u.pid,
        :birthdate => render_date(u.birthdate),
        :tel => u.tel,
        :name => ["#{prefix}#{u.fname}", u.lname].join(" "),
        :posid => u.posid
      }
    }
    render :text => return_data.to_json,:layout => false  
  end
  
  def report
    str_join = " left join pispersonel on pispersonel.id = pisj18.id "
    str_join += " left join cprefix on pispersonel.pcode = cprefix.pcode "
    str_join += " left join cposition on pisj18.poscode = cposition.poscode "
    str_join += " left join cgrouplevel on pisj18.c = cgrouplevel.ccode "
    str_join += " left join cexpert on pisj18.epcode = cexpert.epcode "
    str_join += " left join cpostype on pisj18.ptcode = cpostype.ptcode"
    select = "fname,lname,birthdate,appointdate"
    select += ",cprefix.longprefix"
    select += ",cposition.posname"
    select += ",cgrouplevel.clname"
    select += ",cexpert.prename as eppre,cexpert.expert"
    select += ",cpostype.ptname,pisj18.sdcode,pisj18.deptcode,pisj18.mincode,pisj18.deptcode"
    @info = Pisj18.select(select).joins(str_join).where("pisj18.id = '#{params[:id]}'")
    
    str_join = " left join pispersonel on pispersonel.id = pisposhis.id "
    str_join += " left join cposition on pisposhis.poscode = cposition.poscode "
    str_join += " left join cgrouplevel on pisposhis.c = cgrouplevel.ccode "
    str_join += " left join cministry on pisposhis.mcode = cministry.mcode "
    str_join += " left join cdept on pisposhis.deptcode = cdept.deptcode"
    select = "pisposhis.*,cposition.posname"
    select += ",EXTRACT(year from AGE(date(forcedate), date(birthdate) - INTERVAL '1 days')) as age"
    select += ",deptname,minname,cposition.shortpre as pospre,clname"
    @records = Pisposhis.select(select).joins(str_join).where("pisposhis.id = '#{params[:id]}'").order("historder")
    prawnto :prawn => {
        :top_margin => 140,
        :bottom_margin => 30,
        :left_margin => 30,
        :right_margin => 30
    }
  end
end
