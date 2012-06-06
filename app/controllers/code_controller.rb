# coding: utf-8
class CodeController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token  
  def csdgroup
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (sdgcode::varchar = '#{params[:query]}'"
      search += " or sdgname::varchar like '%#{params[:query]}%'";
      search += " or shortpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:sdgcode].to_s != ""
      search += " and sdgcode = '#{params[:sdgcode]}' "
    end
    records = Csdgroup.where("use_status = '1' #{search}").order("sdgname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Csdgroup.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :sdgcode => u.sdgcode,
      :sdgname => "#{u.shortpre} #{u.sdgname}(#{u.sdgcode})".strip,
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def ctrainlevel
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (trlcode::varchar = '#{params[:query]}'"
      search += " or trlname::varchar like '%#{params[:query]}%' )";
    end
    if params[:trlcode].to_s != ""
      search += " and trlcode = '#{params[:trlcode]}' "
    end
    records = Ctrainlevel.where("use_status = '1' #{search}").order("trlname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Ctrainlevel.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :trlcode => u.trlcode,
      :trlname => "#{u.trlname}(#{u.trlcode})".strip
    } }
    render :text => return_data.to_json, :layout => false    
  end
  
  def clocation
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (lcode::varchar = '#{params[:query]}'"
      search += " or location::varchar like '%#{params[:query]}%' )";
    end
    if params[:lcode].to_s != ""
      search += " and lcode = '#{params[:lcode]}' "
    end
    records = Clocation.where("use_status = '1' #{search}").order("location asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Clocation.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :lcode => u.lcode,
      :location => "#{u.location}(#{u.lcode})".strip
    } }
    render :text => return_data.to_json, :layout => false     
  end
  
  def carea
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (acode::varchar = '#{params[:query]}'"
      search += " or aname::varchar like '%#{params[:query]}%' )";
    end
    if params[:acode].to_s != ""
      search += " and acode = '#{params[:acode]}' "
    end
    records = Carea.where("use_status = '1' #{search}").order("aname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Carea.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :acode => u.acode,
      :aname => "#{u.aname}(#{u.acode})".strip
    } }
    render :text => return_data.to_json, :layout => false     
  end
  
  def cprovince
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (provname::varchar like '%#{params[:query]}%'"
      search += " or provcode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:provcode].to_s != ""
      search += " and provcode = '#{params[:provcode]}' "
    end
    records = Cprovince.where("use_status = '1' #{search}").order("provname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cprovince.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :provcode => u.provcode,
      :provname => "#{u.longpre} #{u.provname}(#{u.provcode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def camphur
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (amname::varchar like '%#{params[:query]}%'"
      search += " or amcode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";
    end
    records = Camphur.where("use_status = '1' and provcode = #{params[:provcode]} #{search}").order("amname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Camphur.where("use_status = '1' and provcode = #{params[:provcode]} #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :amcode => u.amcode,
      :amname => "#{u.longpre} #{u.amname}(#{u.amcode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def ctumbon
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (tmname::varchar like '%#{params[:query]}%'"
      search += " or tmcode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";      
    end
    records = Ctumbon.where("use_status = '1'  and provcode = #{params[:provcode]} and amcode = #{params[:amcode]} #{search}").order("tmname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Ctumbon.where("use_status = '1'  and provcode = #{params[:provcode]} and amcode = #{params[:amcode]} #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :tmcode => u.tmcode,
      :tmname => "#{u.longpre} #{u.tmname}(#{u.tmcode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def cfinpay
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (fcode::varchar = '#{params[:query]}'"
      search += " or finname::varchar like '%#{params[:query]}%' )";      
    end
    if params[:fcode].to_s != ""
      search += " and fcode = '#{params[:fcode]}' "
    end    
    records = Cfinpay.where("use_status = '1' #{search}").order("finname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cfinpay.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :fcode => u.fcode,
      :finname => "#{u.finname}(#{u.fcode})".strip
    } }
    render :text => return_data.to_json, :layout => false    
  end
  
  def csubdepttype
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (sdtcode::varchar = '#{params[:query]}'"
      search += " or subdepttype::varchar like '%#{params[:query]}%' )";      
    end
    if params[:sdtcode].to_s != ""
      search += " and sdtcode = '#{params[:sdtcode]}' "
    end    
    records = Csubdepttype.where("use_status = '1' #{search}").order("subdepttype asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Csubdepttype.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :sdtcode => u.sdtcode,
      :subdepttype => "#{u.subdepttype}(#{u.sdtcode})"
    } }
    render :text => return_data.to_json, :layout => false    
  end
  
  def csubdept
    limit = params[:limit].to_i
    start = params[:start].to_i
    where = "" 
    if params[:query].to_s != ""
      where = "and (sdcode::varchar = '#{params[:query]}'"
      where += " or subdeptname::varchar like '%#{params[:query]}%'";
      where += " or shortpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:sdcode].to_s != ""
      where += " and sdcode = '#{params[:sdcode]}' "
    end
    if params[:provcode].to_s != ""    
      where += " and provcode = '#{params[:provcode]}' "
    end
    if params[:amcode].to_s != ""    
      where += " and amcode = '#{params[:amcode]}' "
    end
    if params[:tmcode].to_s != ""    
      where += " and tmcode = '#{params[:tmcode]}' "
    end
    if params[:sdtcode].to_s != ""    
      where += " and sdtcode = '#{params[:sdtcode]}' "
    end
    records = Csubdept.where("use_status = '1' #{where}").order("subdeptname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Csubdept.where("use_status = '1' #{where}").count()
    return_data[:records]   = records.collect{|u|
      {
        :sdcode => u.sdcode,
        :subdeptname => "#{u.full_name}(#{u.sdcode})"
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  
  def cposition
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (posname::varchar like '%#{params[:query]}%'"
      search += " or poscode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:poscode].to_s != ""
      search += " and poscode = '#{params[:poscode]}' "
    end
    records = Cposition.where("use_status = '1' #{search}").order("posname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cposition.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :poscode => u.poscode,
      :posname => "#{u.full_name}(#{u.poscode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def cgrouplevel
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (ccode::varchar = '#{params[:query]}'"
      search += " or cname::varchar like '%#{params[:query]}%' )";
    end
    if params[:ccode].to_s != ""
      search += " and ccode = '#{params[:ccode]}' "
    end
    records = Cgrouplevel.where("use_status = '1' #{search}").order("cname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cgrouplevel.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :ccode => u.ccode,
      :cname => "#{u.cname}(#{u.ccode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cinterval
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (incode::varchar = '#{params[:query]}'"
      search += " or inname::varchar like '%#{params[:query]}%' )";
    end
    if params[:incode].to_s != ""
      search += " and incode = '#{params[:incode]}' "
    end
    records = Cinterval.where("use_status = '1' #{search}").order("inname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cinterval.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :incode => u.incode,
      :inname => "#{u.inname}(#{u.incode})".strip
    } }
    render :text => return_data.to_json, :layout => false      
  end
  
  def cpostype
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (ptcode::varchar = '#{params[:query]}'"
      search += " or ptname::varchar like '%#{params[:query]}%' )";
    end
    if params[:ptcode].to_s != ""
      search += " and ptcode = '#{params[:ptcode]}' "
    end
    records = Cpostype.where("use_status = '1' #{search}").order("ptname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cpostype.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :ptcode => u.ptcode,
      :ptname => "#{u.ptname}(#{u.ptcode})".strip
    } }
    render :text => return_data.to_json, :layout => false 
  end
  
  def cexecutive
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (exname::varchar like '%#{params[:query]}%'"
      search += " or excode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:excode].to_s != ""
      search += " and excode = '#{params[:excode]}' "
    end
    records = Cexecutive.where("use_status = '1' #{search}").order("exname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cexecutive.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :excode => u.excode,
      :exname => "#{u.full_name}(#{u.excode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def cexpert
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (epcode::varchar = '#{params[:query]}'"
      search += " or expert::varchar like '%#{params[:query]}%' )";
    end
    if params[:epcode].to_s != ""
      search += " and epcode = '#{params[:epcode]}' "
    end
    records = Cexpert.where("use_status = '1' #{search}").order("expert asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cexpert.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :epcode => u.epcode,
      :expert => "#{u.full_name}(#{u.epcode})".strip
    } }
    render :text => return_data.to_json, :layout => false 
  end
  
  def cministry
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (mcode::varchar = '#{params[:query]}'"
      search += " or minname::varchar like '%#{params[:query]}%' )";
    end
    if params[:mcode].to_s != ""
      search += " and mcode = '#{params[:mcode]}' "
    end
    #if @user_work_place.key?(:mcode)
    #  if search == ""
    #    search = "mcode = '#{@user_work_place[:mcode]}'"
    #  else
    #    search += " and mcode = '#{@user_work_place[:mcode]}'"
    #  end
    #end
    records = Cministry.where("use_status = '1' #{search}").order("minname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cministry.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :mcode => u.mcode,
      :minname => "#{u.minname}(#{u.mcode})".strip
    } }
    render :text => return_data.to_json, :layout => false     
  end
  
  def cdept
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (deptcode::varchar = '#{params[:query]}'"
      search += " or deptname::varchar like '%#{params[:query]}%' )";
    end
    if params[:deptcode].to_s != ""
      search += " and deptcode = '#{params[:deptcode]}' "
    end
    records = Cdept.where("use_status = '1' #{search}").order("deptname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cdept.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :deptcode => u.deptcode,
      :deptname => "#{u.deptname}(#{u.deptcode})".strip
    } }
    render :text => return_data.to_json, :layout => false       
  end
  
  def cdivision
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (division::varchar like '%#{params[:query]}%'"
      search += " or dcode::varchar = '#{params[:query]}'";
      search += " or prefix::varchar like '%#{params[:query]}%' )";
    end
    if params[:dcode].to_s != ""
      search += " and dcode = '#{params[:dcode]}' "
    end
    records = Cdivision.where("use_status = '1' #{search}").order("division asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cdivision.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :dcode => u.dcode,
      :division => "#{u.full_name}(#{u.dcode})".strip
    } }
    render :text => return_data.to_json, :layout => false    
  end
  
  def csection
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (seccode::varchar = '#{params[:query]}'"
      search += " or secname::varchar like '%#{params[:query]}%'";
      search += " or shortname::varchar like '%#{params[:query]}%' )";
    end
    if params[:seccode].to_s != ""
      search += " and seccode = '#{params[:seccode]}' "
    end
    records = Csection.where("use_status = '1' #{search}").order("secname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Csection.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :seccode => u.seccode,
      :secname => "#{u.full_name}(#{u.seccode})".strip
    } }
    render :text => return_data.to_json, :layout => false     
  end
  
  def cjob
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (jobcode::varchar = '#{params[:query]}'"
      search += " or jobname::varchar like '%#{params[:query]}%' )";
    end
    if params[:jobcode].to_s != ""
      search += " and jobcode = '#{params[:jobcode]}' "
    end
    records = Cjob.where("use_status = '1' #{search}").order("jobname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cjob.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :jobcode => u.jobcode,
      :jobname => "#{u.jobname}(#{u.jobcode})".strip
    } }
    render :text => return_data.to_json, :layout => false     
  end
  def csubdept_search
    where = ""
    if params[:sdcode].to_s != ""
      where += " and sdcode = '#{params[:sdcode]}' "
    end
    records = Csubdept.where("use_status = '1' #{where}")
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Csubdept.where("use_status = '1' #{where}").count()
    return_data[:records]   = records.collect{|u|
      {
        :sdcode => u.sdcode,
        :subdeptname => "#{u.full_name}(#{u.sdcode})".strip
      }
    }
    render :text => return_data.to_json, :layout => false 
  end
  
  def cposcondition
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (pcdcode::varchar = '#{params[:query]}'"
      search += " or pcdname::varchar like '%#{params[:query]}%' )";
    end
    if params[:pcdcode].to_s != ""
      search += " and pcdcode = '#{params[:pcdcode]}' "
    end
    records = Cposcondition.where("use_status = '1' #{search}").order("pcdname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cposcondition.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :pcdcode => u.pcdcode,
      :pcdname => "#{u.pcdname}(#{u.pcdcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def cj18status
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (j18code::varchar = '#{params[:query]}'"
      search += " or j18status::varchar like '%#{params[:query]}%' )";
    end
    if params[:j18code].to_s != ""
      search += " and j18code = '#{params[:j18code]}' "
    end
    records = Cj18status.where("use_status = '1' #{search}").order("j18status asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cj18status.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :j18code => u.j18code,
      :j18status => "#{u.j18status}(#{u.j18code})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cqualify
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""
      search = "and (qualify::varchar like '%#{params[:query]}%'"
      search += " or qcode::varchar = '#{params[:query]}'";
      search += " or longpre::varchar like '%#{params[:query]}%' )";
    end
    if params[:qcode].to_s != ""
      search += " and qcode = '#{params[:qcode]}' "
    end
    records = Cqualify.where("use_status = '1' #{search}").order("qualify asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cqualify.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :qcode => u.qcode,
      :qualify => "#{u.full_name}(#{u.qcode})".strip
    } }
    render :text => return_data.to_json, :layout => false
  end
  
  def cmajor
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (macode::varchar = '#{params[:query]}'"
      search += " or major::varchar like '%#{params[:query]}%' )";
    end
    if params[:macode].to_s != ""
      search += " and macode = '#{params[:macode]}' "
    end
    records = Cmajor.where("use_status = '1' #{search}").order("major asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cmajor.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :macode => u.macode,
      :major => "#{u.major}(#{u.macode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def ctrade
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (codetrade::varchar = '#{params[:query]}'"
      search += " or trade::varchar like '%#{params[:query]}%' )";
    end
    if params[:codetrade].to_s != ""
      search += " and codetrade = '#{params[:codetrade]}' "
    end
    records = Ctrade.where("use_status = '1' #{search}").order("trade asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Ctrade.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :codetrade => u.codetrade,
      :trade => "#{u.trade}(#{u.codetrade})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def cupdate
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (updcode::varchar = '#{params[:query]}'"
      search += " or updname::varchar like '%#{params[:query]}%' )";
    end
    if params[:updcode].to_s != ""
      search += " and updcode = '#{params[:updcode]}' "
    end
    records = Cupdate.where("use_status = '1' #{search}").order("updname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cupdate.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :updcode => u.updcode,
      :updname => "#{u.updname}(#{u.updcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cprefix
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (pcode::varchar = '#{params[:query]}'"
      search += " or longprefix::varchar like '%#{params[:query]}%' )";
    end
    if params[:pcode].to_s != ""
      search += " and pcode = '#{params[:pcode]}' "
    end
    records = Cprefix.where("use_status = '1' #{search}").order("longprefix asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cprefix.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :pcode => u.pcode,
      :longprefix => "#{u.longprefix}(#{u.pcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cmarital
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (mrcode::varchar = '#{params[:query]}'"
      search += " or marital::varchar like '%#{params[:query]}%' )";
    end
    if params[:mrcode].to_s != ""
      search += " and mrcode = '#{params[:mrcode]}' "
    end
    records = Cmarital.where("use_status = '1' #{search}").order("marital asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cmarital.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :mrcode => u.mrcode,
      :marital => "#{u.marital}(#{u.mrcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def creligion
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (recode::varchar = '#{params[:query]}'"
      search += " or renname::varchar like '%#{params[:query]}%' )";
    end
    if params[:recode].to_s != ""
      search += " and recode = '#{params[:recode]}' "
    end
    records = Creligion.where("use_status = '1' #{search}").order("renname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Creligion.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :recode => u.recode,
      :renname => "#{u.renname}(#{u.recode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def cchangename
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (chgcode::varchar = '#{params[:query]}'"
      search += " or chgname::varchar like '%#{params[:query]}%' )";
    end
    if params[:chgcode].to_s != ""
      search += " and chgcode = '#{params[:chgcode]}' "
    end
    records = Cchangename.where("use_status = '1' #{search}").order("chgname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cchangename.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :chgcode => u.chgcode,
      :chgname => "#{u.chgname}(#{u.chgcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cedulevel
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (ecode::varchar = '#{params[:query]}'"
      search += " or edulevel::varchar like '%#{params[:query]}%' )";
    end
    if params[:ecode].to_s != ""
      search += " and ecode = '#{params[:ecode]}' "
    end
    records = Cedulevel.where("use_status = '1' #{search}").order("edulevel asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cedulevel.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :ecode => u.ecode,
      :edulevel => "#{u.edulevel}(#{u.ecode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def ccountry
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (cocode::varchar = '#{params[:query]}'"
      search += " or coname::varchar like '%#{params[:query]}%' )";
    end
    if params[:cocode].to_s != ""
      search += " and cocode = '#{params[:cocode]}' "
    end
    records = Ccountry.where("use_status = '1' #{search}").order("coname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Ccountry.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :cocode => u.cocode,
      :coname => "#{u.coname}(#{u.cocode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def cdecoratype
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (dccode::varchar = '#{params[:query]}'"
      search += " or dcname::varchar like '%#{params[:query]}%' )";
    end
    if params[:dccode].to_s != ""
      search += " and dccode = '#{params[:dccode]}' "
    end
    records = Cdecoratype.where("use_status = '1' #{search}").order("dcname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cdecoratype.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :dccode => u.dccode,
      :dcname => "#{u.dcname}(#{u.dccode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def cpunish
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (pncode::varchar = '#{params[:query]}'"
      search += " or pnname::varchar like '%#{params[:query]}%' )";
    end
    if params[:pncode].to_s != ""
      search += " and pncode = '#{params[:pncode]}' "
    end
    records = Cpunish.where("use_status = '1' #{search}").order("pnname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cpunish.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :pncode => u.pncode,
      :pnname => "#{u.pnname}(#{u.pncode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end

  def cabsenttype
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (abcode::varchar = '#{params[:query]}'"
      search += " or abtype::varchar like '%#{params[:query]}%' )";
    end
    if params[:abcode].to_s != ""
      search += " and abcode = '#{params[:abcode]}' "
    end
    records = Cabsenttype.where("use_status = '1' #{search}").order("abtype asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cabsenttype.where("use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :abcode => u.abcode,
      :abtype => "#{u.abtype}(#{u.abcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  
  def t_ks24usesub
    limit = params[:limit].to_i
    start = params[:start].to_i
    year = params[:fiscal_year].to_s + params[:round]
    search = ""
    if params[:query].to_s != ""      
      search = "and (id::varchar = '#{params[:query]}'"
      search += " or usename::varchar like '%#{params[:query]}%' )";
    end
    if params[:id].to_s != ""
      search += " and id = '#{params[:id]}' "
    end
    records = TKs24usesub.where("officecode = '#{@user_work_place[:sdcode]}' and year = #{year} #{search}").order(:id).paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = TKs24usesub.count(:conditions => "officecode = '#{@user_work_place[:sdcode]}' and year = #{year} #{search}")
    return_data[:records]   = records.collect{|u| {   
      :id => u.id,
      :usename => "#{u.usename}(#{u.id})".strip,
      :year => u.year
    } }
    render :text => return_data.to_json, :layout => false      
  end


  def cupdate_cal_sal
    limit = params[:limit].to_i
    start = params[:start].to_i
    search = ""
    if params[:query].to_s != ""      
      search = "and (updcode::varchar = '#{params[:query]}'"
      search += " or updname::varchar like '%#{params[:query]}%' )";
    end
    if params[:updcode].to_s != ""
      search += " and updcode = '#{params[:updcode]}' "
    end
    records = Cupdate.where("updcode in (600,601,626) and use_status = '1' #{search}").order("updname asc").paginate :per_page => limit,:page => ((start / limit) + 1)
    return_data = Hash.new()
    return_data[:success] = true
    return_data[:totalcount] = Cupdate.where("updcode in (600,601,626) and use_status = '1' #{search}").count()
    return_data[:records]   = records.collect{|u| {   
      :updcode => u.updcode,
      :updname => "#{u.updname}(#{u.updcode})".strip
    } }
    render :text => return_data.to_json, :layout => false  
  end
  

end
