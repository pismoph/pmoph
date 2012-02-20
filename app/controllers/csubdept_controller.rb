# coding: utf-8
class CsubdeptController < ApplicationController
  before_filter :login_menu_code
  skip_before_filter :verify_authenticity_token
  def read
    limit = params[:limit]
    start = params[:start]
    search = ""
    if params[:fields].to_s != ""
      case_search = []
      fields = ActiveSupport::JSON.decode(params[:fields])
      fields.each do |v|
        case v
          when "sdcode"
            case_search.push("csubdept.sdcode::varchar like '%#{params[:query]}%'")
          when "shortpre"
            case_search.push("csubdept.shortpre::varchar like '%#{params[:query]}%'")
          when "longpre"          
            case_search.push("csubdept.longpre::varchar like '%#{params[:query]}%'")
          when "subdeptname"          
            case_search.push("csubdept.subdeptname::varchar like '%#{params[:query]}%'")
          when "sdgcode"
            case_search.push("csdgroup.sdgcode::varchar like '%#{params[:query]}%'")
          when "sdgname"
            case_search.push("csdgroup.sdgname::varchar like '%#{params[:query]}%'")
          when "acode"
            case_search.push("carea.acode::varchar like '%#{params[:query]}%'")
          when "aname"
            case_search.push("carea.aname::varchar like '%#{params[:query]}%'")
          when "trlcode"
            case_search.push("ctrainlevel.trlcode::varchar like '%#{params[:query]}%'")
          when "trlname"
            case_search.push("ctrainlevel.trlname::varchar like '%#{params[:query]}%'")
          when "provcode"
            case_search.push("cprovince.provcode::varchar like '%#{params[:query]}%'")
          when "provname"          
            case_search.push("cprovince.provname::varchar like '%#{params[:query]}%'")
          when "amcode"          
            case_search.push("camphur.amcode::varchar like '%#{params[:query]}%'")
          when "amname"
            case_search.push("camphur.amname::varchar like '%#{params[:query]}%'")
          when "tmcode"          
            case_search.push("ctumbon.tmcode::varchar like '%#{params[:query]}%'")
          when "tmname"          
            case_search.push("ctumbon.tmname::varchar like '%#{params[:query]}%'")
          when "fcode"          
            case_search.push("cfinpay.fcode::varchar like '%#{params[:query]}%'")
          when "finname"          
            case_search.push("cfinpay.finname::varchar like '%#{params[:query]}%'")
          when "lcode"          
            case_search.push("clocation.lcode::varchar like '%#{params[:query]}%'")
          when "location"          
            case_search.push("clocation.location::varchar like '%#{params[:query]}%'")
          when "use_status"          
            case_search.push("csubdept.use_status::varchar like '%#{params[:query]}%'")          
        end
      end
      if case_search.length > 0
        search = "where " + case_search.join( " or ")
      end      
    end
    sql = "
        select
                csubdept.sdcode
                ,csubdept.shortpre
                ,csubdept.longpre
                ,csubdept.subdeptname 
                ,csdgroup.sdgcode
                ,csdgroup.sdgname
                ,carea.acode
                ,carea.aname
                ,ctrainlevel.trlcode
                ,ctrainlevel.trlname
                ,cprovince.provcode
                ,cprovince.provname
                ,camphur.amcode
                ,camphur.amname
                ,ctumbon.tmcode              
                ,ctumbon.tmname
                ,cfinpay.fcode               
                ,cfinpay.finname
                ,clocation.lcode               
                ,clocation.location
                ,csubdept.use_status
        from
                csubdept
                left join csdgroup on csubdept.sdgcode = csdgroup.sdgcode
                left join carea on csubdept.acode = carea.acode
                left join ctrainlevel on csubdept.trlcode = ctrainlevel.trlcode
                left join cprovince on csubdept.provcode = cprovince.provcode        
                left join camphur on csubdept.amcode = camphur.amcode and camphur.provcode = cprovince.provcode        
                left join ctumbon on csubdept.tmcode = ctumbon.tmcode and ctumbon.provcode = cprovince.provcode and ctumbon.amcode = camphur.amcode
                left join cfinpay on csubdept.fcode = cfinpay.fcode
                left join clocation on csubdept.lcode = clocation.lcode
        #{search}
        order by csubdept.sdcode
        limit #{limit}
        offset #{start}
    "
    rs = Csubdept.find_by_sql(sql)
    return_data = Hash.new()
    sql = "
        select
                count(*) as n
        from
                csubdept
                left join csdgroup on csubdept.sdgcode = csdgroup.sdgcode
                left join carea on csubdept.acode = carea.acode
                left join ctrainlevel on csubdept.trlcode = ctrainlevel.trlcode
                left join cprovince on csubdept.provcode = cprovince.provcode        
                left join camphur on csubdept.amcode = camphur.amcode and camphur.provcode = cprovince.provcode        
                left join ctumbon on csubdept.tmcode = ctumbon.tmcode and ctumbon.provcode = cprovince.provcode and ctumbon.amcode = camphur.amcode
                left join cfinpay on csubdept.fcode = cfinpay.fcode
                left join clocation on csubdept.lcode = clocation.lcode
        #{search}
    "
    return_data[:totalCount] =    Csubdept.find_by_sql(sql)[0]["n"]
    return_data[:records]   = rs.collect{|u| {
            :sdcode => u.sdcode,
            :sdcode_tmp => u.sdcode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :subdeptname => u.subdeptname,            
            :sdgcode => u.sdgcode,
            :sdgname => u.sdgname,
            :acode => u.acode,            
            :aname => u.aname,
            :trlcode => u.trlcode,
            :trlname => u.trlname,
            :provcode => u.provcode,
            :provname => u.provname,
            :amcode => u.amcode,
            :amname => u.amname,
            :tmcode => u.tmcode,
            :tmname => u.tmname,
            :fcode  => u.fcode,             
            :finname => u.finname,
            :lcode => u.lcode,           
            :location => u.location,
            :use_status => (u.use_status.to_s == '1') ? "ใช้งาน" : "ยกเลิก" 
    } }    
    render :text => return_data.to_json,:layout => false
  end

  def create
    count_check = Csubdept.count(:all, :conditions => "sdcode = '#{params[:sdcode_tmp]}'")
    if count_check > 0
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "มีรหัสนี้แล้ว"
      render :text => return_data.to_json, :layout=>false      
    else
      store = Csubdept.new
      store.use_status = params[:use_status]
      store.provcode = params[:provcode]
      store.sdgcode = params[:sdgcode]
      store.acode = params[:acode]
      store.lcode = params[:lcode]
      store.longpre = params[:longpre]
      store.trlcode = params[:trlcode]
      store.subdeptname = params[:subdeptname]
      store.shortpre = params[:shortpre]
      store.fcode = params[:fcode]
      store.sdcode = params[:sdcode_tmp]
      store.tmcode = params[:tmcode]
      store.amcode = params[:amcode]
      if store.save
        render :text => "{success:true}"
      else
        render :text => "{success:false,msg:'เกิดข้อผิดพลาดกรุุณาทำรายการใหม่อีกครั้ง'}"   
      end
    end
  end

  def search_edit
    sql = "
        select
                sdcode,shortpre,longpre,subdeptname,sdgcode,acode,trlcode,provcode,amcode,tmcode,fcode,lcode,use_status
        from
                csubdept
        where sdcode = #{params[:sdcode]}
    "
    rs = Csubdept.find_by_sql(sql)
    return_data = Hash.new()
    return_data[:records]   = rs.collect{|u| {
            :sdcode => u.sdcode,
            :sdcode_tmp => u.sdcode,
            :shortpre => u.shortpre,
            :longpre => u.longpre,
            :subdeptname => u.subdeptname,            
            :sdgcode => u.sdgcode,
            :acode => u.acode, 
            :trlcode => u.trlcode,
            :provcode => u.provcode,
            :amcode => u.amcode,
            :tmcode => u.tmcode,
            :fcode  => u.fcode,
            :lcode => u.lcode,
            :use_status => u.use_status
    } }    
    render :text => return_data.to_json,:layout => false
  end

  def update
    count_check = Csubdept.count(:all , :conditions => "sdcode = '#{params[:sdcode_tmp]}' and sdcode <> '#{params[:sdcode]}' ")
    if count_check > 0
      return_data = Hash.new()
      return_data[:success] = false
      return_data[:msg] = "มีรหัสตี้แล้ว"
      render :text => return_data.to_json, :layout=>false
    else
      sql = " update Csubdept set
                    sdcode = #{params[:sdcode_tmp]},
                    shortpre = '#{params[:shortpre]}',
                    longpre = '#{params[:longpre]}',
                    subdeptname = '#{params[:subdeptname]}',
      "
      sql += "sdgcode = #{params[:sdgcode]}," if params[:sdgcode].to_s != ""
      sql += "acode = #{params[:acode]}," if params[:acode].to_s != ""
      sql += "trlcode = #{params[:trlcode]}," if params[:trlcode].to_s != ""
      sql += "provcode = #{params[:provcode]}," if params[:provcode].to_s != ""
      sql += "amcode = #{params[:amcode]}," if params[:amcode].to_s != ""
      sql += "tmcode = #{params[:tmcode]}," if params[:tmcode].to_s != ""
      sql += "fcode  = #{params[:fcode]}," if params[:fcode].to_s != ""
      sql += "lcode = #{params[:lcode]}," if params[:lcode].to_s != ""
      sql += "
                    use_status = '#{params[:use_status]}'
              where sdcode = #{params[:sdcode].to_s}
      "
      if QueryPis.update_by_sql(sql)
        render :text => "{success:true}" 
      else
        render :text => "{success:false,msg:'เกิดข้อผิดพลาดกรุุณาทำรายการใหม่อีกครั้ง'}"   
      end      
    end
  end

  def delete
    sdcode = params[:sdcode]
    if Csubdept.delete(sdcode)
            render :text => "{success:true}"
    else
            render :text => "{success:false,msg:'เกิดข้อผิดพลาดกรุุณาทำรายการใหม่อีกครั้ง'}"
    end
  end

  def report
    data = ActiveSupport::JSON.decode(params[:data])
    search = ""
    if data["fields"].to_s != ""
      case_search = []
      fields = ActiveSupport::JSON.decode(data["fields"])
      fields.each do |v|
        case v
          when "sdcode"
            case_search.push("csubdept.sdcode::varchar like '%#{data["query"]}%'")
          when "shortpre"
            case_search.push("csubdept.shortpre::varchar like '%#{data["query"]}%'")
          when "longpre"          
            case_search.push("csubdept.longpre::varchar like '%#{data["query"]}%'")
          when "subdeptname"          
            case_search.push("csubdept.subdeptname::varchar like '%#{data["query"]}%'")
          when "sdgcode"
            case_search.push("csdgroup.sdgcode::varchar like '%#{data["query"]}%'")
          when "sdgname"
            case_search.push("csdgroup.sdgname::varchar like '%#{data["query"]}%'")
          when "acode"
            case_search.push("carea.acode::varchar like '%#{data["query"]}%'")
          when "aname"
            case_search.push("carea.aname::varchar like '%#{data["query"]}%'")
          when "trlcode"
            case_search.push("ctrainlevel.trlcode::varchar like '%#{data["query"]}%'")
          when "trlname"
            case_search.push("ctrainlevel.trlname::varchar like '%#{data["query"]}%'")
          when "provcode"
            case_search.push("cprovince.provcode::varchar like '%#{data["query"]}%'")
          when "provname"          
            case_search.push("cprovince.provname::varchar like '%#{data["query"]}%'")
          when "amcode"          
            case_search.push("camphur.amcode::varchar like '%#{data["query"]}%'")
          when "amname"
            case_search.push("camphur.amname::varchar like '%#{data["query"]}%'")
          when "tmcode"          
            case_search.push("ctumbon.tmcode::varchar like '%#{data["query"]}%'")
          when "tmname"          
            case_search.push("ctumbon.tmname::varchar like '%#{data["query"]}%'")
          when "fcode"          
            case_search.push("cfinpay.fcode::varchar like '%#{data["query"]}%'")
          when "finname"          
            case_search.push("cfinpay.finname::varchar like '%#{data["query"]}%'")
          when "lcode"          
            case_search.push("clocation.lcode::varchar like '%#{data["query"]}%'")
          when "location"          
            case_search.push("clocation.location::varchar like '%#{data["query"]}%'")
          when "use_status"          
            case_search.push("csubdept.use_status::varchar like '%#{data["query"]}%'")          
        end
      end
      if case_search.length > 0
        search = "where " + case_search.join( " or ")
      end      
    end
    sql = "
        select
                csubdept.sdcode
                ,csubdept.shortpre
                ,csubdept.longpre
                ,csubdept.subdeptname 
                ,csdgroup.sdgcode
                ,csdgroup.sdgname
                ,carea.acode
                ,carea.aname
                ,ctrainlevel.trlcode
                ,ctrainlevel.trlname
                ,cprovince.provcode
                ,cprovince.provname
                ,camphur.amcode
                ,camphur.amname
                ,ctumbon.tmcode              
                ,ctumbon.tmname
                ,cfinpay.fcode               
                ,cfinpay.finname
                ,clocation.lcode               
                ,clocation.location
                ,csubdept.use_status
        from
                csubdept
                left join csdgroup on csubdept.sdgcode = csdgroup.sdgcode
                left join carea on csubdept.acode = carea.acode
                left join ctrainlevel on csubdept.trlcode = ctrainlevel.trlcode
                left join cprovince on csubdept.provcode = cprovince.provcode        
                left join camphur on csubdept.amcode = camphur.amcode and camphur.provcode = cprovince.provcode        
                left join ctumbon on csubdept.tmcode = ctumbon.tmcode and ctumbon.provcode = cprovince.provcode and ctumbon.amcode = camphur.amcode
                left join cfinpay on csubdept.fcode = cfinpay.fcode
                left join clocation on csubdept.lcode = clocation.lcode
        #{search}
        order by csubdept.sdcode
    "
    prawnto :prawn=>{:page_layout=>:landscape}
    @records = Csubdept.find_by_sql(sql)
  end
end
