set :application, "birdherd"
set :domain, "thebirdherd.com"
set :deploy_to, "/var/www/vhosts/thebirdherd.com"
set :repository, 'git@github.com:baseonmars/birdherd.git'
set :web_command, 'sudo /etc/init.d/apache2'
set :revision, 'v0.1.1a'
