enki_config = YAML.load(IO.read(File.expand_path("#{RAILS_ROOT}/config/enki.yml"))).symbolize_keys
Rakismet::KEY  = enki_config[:rakismet]['key']  || ''
Rakismet::URL  = enki_config[:rakismet]['url']  || ''
Rakismet::HOST = enki_config[:rakismet]['host'] || ''