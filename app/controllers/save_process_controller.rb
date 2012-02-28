# coding: utf-8
#require "spreadsheet/excel"
class SaveProcessController < ApplicationController
  #include Spreadsheet
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  def formula
    tmp = []
    return_data = {}
    return_data[:records] = []
    if params[:formula].to_s == "1"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "1",:e_name => "พอใช้",:e_begin => "60.00",:e_end => "69.99",:up => "2",:idx => 2 })
      tmp.push({:dno => "2",:e_name => "ดี",:e_begin => "70.00",:e_end => "79.99",:up => "3",:idx => 3 })
      tmp.push({:dno => "3",:e_name => "ดีมาก",:e_begin => "80.00",:e_end => "89.99",:up => "4",:idx => 4 })
      tmp.push({:dno => "4",:e_name => "ดีเด่น",:e_begin => "90.00",:e_end => "100",:up => "5",:idx => 5 })      
    end
    if params[:formula].to_s == "2"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "11",:e_name => "พอใช้ 1",:e_begin => "60.00",:e_end => "63.99",:up => "1",:idx => 2 })
      tmp.push({:dno => "12",:e_name => "พอใช้ 2",:e_begin => "64.00",:e_end => "66.99",:up => "1.5",:idx => 3 })
      tmp.push({:dno => "13",:e_name => "พอใช้ 3",:e_begin => "67.00",:e_end => "69.99",:up => "1.7",:idx => 4 })
      tmp.push({:dno => "21",:e_name => "ดี 1",:e_begin => "70.00",:e_end => "73.99",:up => "2",:idx => 5 })
      tmp.push({:dno => "22",:e_name => "ดี 2",:e_begin => "74.00",:e_end => "76.99",:up => "2.2",:idx => 6 })
      tmp.push({:dno => "23",:e_name => "ดี 3",:e_begin => "77.00",:e_end => "79.99",:up => "2.7",:idx => 7 })
      tmp.push({:dno => "31",:e_name => "ดีมาก 1",:e_begin => "80.00",:e_end => "83.99",:up => "3",:idx => 8 })
      tmp.push({:dno => "32",:e_name => "ดีมาก 2",:e_begin => "84.00",:e_end => "86.99",:up => "3.3",:idx => 9 })
      tmp.push({:dno => "33",:e_name => "ดีมาก 3",:e_begin => "87.00",:e_end => "89.99",:up => "3.6",:idx => 10 })
      tmp.push({:dno => "41",:e_name => "ดีเด่น 1",:e_begin => "90.00",:e_end => "93.99",:up => "3.9",:idx => 11 })
      tmp.push({:dno => "42",:e_name => "ดีเด่น 2",:e_begin => "94.00",:e_end => "96.99",:up => "4.2",:idx => 12 })
      tmp.push({:dno => "43",:e_name => "ดีเด่น 3",:e_begin => "97.00",:e_end => "100",:up => "4.5",:idx => 13 })
    end
    if params[:formula].to_s == "3"
      tmp.push({:dno => "0",:e_name => "ปรับปรุง",:e_begin => "0.00",:e_end => "59.99",:up => "0",:idx => 1 })
      tmp.push({:dno => "11",:e_name => "พอใช้ 1",:e_begin => "60.00",:e_end => "65.99",:up => "1",:idx => 2 })
      tmp.push({:dno => "12",:e_name => "พอใช้ 2",:e_begin => "66.00",:e_end => "69.99",:up => "1.5",:idx => 3 })
      tmp.push({:dno => "21",:e_name => "ดี 1",:e_begin => "70.00",:e_end => "75.99",:up => "2",:idx => 4 })
      tmp.push({:dno => "22",:e_name => "ดี 2",:e_begin => "76.00",:e_end => "79.99",:up => "2.2",:idx => 5 })      
      tmp.push({:dno => "31",:e_name => "ดีมาก 1",:e_begin => "80.00",:e_end => "85.99",:up => "3",:idx => 6 })
      tmp.push({:dno => "32",:e_name => "ดีมาก 2",:e_begin => "86.00",:e_end => "89.99",:up => "3.3",:idx => 7 })
      tmp.push({:dno => "41",:e_name => "ดีเด่น 1",:e_begin => "90.00",:e_end => "95.99",:up => "3.9",:idx => 8 })
      tmp.push({:dno => "42",:e_name => "ดีเด่น 2",:e_begin => "96.00",:e_end => "100",:up => "4.2",:idx => 9 })      
    end
    
    if params[:formula].to_s == ""
      i = 0
      year = params[:fiscal_year].to_s + params[:round]
      rs = TKs24usesubdetail.find(:all,:conditions => "year = #{year} and id = #{params[:id]}")
      tmp = rs.collect{|u|
        i += 1
        {
          :dno => u.dno,
          :e_name => u.e_name,
          :e_begin => u.e_begin,
          :e_end => u.e_end,
          :up => u.up,
          :idx => i,
          :salary => "",
          :n => ""
        }
      }
    end
    return_data[:records] = tmp
    render :text => return_data.to_json,:layout => false
  end
  
  def read
    year = params[:fiscal_year].to_s + params[:round]
    search = " year = #{year} and evalid1 = #{params[:id]} and flagcal = '1' and sdcode = '#{@user_work_place[:sdcode]}' "
    rs = TIncsalary.find(:all,:conditions => search,:order => :posid)
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    i = 0
    return_data = {}
    if params[:file].to_s == ""
      return_data[:records]   = rs.collect{|u|
        i += 1
        idx_p = arr_p.index(u.pcode.to_i)
        {
          :idx => i,
          :posid => u.posid,
          :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
          :salary => u.salary,
          :midpoint => u.midpoint,
          :score => u.score,
          :newsalary => u.newsalary,
          :addmoney => u.addmoney,
          :note1 => u.note1,
          :maxsalary => u.maxsalary,
          :id => u.id
        }
      }
    else
      map_column = ActiveSupport::JSON.decode(params[:map_column])
      col_posid = ""
      col_score = ""
      col_note1 = ""
      posid = []
      score = []
      note1 = []
      map_column.each do |u|
        if u["col_name"].to_s == "posid"
          col_posid = u["config"].to_i
        end
        if u["col_name"].to_s == "score"
          col_score = u["config"].to_i
        end
        if u["col_name"].to_s == "note1"
          col_note1 = u["config"].to_i
        end
      end
      Spreadsheet.open(params[:file], "rb") do |book|
        sheet= book.worksheet(0)
        for i in 1...sheet.row_count
          posid.push(sheet[i,col_posid].to_i)
          score.push(sheet[i,col_score].to_i)
          note1.push(sheet[i,col_note1].to_s)
        end
        
        return_data[:records]   = rs.collect{|u|
          i += 1
          idx_p = arr_p.index(u.pcode.to_i)
          {
            :idx => i,
            :posid => u.posid,
            :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
            :salary => u.salary,
            :midpoint => u.midpoint,
            :score => begin score[posid.index(u.posid.to_i)] rescue "" end,
            :newsalary => "",
            :addmoney => "",
            :note1 => begin note1[posid.index(u.posid.to_i)] rescue "" end,
            :maxsalary => u.maxsalary,
            :id => u.id
          }
        }
      end
      File.delete(params[:file]) 
    end
    render :text => return_data.to_json,:layout => false
  end
  
  def process_cal
    begin
      year = params[:fiscal_year].to_s + params[:round]
      search_config = "year = #{year} and id = #{params[:id]}"
      search_user = " year = #{year} and evalid1 = #{params[:id]} and flagcal = '1' and sdcode = '#{@user_work_place[:sdcode]}' "
      data_user = ActiveSupport::JSON.decode(params[:data_user])
      data_config = ActiveSupport::JSON.decode(params[:data_config])
      val_config = []
      sql = ""
      TIncsalary.transaction do
        ## t_ks24usesubdetail
        TKs24usesubdetail.delete_all(search_config)
        data_config.each do |u|
          val_config.push("(#{params[:id]},#{year},#{u["dno"]},'#{u["e_name"]}',#{u["e_begin"]},#{u["e_end"]},#{u["up"]})")
          #compare_config.push([u["e_begin"].to_f,u["e_end"].to_f,u["up"].to_f])
        end
        sql = "insert into t_ks24usesubdetail(id, year, dno, e_name, e_begin, e_end, up) values#{val_config.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
        ## TIncsalary
        data_user.each do |du|
          newsalary = "null"
          addmoney = "null"
          calpercent = "null"
          updcode = "null"
          evalno = "null"
          data_config.each do |dc|
            if dc["e_begin"].to_f <= du["score"].to_f and dc["e_end"].to_f >= du["score"].to_f
              evalno = dc["dno"]
              calpercent = dc["up"]
              newsalary = (dc["up"].to_f / 100)
              newsalary = newsalary * du["midpoint"].to_f
              newsalary += du["salary"].to_f
              if newsalary >= du["maxsalary"].to_f
                addmoney = ("%.2f" % (newsalary - du["maxsalary"].to_f)).to_f
                newsalary = du["maxsalary"].to_f
                updcode = 601
              else
                newsalary = ((newsalary/10).ceil)*10
                updcode = 626
              end
              
              if du["score"].to_f <= 0
                updcode = 600
              end
            end
            ########
          end
          sql = "update t_incsalary set "
          sql += " newsalary = #{(newsalary.to_s == "")? "null" : newsalary} "
          sql += " ,addmoney = #{(addmoney.to_s == "")? "null" : addmoney} "
          sql += " ,score = #{(du["score"].to_s == "")? "null" : du["score"]} "
          sql += " ,note1 = #{(du["note1"].to_s == "")? "null" : du["note1"]} "
          sql += " ,calpercent = #{(calpercent.to_s == "")? "null" : calpercent} "
          sql += " ,updcode = #{(updcode.to_s == "")? "null" : updcode} "
          sql += " ,evalno = #{(evalno.to_s == "")? "null" : evalno} "
          sql += " where #{search_user} and id = '#{du["id"]}'"
          ActiveRecord::Base.connection.execute(sql)
        end  
      end
      render :text => "{success: true}"
    rescue
      render :text => "{success: false}"
    end
  end
  
  def report
    year = params[:fiscal_year].to_s + params[:round].to_s
    search = " t_incsalary.year = #{year} and t_incsalary.evalid1 = #{params[:id]} and t_incsalary.flagcal = '1' and t_incsalary.sdcode = '#{@user_work_place[:sdcode]}' "
    
    ##เก็บ pcode ลง array
    arr_p = []
    d_p = TIncsalary.select("distinct pcode").find(:all,:conditions => search).collect{|u| u.pcode }
    rs_p = Cprefix.select("pcode,prefix").where(:pcode => d_p)
    for i in 0...rs_p.length
      arr_p.push(rs_p[i].pcode.to_i)
    end
    
    ##เก็บ pid ลง array
    arr_pid = []
    rs_pid = Pispersonel.find(:all,:select => "id,pid",:conditions => "id in (select t_incsalary.id from t_incsalary where #{search}) ")
    for i in 0...rs_pid.length
      arr_pid.push(rs_pid[i].id.to_s)
    end
    
    ##เก็บ c ลง array
    arr_c = []
    d_c = TIncsalary.select("distinct level").find(:all,:conditions => search).collect{|u| u.level }
    rs_c = Cgrouplevel.select("ccode,cname,clname,gname").where(:ccode => d_c)
    for i in 0...rs_c.length
      arr_c.push(rs_c[i].ccode.to_i)
    end
    
    ##เก็บค่า position ลง array
    arr_pos = []
    d_pos = TIncsalary.select("distinct poscode").find(:all,:conditions => search).collect{|u| u.poscode }
    rs_pos = Cposition.select("poscode,posname,shortpre").where(:poscode => d_pos)
    for i in 0...rs_pos.length
      arr_pos.push(rs_pos[i].poscode.to_i)
    end
    
    ##เก็บ section ลง array
    arr_sec = []
    d_sec = TIncsalary.select("distinct seccode").find(:all,:conditions => search).collect{|u| u.seccode }
    rs_sec = Csection.select("seccode,secname,shortname").where(:seccode => d_sec)
    for i in 0...rs_sec.length
      arr_sec.push(rs_sec[i].seccode.to_i)
    end    
    
    rs = TIncsalary.find(:all,:conditions => search,:order => "seccode,posid")
    
    i = 0
    @records = rs.collect{|u|
      i += 1
      idx_p = arr_p.index(u.pcode.to_i)
      idx_pid = arr_pid.index(u.id.to_s)
      idx_c = arr_c.index(u.level.to_i)
      idx_pos = arr_pos.index(u.poscode.to_i)
      idx_sec = arr_sec.index(u.seccode.to_i)
      {
        :idx => i,
        :posid => u.posid,
        :name => "#{begin rs_p[idx_p].prefix rescue "" end}#{u.fname} #{u.lname}",
        :pid => begin rs_pid[idx_pid].pid rescue "" end,
        :salary => u.salary,
        :midpoint => u.midpoint,
        :score => u.score,
        :newsalary => u.newsalary,
        :addmoney => u.addmoney.to_s,
        :note1 => u.note1,
        :maxsalary => u.maxsalary,
        :id => u.id,
        :clname => begin rs_c[idx_c].clname rescue "" end,
        :gname => begin rs_c[idx_c].gname rescue "" end,
        :posname => begin "#{rs_pos[idx_pos].shortpre}#{rs_pos[idx_pos].posname}" rescue "" end,
        :secname => begin "#{rs_sec[idx_sec].shortname}#{rs_sec[idx_sec].secname}" rescue "" end,
      }
    }
    respond_to do |format|
      format.xls  { render :action => "report", :layout => false }
    end
  end
  
  def upload
    begin
      t = Time.new
      data = {}
      file = Upload.save_process(params[:file],@current_user.id.to_s+"_#{t.to_i}")
      Spreadsheet.open(file[1], "rb") do |book|
        sheet= book.worksheet(0)
        data[:success] = true
        data[:column] = sheet.row(0)
        data[:file] = file[1].to_s
      end
      render :text => data.to_json,:layout => false
    rescue
      render :text => "{success: false,msg: 'เกิดความผิดพลาด'}",:layout => false
    end
    
  end
  
  def map_column
    tmp = []
    return_data = {}
    return_data[:records] = []
    tmp.push({:static => "เลขที่ตำแหน่ง",:col_name => "posid",:config => ""})
    tmp.push({:static => "คะแนน",:col_name => "score",:config => ""})
    tmp.push({:static => "หมายเหตุ",:col_name => "note1",:config => ""})
    return_data[:records] = tmp
    render :text => return_data.to_json,:layout => false
  end
end
