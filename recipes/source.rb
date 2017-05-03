# frozen_string_literal: true
include_recipe 'build-essential'

selinux_state "SELinux Permissive" do
  action :permissive
end

haproxy_install 'source'

haproxy_config_global '' do
  daemon true
  maxconn 256
  log '/dev/log local0'
  log_tag 'WARDEN'
  pidfile '/var/run/haproxy.pid'
  tuning 'bufsize' => '262144'
end

haproxy_config_defaults 'defaults' do
  mode 'http'
  timeout connect: '5000ms',
          client: '5000ms',
          server: '5000ms'
  haproxy_retries 5
end

haproxy_frontend 'http-in' do
  bind '*:80'
  default_backend 'servers'
end

bind_hash = { '*' => '8080', '0.0.0.0' => %w(8081 8180) }

haproxy_frontend 'multiport' do
  bind bind_hash
  default_backend 'servers'
end

haproxy_backend 'servers' do
  server ['server1 127.0.0.1:8000 maxconn 32']
end
