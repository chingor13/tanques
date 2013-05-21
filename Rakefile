require 'active_support'
require 'active_support/inflector'

desc 'Compile a bot'
task :compile do
  bot = ENV['BOT']
  if bot.nil?
    puts "no bot specified"
    exit(1)
  end

  source = File.read(File.expand_path("../bots/#{bot}.rb", __FILE__)).split("\n")
  source.reject!{|line| line.match(/^\s*require/)}

  File.open(File.expand_path("../compiled/#{bot}.rb", __FILE__), "w") do |f|
    source.each do |line|
      if matches = line.match(/\s*include\s(Strategies::.*)/)
        strategy_content(matches[1]).each do |l|
          f.puts l
        end
      else
        f.puts line
      end
    end
  end
end

def strategy_content(class_name)
  source = File.read(File.expand_path("../bots/#{class_name.strip.underscore}.rb", __FILE__)).split("\n")
  source.select{|line| line.match(/\s{4,}.*/)}
end
