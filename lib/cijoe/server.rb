require 'sinatra'
require 'erb'

class CIJoe
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      # thanks integrity!
      def bash_color_codes(string)
        string.gsub("\e[0m", '</span>').
          gsub("\e[31m", '<span class="color31">').
          gsub("\e[32m", '<span class="color32">').
          gsub("\e[33m", '<span class="color33">').
          gsub("\e[34m", '<span class="color34">').
          gsub("\e[35m", '<span class="color35">').
          gsub("\e[36m", '<span class="color36">').
          gsub("\e[37m", '<span class="color37">')
      end
    end

    get '/' do
      joe.build
      erb(:template, {}, :joe => joe)
    end

    def joe
      @joe ||= CIJoe.new(@user, @project)
    end

    attr_accessor :user, :project
    def self.start(user, project)
      CIJoe::Server.run! \
        :user    => user,
        :project => project
    end

    def self.parse_args(args = ARGV)
      name_with_owner = args[0]

      if name_with_owner.nil? || !name_with_owner.include?('/')
        puts "Whoops! I need a project name (e.g. mojombo/grit)"
        abort "  $ cijoe project_name"
      else
        user, project = name_with_owner.split('/')
      end

      if !File.exists?(project)
        puts "Whoops! You need to do this first:"
        abort "  $ git clone git@github.com:#{name_with_owner}.git #{project}"
      end

      [ user, project ]
    end
  end
end
