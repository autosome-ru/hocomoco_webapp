require 'json'

desc 'Collect previous motif names (hocomoco-9 to hocomoco-12)'
task :collect_previous_motif_names => :environment do
  File.open('previous_motif_names.json','w') do |fw|
    previous_names_by_motif = Motif.all.map{|d| [d.name, d.previous_names] }.to_h
    fw.puts(previous_names_by_motif.to_json)
  end
end
