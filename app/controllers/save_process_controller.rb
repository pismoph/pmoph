# coding: utf-8
class SaveProcessController < ApplicationController
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
    

    return_data[:records] = tmp
    render :text => return_data.to_json,:layout => false
  end
end
