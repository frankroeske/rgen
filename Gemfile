# THIS FILE IS AUTOGENERATED, DO NOT EDIT
require 'yaml'
require 'pathname'
def source_gems(gem_source, gems)
  workspace_config_path = File.join(File.dirname(__FILE__), '..', 'Workspace.yaml')
  workspace = File.file?(workspace_config_path) ? YAML.load_file(workspace_config_path) : {}
  abort 'Workspace syntax error' unless workspace.is_a?(Hash)
  gems.each do |gem_args|
    found = false
    gem_args = [gem_args] if gem_args.is_a?(String)
    name = gem_args.first
    begin gem *(gem_args << {:source => gem_source}); next end if workspace.nil?
    env = (workspace['environment'] || 'production')
    ((workspace['common'] || []) + ((workspace['environments'] || {})[env] || [])).each do |source_info|
      (source_info['gems'] || []).each do |gem_info|
        next unless name == (gem_info.is_a?(String) ? gem_info : gem_info['name'])
        if !source_info['url'].nil?
          gem *(gem_args << {:source => source_info['url']})
        elsif !source_info['path'].nil?
          path = gem_info['path'] || name
          source_path = Pathname(source_info['path']).absolute? ? source_info['path'] : File.join('..', source_info['path'])
		      gem_path = Pathname(path).absolute? ? path : File.join(source_path, path)
		      Dir.chdir(gem_path) { abort "Can't bundle dependency from #{gem_path}" unless system('bundle') }
          gem *(gem_args <<  {:path => gem_path})
        elsif !source_info['git'].nil?
          gem *(gem_args << {:git => (source_info['git'] + '/' + (gem_info['path'] || name)), :ref => gem_info['ref'],
              :branch => gem_info['branch'], :tag => gem_info['tag']})
        else
          abort "Unknown source type #{source_info.to_s}"
        end
        found = true
        break
      end
      break if found
    end
    gem *(gem_args << {:source => gem_source}) unless found
  end
end

require 'yaml'
project = YAML.load(File.read(File.join(File.dirname(__FILE__), 'Project.yaml')))
deps = project['dependencies'] || {}
deps = 
  if deps.is_a?(Hash)
    deps
  else
    {'http://rubygems.org' => deps}
  end
is_gem = project['is_gem'].nil? ? true : project['is_gem']
deps.each do |source, gems|
  source_gems(source, gems.map do |d|
      if d.is_a?(String)
        d
      else
        if is_gem
          d['name']
        else
          dep_args = [d['name']]
          dep_args.concat(if d['version'].nil?; []; else d['version'].is_a?(String) ? [d['version']] : d['version'] end)
          dep_args
        end
      end
    end)
end
if is_gem
  gemspec :name => project['name'], :path => File.dirname(__FILE__)
end