# coding: utf-8
class UpSalaryController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def read
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} "
    @user_work_place.each do |key,val|
      if key.to_s != "mcode" and key.to_s != "deptcode"
        search += " and #{key} = '#{val}' "
      end
    end
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    ##เก็บ j18status ลง array
    arr_j18 = []
    d_j18 = TIncsalary.select("distinct j18code").find(:all,:conditions => search).collect{|u| u.j18code }
    rs_j18 = Cj18status.select("j18code,j18status").where(:j18code => d_j18)
    for i in 0...rs_j18.length
      arr_j18.push(rs_j18[i].j18code.to_i)
    end
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => :posid)
    return_data = {}
    return_data[:totalCount] = TIncsalary.count(:all,:conditions => search)
    i = 0
    return_data[:records]   = rs.collect{|u|
      i += 1
      idx_c = arr_c.index(u.level.to_i)
      idx_j18 = arr_j18.index(u.j18code.to_i)
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      {
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :cname => begin rs_c[idx_c].cname rescue "" end,
        :salary => u.salary,
        :j18status => begin rs_j18[idx_j18].j18status rescue "" end,
        :midpoint => u.midpoint,
        :calpercent => u.calpercent,
        :score => u.score,
        :evalno => u.evalno,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :year => u.year,
        :id => u.id,
        :idx => i,
        :sdcode => u.sdcode
      }
    }
    render :text => return_data.to_json,:layout => false
  end
  
  def update
    begin
      data = ActiveSupport::JSON.decode(params[:data])
      data.each do |u|
        TIncsalary.transaction do
          val = []
          val.push("newsalary = #{ (u["newsalary"].to_s == "")? "null" : u["newsalary"] }")
          val.push("addmoney = #{ (u["addmoney"].to_s == "")? "null" : u["addmoney"] }")
          val.push("score = #{ (u["score"].to_s == "")? "null" : u["score"] }")
          val.push("note1 = '#{u["note1"]}'")
          val.push("calpercent = #{ (u["calpercent"].to_s == "")? "" : u["calpercent"] }")
          val.push("updcode = #{ (u["updcode"].to_s == "")? "null" : u["updcode"] }")
          val.push("evalno = #{ (u["evalno"].to_s == "")? "null" : u["evalno"] }")
          val = val.join(",")
          sql = "update t_incsalary set #{val} where year = #{u["year"]} and id = '#{u["id"]}' and sdcode = #{@user_work_place[:sdcode]} "
          ActiveRecord::Base.connection.execute(sql)
        end
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
end
