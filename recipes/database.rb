#
# Cookbook:: nace_cometchat
# Recipe:: database
#
# The MIT License (MIT)
#
# Copyright:: 2017, UAF GINA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

apt_update 'system' do
  action :periodic
  frequency 86_400
end

mysql_service 'default' do
  port '3306'
  version '5.6'
  bind_address '127.0.0.1'
  initial_root_password 'changemenow!'
  action [:create, :start]
end


mysql_client 'default' do
  action :create
end

chef_gem 'mysql2' do
  compile_time false
end

mysql_database node['cometchat']['db_name'] do
  connection(
    :host     => '127.0.0.1',
    :username => 'root',
    :password => 'changemenow!'
  )
  action :create
end

mysql_database_user node['cometchat']['db_username'] do
  connection(
    :host     => '127.0.0.1',
    :username => 'root',
    :password => 'changemenow!'
  )
  database_name node['cometchat']['db_name']
  host          '%'
  privileges    [:all]

  password      node['cometchat']['db_password']
  action        [:create, :grant]
end
