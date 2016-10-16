# LICENSE: MIT (see LICENSE)
require 'find'
require 'pathname'
require 'set'
require 'logger'

$log = Logger.new(STDOUT)
$log.level = Logger::INFO
$log.progname = 'sorter'

def _match_files(files, path)
  files.any? { |p|
    File.fnmatch(p.to_s, path, File::FNM_DOTMATCH | File::FNM_PATHNAME)
  }
end

class Sorter
  def initialize(disks, inclusions)
    @disks = disks
    @inclusions = inclusions
    @parents = _get_parents
  end

  def _mountpoint(path)
    @disks.include?(path)
  end

  def _get_parents
    parents = Set.new
    @inclusions.each do |e|
      e = Pathname.new e
      until e.root?
        e = e.parent
        parents.add e
      end
    end
    parents
  end

  def classify_disk(root)
    exclusions = Set.new
    inclusions = Set.new
    Find.find(root) do |path|
      if FileTest.directory?(path)
        if path != root && _mountpoint(path)
          $log.debug("Stopped at mountpoint #{path}")
          Find.prune
        end
        if _match_files(@parents, path)
          $log.debug("Descending into #{path}")
        elsif _match_files(@inclusions, path)
          $log.debug("Including #{path}")
          inclusions.add path
          Find.prune
        else
          $log.debug("Excluding #{path}")
          exclusions.add path
          Find.prune
        end
      end
    end
    return {disk: root, exclusions: exclusions, inclusions: inclusions}
  end

  def classify
    @disks.map { |disk| classify_disk(disk) }
  end
end

#
# old is an array of existing exclusions, new is a set of new ones
#
# Returns:
#   new: array of new exclusions, sorted to minimize changes
#   added: array of additions, in the same order
#   removed: array of removals, in the same order
#
def diff(old, new_s)
  new = []
  added = []
  removed = []
  # First walk through existing exclusions and remove obsolete ones
  old.each { |e|
    if new_s.include?(e)
      new.push e
    else
      removed.push e
    end
    new_s.delete(e)
  }
  # The remaining elements (sorted) are appended to the list of exclusions
  added = new_s.to_a.sort!
  new += added
  return {new: new, added: added, removed: removed}
end
