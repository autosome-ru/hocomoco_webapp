require 'open-uri'
require 'json'

def json_at_url(url)
  timeout = 1
  stepcount = 0
  while true
    begin
      raw_text = open(url, read_timeout: timeout, &:read)
      return JSON.parse(raw_text)
    rescue
      sleep(timeout)
      timeout *= 2
      stepcount += 1
      if stepcount >= 2
        $stderr.puts "#{url} loading failed"
        return nil
      end
    end
  end
end

def each_result_in_jaspar_by_url(url, &block)
  return enum_for(:each_result_in_jaspar_by_url, url)  unless block_given?
  while url
    obj = json_at_url(url)
    obj['results'].each(&block)
    url = obj['next']
  end
end

def each_result_in_jaspar(query_term, &block)
  # We don't ask the latest motif because it can throw out other species motifs (AR / Ar)
  each_result_in_jaspar_by_url("http://jaspar.genereg.net/api/v1/matrix/?collection=CORE&tax_group=Vertebrates&version=all&search=#{query_term}&format=json&page_size=50",&block)
end

def jaspar_matrix_for_gene(gene_name)
  each_result_in_jaspar(gene_name).select{|motif|
    motif['name'].split('::').any?{|motif_part| # Ahr::Arnt should be found by "Ahr" query
      # To dismiss queries with match query but not exactly equal to it ("AR" erroneously matches "ARNT")
      # Mouse "Ar" and human "AR" should both be found simultaneously
      motif_part.upcase == gene_name.upcase
    }
  }.map{|obj|
    json_at_url(obj['url']) # matrix details
  }.compact
end

desc 'get matrix ids from JASPAR corresponding to HOCOMOCO TFs'
task :hocomoco2jaspar_mappping => :environment do
  File.open('public/hocomoco_jaspar_mapping.txt', 'w') do |fw|
    ['human', 'mouse'].each{|species|
      ['mono', 'di'].each{|arity|
        Motif.in_bundle(species: species, arity: arity).each{|motif|
          $stderr.puts motif.full_name
          fw.puts [motif.full_name, jaspar_matrix_for_gene(motif.gene_name).map(&:to_json)].join("\t")
        }
      }
    }
  end
end
