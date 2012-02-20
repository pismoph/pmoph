#!/usr/bin/ruby

cmd = "perl -p -i -e \"s/\/images/\/pmoph\/images/g\" public/stylesheets/icon.css"
system(cmd)
###
cmd = "perl -p -i -e \"s/\/images/\/pmoph\/images/g\" app/views/layouts/extjs_layout.html.erb"
system(cmd)
##
cmd = "perl -p -i -e \"s/pre_url = \"\"/pre_url = \"\/pmoph\" public/javascripts/fshare.js"
system(cmd)