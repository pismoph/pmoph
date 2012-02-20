# coding: utf-8
class MainController < ApplicationController
  before_filter :login_required
  layout "extjs_layout"
  def index
  end
end
