module Pushka
  class DirChecker
    def initialize
      @pwd = Dir.pwd
    end

    def validate_dir!
      msg = 'Directory should contain at least Rakefile and config.yml files'
      raise msg unless dir_valid?
    end

    def prepare_dir!
      raise "Directory #{@pwd} not empty!" unless Dir.empty? @pwd
      `cp -r #{BASE_DIR}/src/* .`
    end

    def dir_valid?
      %[Rakefile hosts.json].reduce(false) { |acc, f| acc + File.exists?(f) }
    end
  end
end
