# LICENSE: MIT (see LICENSE)
require 'plist'
require 'open3'

def _walk(y, node)
  if node.kind_of?(Array)
    node.each {|n| _walk(y, n)}
  end
  if node.kind_of?(Hash)
    if node['MountPoint']
      y << node['MountPoint']
    end
    node.each {|k,n| _walk(y, n)}
  end
end

def get_disks
  exit_code, out = nil
  Open3.popen2('/usr/sbin/diskutil', 'list', '-plist') {|stdin, stdout, wait|
    stdin.close
    out = stdout.gets(nil)
    exit_code = wait.value
  }
  return nil if exit_code != 0
  return Enumerator.new do |y|
    _walk(y, Plist::parse_xml(out))
  end
end
