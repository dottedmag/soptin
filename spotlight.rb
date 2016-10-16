# LICENSE: MIT (see LICENSE)
require 'plist'
require 'date'
require 'tempfile'

SD = '/.Spotlight-V100'
CF = 'VolumeConfiguration.plist'

def _read_config(path)
  File.open(path+SD+'/'+CF, 'r') { |f|
    Plist::parse_xml(f)
  }
end

def get_exclusions(root)
  _read_config(root)['Exclusions']
end

def now
  DateTime.now.new_offset(0).strftime('%FT%TZ')
end

def set_exclusions(root, exclusions)
  config = _read_config(root)
  config['Exclusions'] = exclusions
  config['ConfigurationModificationDate'] = now
  t = Tempfile.new(CF, root+SD)
  t.write(Plist::Emit.dump(config))
  t.close
  File.rename(t.path, root+SD+'/'+CF)
ensure
  t.unlink
end

def reload
  system('/bin/launchctl', 'stop', 'com.apple.metadata.mds')
  system('/bin/launchctl', 'start', 'com.apple.metadata.mds')
end
