HERE = File.split(__FILE__).first
Dir.chdir(HERE) do
  %x(bundle exec haml page.haml > ../../pages/r0/index.html)
  %x(bundle exec haml figs.haml > ../../pages/r0/figs.html)
  %x(bundle exec ruby build_json.rb > ../../pages/r0/data.json)
end
