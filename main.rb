# LICENSE: MIT (see LICENSE)
require 'optparse'
require 'logger'
require './disklist'
require './sorter'
require './spotlight'

$log = Logger.new(STDOUT)
$log.level = Logger::INFO
$log.progname = 'main'

DEF_INC = Set.new ['/Applications', '/Users/*/Applications',
                   '/Library/Fonts', '/System/Library/Fonts',
                   '/Library/PreferencePanes']

def apply_exclusions(classification)
  classification.each { |c|
    old = get_exclusions(c[:disk])
    diff = diff(old, c[:exclusions])
    set_exclusions(c[:disk], diff[:new])
  }
end

def run
  options = {dry_run: false}
  OptionParser.new { |opts|
    opts.banner = 'Usage: soptin [PATH [PATH..]]'
    opts.on('-n', '--dry-run', 'Do not write changes to disk') { |v|
      options.dry_run = true
    }
    opts.on_tail('-h', '--help', 'Show this message') { |v|
      puts opts
      exit
    }
  }.parse!

  disks = Set.new(get_disks)
  inclusions = (if ARGV.any? then ARGV else DEF_INC end)

  s = Sorter.new(disks, inclusions)
  c = s.classify

  c.each { |cc|
    $log.debug("Disk #{cc[:disk]}")
    $log.debug('Exclusions:')
    cc[:exclusions].each { |e| $log.debug("  #{e}") }
    $log.debug('Inclusions:')
    cc[:inclusions].each { |e| $log.debug("  #{e}") }
  }

  if not options[:dry_run]
    apply_exclusions(c)
    reload
  end
end

run
