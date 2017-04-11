#
# Cookbook:: nace_cometchat
# Recipe:: ckan_plugin
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

include_recipe 'chef-vault'

chatnode = search(:node, "tags:cometchat AND chef_environment:#{node.chef_environment}", filter_result: { ip: [:ipaddress], fqdn: [:fqdn] }).first

if chatnode
  mysqlconfig = chef_vault_item_for_environment('apps', 'nace_ckan')['cometchat']

  chat_url = "http://#{chatnode['fqdn'].nil ? chatnode['ip'] : chatnode['fqdn']}/"

  package %w(mysql-client libmysqlclient-dev)

  python_package 'MySQL-python' do
    python '/usr/lib/ckan/default/bin/python'
    action :install
  end

  directory '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/' do
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/cometchat-css.html' do
    source 'cometchat-css.html.erb'
    variables ({
        'cometchat_url' => chat_url
    })
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace/templates/snippets/cometchat-js.html' do
    source 'cometchat-js.html.erb'
    variables ({
        'cometchat_url' => chat_url
      })
    action :create
  end

  template '/usr/lib/ckan/default/src/ckanext-nasa_ace/ckanext/nasa_ace_actions/config.py' do
    source 'config.py.erb'
    variables ({
        'cometchat_db_host'     => mysqlconfig['db_host'],
        'cometchat_db_name'     => mysqlconfig['db_name'],
        'cometchat_db_username' => mysqlconfig['db_username'],
        'cometchat_db_password' => mysqlconfig['db_password']
      })
      action :create
  end

  template '/tmp/create_users.sh' do
    source 'create_users.erb'
    variables ({
      'mysql_host_name' => mysqlconfig['db_host'],
      'mysql_user'      => mysqlconfig['db_username'],
      'mysql_password'  => mysqlconfig['db_password'],
      'mysql_db_name'   => mysqlconfig['db_name']
    })
    action :create
    notifies :run, 'execute[create_users]', :delayed
  end

  execute 'create_users' do
    command 'bash /tmp/create_users.sh'
    action :nothing
  end
end
