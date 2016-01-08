require 'rdf'
require 'rdf/turtle'

file = ARGV[0] || "./sample/ChIP_sample.xls"


#########################################################
#  define PREFIX
#########################################################
rdfs   = RDF::Vocabulary.new("http://www.w3.org/TR/rdf-schema/#")
faldo  = RDF::Vocabulary.new("http://biohackathon.org/resource/faldo#")
so     = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
kero   = RDF::Vocabulary.new("http://dbtss.hgc.jp/kero.owl#")

puts "@prefix rdfs: <#{RDF::URI(rdfs)}> ."
puts "@prefix faldo: <#{RDF::URI(faldo)}> ."
puts "@prefix so: <#{RDF::URI(so)}> ."
puts "@prefix kero: <#{RDF::URI(kero)}> ."

File.open(file).each do |line|
  unless line =~ /name|^#|^\s/
    g = RDF::Graph.new
    
    chr, start, last, length, abs_summit, pileup, pvalue, fold_enrichment, qvalue, name, fwd_gene, rev_gene = line.chomp.split("\t")
    
    region = RDF::Node.new
    b_node = RDF::Node.new
    e_node = RDF::Node.new
    
    id = RDF::URI("http://dbtss.hgc.jp/rdf/ChIPseq/#{name}")
    
    g << [id, RDF.type, so.SO_0001697]      #ChIP_seq_region
    g << [id, kero.binding, so.SO_0001706]  #H3K4_trimethylation
    g << [id, rdfs.label, name]
    
    g << [id, kero.length, length.to_i]
    g << [id, kero.abs_summit, abs_summit.to_i]
    g << [id, kero.pileup, pileup.to_f]
    g << [id, kero.pvalue, pvalue.to_f]
    g << [id, kero.fold_enrichment, fold_enrichment.to_f]
    g << [id, kero.qvalue, qvalue.to_f]
    
    if fwd_gene
      fwd_gene = fwd_gene.split(",")
      fwd_gene.each do |gene|
        g << [id, kero.fwd_gene, gene]
      end
    end
    
    if rev_gene
      rev_gene = rev_gene.split(",")
      rev_gene.each do |gene|
        g << [id, kero.rev_gene, gene]
      end
    end
    
    g << [id, faldo.location, region]
    
    g << [region, RDF.type, faldo.Region]
    g << [region, faldo.begin, b_node]
    g << [region, faldo.end, e_node]

    g << [b_node, RDF.type, faldo.ExactPosition]
    g << [b_node, RDF.type, faldo.ForwardStrandPosition]
    g << [b_node, faldo.position, start.to_i]
    g << [b_node, faldo.reference, chr]
    
    g << [e_node, RDF.type, faldo.ExactPosition]
    g << [e_node, RDF.type, faldo.ForwardStrandPosition]
    g << [e_node, faldo.position, last.to_i]
    g << [e_node, faldo.reference, chr]

    g = g.dump(:ttl, prefixes:
    {
      rdf:   "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      rdfs:  "http://www.w3.org/TR/rdf-schema/#",
      so:    "http://purl.obolibrary.org/obo/",
      faldo: "http://biohackathon.org/resource/faldo#",
      kero:  "http://dbtss.hgc.jp/kero.owl#"
    })
    puts g.gsub(/^@.+\n/, "")
    g.clear
  end
end

