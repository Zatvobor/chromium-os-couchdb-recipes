default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, 'kiosk-mini'

set :user, "chronos"
set :password, "facepunch"
set :sudo_prompt, 'facepunch'
set :use_sudo, true