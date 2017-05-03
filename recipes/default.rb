#
# Cookbook:: opsworks-haproxy
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
# frozen_string_literal: true
haproxy_install 'package'

haproxy_config_global '' do
  chroot '/var/lib/haproxy'
  daemon true
  maxconn 256
  log '/dev/log local0'
  log_tag 'WARDEN'
  pidfile '/var/run/haproxy.pid'
  stats socket: '/var/lib/haproxy/stats level admin'
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
