# coding: utf-8
class ConfigPersonelController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  include ActionView::Helpers::NumberHelper
  def get_config
    #begin
      year = params[:year]
      id = params[:id]
      rs = TKs24usesub.find(:all ,:conditions => "year = #{year} and id = #{id} and officecode = '#{@user_work_place[:sdcode]}' ")[0]
      return_data = {}
      return_data[:success] = true
      return_data[:data] = {
        :usename => rs.usename,
        :salary => (rs.salary.to_s == "" )? "" : number_with_delimiter(rs.salary),
        :calpercent => rs.calpercent.to_i,
        :ks24 => (rs.ks24.to_s == "" )? "" : number_with_delimiter(rs.ks24),
        :admin_show => begin Pispersonel.find(rs.admin_id).full_name rescue "" end,
        :eval_show => begin Pispersonel.find(rs.eval_id).full_name rescue "" end,
        :etype => "#{render_etype rs.etype}",
        :sdcode_show => begin Csubdept.find(rs.sdcode).full_name rescue "" end,
        :seccode => rs.seccode,
        :jobcode => rs.jobcode,
        :pay => (rs.pay.to_s == "")? "" : number_with_delimiter(rs.pay),
        :diff => begin number_with_delimiter(rs.ks24 - rs.pay) rescue "" end
      }
      render :text => return_data.to_json,:layout => false
    #rescue
    #  render :text => "{success: false}"
    #end
  end
  def read
    year = params[:fiscal_year].to_s + params[:round]
    if @current_user.group_user.type_group.to_s == "1"
      search = " t_incsalary.sdcode = '#{@user_work_place[:sdcode]}'  and t_incsalary.flagcal = '1' and t_incsalary.year = #{year}"
    end
    
    if @current_user.group_user.type_group.to_s == "2"
      search_id = " year = #{year} and csubdept.provcode = '#{@current_user.group_user.provcode}' and csubdept.sdtcode not in (2,3,4,5,6,7,8,9) "
      sql_j18 = "select id from t_incsalary left join csubdept on t_incsalary.sdcode = csubdept.sdcode where #{search_id}" 
      sql_person = "select id from t_incsalary left join csubdept on t_incsalary.wsdcode = csubdept.sdcode where #{search_id}"
      sql_id = "(#{sql_j18}) union (#{sql_person})"
      sql_id = sql_j18
      search = " id in (#{sql_id}) and year = #{year} and flagcal = '1'"
    end
    
    search_tmp = []
    #search_tmp.push(" year = #{year} ")
    if params[:all_subdept].to_s == "false"
      if params[:sdcode].to_s != ""
        rs_subdept = Csubdept.find(params[:sdcode])
        sdtcode_c = [16,17,18]
        if sdtcode_c.include?(rs_subdept.sdtcode.to_i)
          search_tmp.push(" csubdept.provcode = #{rs_subdept.provcode} AND csubdept.amcode = #{rs_subdept.amcode} AND csubdept.sdtcode between 16 and 18")
        else
          search_tmp.push(" wsdcode = '#{params[:sdcode]}' ")
          
          if params[:seccode].to_s != ""
            search_tmp.push(" wseccode = '#{params[:seccode]}' ")
          end
          
          if params[:jobcode].to_s != ""
            search_tmp.push(" wjobcode = '#{params[:jobcode]}' ")
          end
        end
      end
      
      if search_tmp.length > 0
        search += " and (#{search_tmp.join(" and ")})"
      end
    end
    
    ##เก็บ j18status ลง array
    arr_j18 = []
    d_j18 = TIncsalary.select("distinct j18code").joins("LEFT JOIN csubdept  ON t_incsalary.wsdcode = csubdept.sdcode").find(:all,:conditions => search).collect{|u| u.j18code }
    rs_j18 = Cj18status.select("j18code,j18status").where(:j18code => d_j18)
    for i in 0...rs_j18.length
      arr_j18.push(rs_j18[i].j18code.to_i)
    end
    
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").joins("LEFT JOIN csubdept  ON t_incsalary.wsdcode = csubdept.sdcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บ updcode ลง array
    #arr_u = []
    #rs_u = Cupdate.select("updcode,updname").find(:all,:conditions => "updcode in (600,601,626)")
    #for i in 0...rs_u.length
    #  arr_u.push(rs_u[i].updcode.to_i)
    #end
    
    rs = TIncsalary.joins("LEFT JOIN csubdept  ON t_incsalary.wsdcode = csubdept.sdcode")
    rs = rs.find(:all,:conditions => search,:order => :posid)
    return_data = {}
    return_data[:totalCount] = TIncsalary.joins("LEFT JOIN csubdept  ON t_incsalary.wsdcode = csubdept.sdcode").count(:all,:conditions => search)
    idx = 0
    return_data[:records]   = rs.collect{|u|
      idx_j18 = arr_j18.index(u.j18code.to_i)
      idx_p = arr_p.index(u.pcode.to_i)
      #idx_u = arr_u.index(u.updcode.to_i)
      idx += 1
      {
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :j18status => begin rs_j18[idx_j18].j18status rescue "" end,
        :salary => number_with_delimiter(u.salary.to_i),
        :midpoint => number_with_delimiter(u.midpoint.to_i),
        :flageval1 =>  (u.flageval1.to_s == '1')? true : false,
        :evalid1 => u.evalid1,
        #:updcode => u.updcode.to_s,
        :updname => begin rs_u[idx_u].updname rescue "" end,
        :id => u.id,
        :idx => idx,
        :year => year
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def update
    data  = ActiveSupport::JSON.decode(params[:data])
    begin
      sql_a = []
      ActiveRecord::Base.transaction do
        data.each do |d|          
          sql = "update t_incsalary set"
          sql += " flageval1 = #{(d["flageval1"])? "1" : "0"}, "
          sql += " evalid1 = #{(d["evalid1"].to_s =="")? "null" : d["evalid1"]} "
          sql += " where year = #{d["year"]} and id = '#{d["id"]}'; "
          sql_a.push(sql)
        end
        ActiveRecord::Base.connection.execute(sql_a.join(""))
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
end
