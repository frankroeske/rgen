require 'digest'

module RGen

module Util

# The FileChangeDetector detects changes in a set of files.
# Changes are detected between successive calls to check_files with a give set of files.
# Changes include files being added, removed or having changed their content.
#
class FileChangeDetector

  FileInfo = Struct.new(:timestamp, :digest)

  # Create a FileChangeDetector, options include:
  #
  #  :file_added
  #    a proc which is called when a file is added, receives the filename
  #
  #  :file_removed
  #    a proc which is called when a file is removed, receives the filename
  #
  #  :file_changed
  #    a proc which is called when a file is changed, receives the filename
  #
  def initialize(options={})
    @file_added = options[:file_added]
    @file_removed = options[:file_removed]
    @file_changed = options[:file_changed]
    @file_info = {}
  end

  # Checks if any of the files has changed compared to the last call of check_files.
  # When called for the first time on a new object, all files will be reported as being added.
  # 
  def check_files(files)
    files_before = @file_info.keys
    used_files = {} 
    files.each do |file|
      used_files[file] = true
      if @file_info[file]
        if @file_info[file].timestamp != File.atime(file)
          @file_info[file].timestamp = File.atime(file)
          digest = calc_digest(file)
          if @file_info[file].digest != digest
            @file_info[file].digest = digest 
            @file_changed && @file_changed.call(file)
          end
        end
      else
        @file_info[file] = FileInfo.new
        @file_info[file].timestamp = File.atime(file)
        @file_info[file].digest = calc_digest(file)
        @file_added && @file_added.call(file)
      end
    end
    files_before.each do |file|
      if !used_files[file]
        @file_info.delete(file)
        @file_deleted && @file_deleted.call(file)
      end
    end
  end

  private

  def calc_digest(file)
    sha1 = Digest::SHA1.new
    sha1.file(file)
    sha1.hexdigest
  end

end

end

end

