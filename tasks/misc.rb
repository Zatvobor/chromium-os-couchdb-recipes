namespace :misc do

  desc "Get the local IP."
  task :local_ip do puts fetch_local_ip end;

end