require 'roo'
require 'rdf'
require 'rdf/turtle'
include RDF

file   = ARGV[0] || "./sample/A549_MethylSeq_reduced.xlsx"
#sample = ARGV[1] || "A549" #need to recognize it automatically 


#########################################################
#  define PREFIX
#########################################################
rdf    = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
rdfs   = RDF::Vocabulary.new("http://www.w3.org/TR/rdf-schema/#")
dct    = RDF::Vocabulary.new("http://purl.org/dc/terms/")
faldo  = RDF::Vocabulary.new("http://biohackathon.org/resource/faldo#")
so     = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
idref  = RDF::Vocabulary.new("http://identifiers.org/refseq/")
idname = RDF::Vocabulary.new("http://identifiers.org/hgnc.symbol/")
refseq = RDF::Vocabulary.new("http://www.ncbi.nlm.nih.gov/nuccore/")
gname  = RDF::Vocabulary.new("http://www.genenames.org/cgi-bin/gene_symbol_report?match=")
kero   = RDF::Vocabulary.new("http://dbtss.hgc.jp/ontology/kero.owl#")
chr    = RDF::Vocabulary.new("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#")
bs     = RDF::Vocabulary.new("http://dbtss.hgc.jp/rdf/BSseq/")
bsfile = RDF::Vocabulary.new("http://dbtss.hgc.jp/rdf/BSseqFile/")

puts "@prefix rdf: <#{RDF::URI(rdf)}> ."
puts "@prefix rdfs: <#{RDF::URI(rdfs)}> ."
puts "@prefix dct: <#{RDF::URI(dct)}> ."
puts "@prefix faldo: <#{RDF::URI(faldo)}> ."
puts "@prefix obo: <#{RDF::URI(so)}> ."
puts "@prefix kero: <#{RDF::URI(kero)}> ."
puts "@prefix chr: <#{RDF::URI(chr)}> ."
puts "@prefix file: <#{RDF::URI(bsfile)}> ."
puts "@prefix bs: <#{RDF::URI(bs)}> ."


filename = ""
if file =~ /\//
  filename = file.split("/")
  filename = filename[-1]
else
  filename = file
end

sample, _ = filename.split("_")
puts "\nfile:#{filename} a kero:MethylSeqFile .\n"

xlsx = Roo::Spreadsheet.open(file)
xlsx.each do |sheet|
  if sheet[0].class == Float
    g = RDF::Graph.new
    
    # create blank node
    id          = RDF::Node.new
    region      = RDF::Node.new
    b_node      = RDF::Node.new
    e_node      = RDF::Node.new
    up_node     = RDF::Node.new
    up_region   = RDF::Node.new
    up_b_node   = RDF::Node.new
    up_e_node   = RDF::Node.new
    body_region = RDF::Node.new
    body_node   = RDF::Node.new
    body_b_node = RDF::Node.new
    body_e_node = RDF::Node.new
    
    gene_b = 0
    gene_e = 0
    up_b   = 0
    up_e   = 0
    
    # main section
    #id    = RDF::URI("http://dbtss.hgc.jp/rdf/BSseq/#{sample}_#{sheet[0].to_i}")
    chrom = RDF::URI("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38##{sheet[2].delete("chr")}")
    
    g << [RDF::URI("http://dbtss.hgc.jp/rdf/BSseqFile/#{filename}"), kero.hasGene, id]
    g << [id, RDF.type, so.SO_0000704] #gene
    g << [id, RDF.type, kero.Region]
    g << [id, dct.identifier, "#{sample}_#{sheet[0].to_i}"]
    
    sheet[1].split(",").each do |refseq|
      g << [id, kero.refseqId, refseq]
      g << [id, RDFS.seeAlso, RDF::URI("http://identifiers.org/refseq/#{refseq}")]
      g << [id, RDFS.seeAlso, RDF::URI("http://www.ncbi.nlm.nih.gov/nuccore/#{refseq}")]
    end
    
    g << [id, RDFS.label, sheet[6]]
    g << [id, RDFS.seeAlso, RDF::URI("http://identifiers.org/hgnc.symbol/#{sheet[6]}")]
    g << [id, RDFS.seeAlso, RDF::URI("http://www.genenames.org/cgi-bin/gene_symbol_report?match=#{sheet[6]}")]
    g << [id, RDFS.comment, sheet[7]]
    
    g << [id, kero.mRNAlength, sheet[8].to_i]
    g << [id, kero.theoreticalNumCpG, sheet[9].to_i + sheet[12].to_i]
    g << [id, kero.experimentNumCpGDepthOver5, sheet[10].to_i + sheet[13].to_i]
    
    # position and direction
    if sheet[3] == "+"
      g << [b_node, RDF.type, faldo.ForwardStrandPosition]
      g << [e_node, RDF.type, faldo.ForwardStrandPosition]
      g << [up_b_node, RDF.type, faldo.ForwardStrandPosition]
      g << [up_e_node, RDF.type, faldo.ForwardStrandPosition]
      g << [body_b_node, RDF.type, faldo.ForwardStrandPosition]
      g << [body_e_node, RDF.type, faldo.ForwardStrandPosition]
      gene_b = sheet[4].to_i - 1000
      gene_e = sheet[5].to_i
      up_b   = sheet[4].to_i - 1000
      up_e   = sheet[4].to_i - 1
    else
      g << [b_node, RDF.type, faldo.ReverseStrandPosition]
      g << [e_node, RDF.type, faldo.ReverseStrandPosition]
      g << [up_b_node, RDF.type, faldo.ReverseStrandPosition]
      g << [up_e_node, RDF.type, faldo.ReverseStrandPosition]
      g << [body_b_node, RDF.type, faldo.ReverseStrandPosition]
      g << [body_e_node, RDF.type, faldo.ReverseStrandPosition]
      gene_b = sheet[4].to_i
      gene_e = sheet[5].to_i + 1000
      up_b   = sheet[5].to_i + 1
      up_e   = sheet[5].to_i + 1000
    end
    
    # FALDO for gene
    g << [id, faldo.location, region]
    
    g << [region, RDF.type, faldo.Region]
    g << [region, faldo.begin, b_node]
    g << [region, faldo.end, e_node]
    g << [region, faldo.reference, chrom]
    
    g << [b_node, RDF.type, faldo.ExactPosition]
    g << [b_node, faldo.position, gene_b]
    g << [b_node, faldo.reference, chrom]
    
    g << [e_node, RDF.type, faldo.ExactPosition]
    g << [e_node, faldo.position, gene_e]
    g << [e_node, faldo.reference, chrom]
    
    # Upstream region of TSS
    g << [id, kero.upstreamRegion, up_node]
    g << [up_node, RDF.type, kero.UpstreamRegion1000]
    g << [up_node, RDF.type, so.SO_0001679] #transcription_regulatory_region
    g << [up_node, RDFS.label, "#{sheet[6]} upstream region"]
    g << [up_node, kero.theoreticalNumCpG, sheet[9].to_i]
    g << [up_node, kero.experimentNumCpGDepthOver5, sheet[10].to_i]
    g << [up_node, kero.avgMethylRatioDepthOver5, sheet[11].to_f]
    
    g << [up_node, faldo.location, up_region]
    g << [up_region, RDF.type, faldo.Region]
    g << [up_region, faldo.begin, up_b_node]
    g << [up_region, faldo.end, up_e_node]
    g << [up_region, faldo.reference, chrom]
    
    g << [up_b_node, RDF.type, faldo.ExactPosition]
    g << [up_b_node, faldo.position, up_b]
    g << [up_b_node, faldo.reference, chrom]
    
    g << [up_e_node, RDF.type, faldo.ExactPosition]
    g << [up_e_node, faldo.position, up_e]
    g << [up_e_node, faldo.reference, chrom]
    
    # Gene body
    g << [id, kero.geneBody, body_node]
    g << [body_node, RDF.type, kero.GeneBody]
    g << [body_node, RDF.type, so.SO_0000836] #mRNA_region
    g << [body_node, RDFS.label, "#{sheet[6]} transcript region"]
    g << [body_node, kero.theoreticalNumCpG, sheet[12].to_i]
    g << [body_node, kero.experimentNumCpGDepthOver5, sheet[13].to_i]
    g << [body_node, kero.avgMethylRatioDepthOver5, sheet[14].to_f]
    
    g << [body_node, faldo.location, body_region]
    g << [body_region, RDF.type, faldo.Region]
    g << [body_region, faldo.begin, body_b_node]
    g << [body_region, faldo.end, body_e_node]
    g << [body_region, faldo.reference, chrom]
    
    g << [body_b_node, RDF.type, faldo.ExactPosition]
    g << [body_b_node, faldo.position, sheet[4].to_i]
    g << [body_b_node, faldo.reference, chrom]
    
    g << [body_e_node, RDF.type, faldo.ExactPosition]
    g << [body_e_node, faldo.position, sheet[5].to_i]
    g << [body_e_node, faldo.reference, chrom]

    g = g.dump(:ttl, prefixes:
    {
      rdf:    "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      rdfs:   "http://www.w3.org/2000/01/rdf-schema#",
      dct:    "http://purl.org/dc/terms/",
      faldo:  "http://biohackathon.org/resource/faldo#",
      so:     "http://purl.obolibrary.org/obo/",
      idref:  "http://identifiers.org/refseq/",
      idname: "http://identifiers.org/hgnc.symbol/",
      refseq: "http://www.ncbi.nlm.nih.gov/nuccore/",
      gname:  "http://www.genenames.org/cgi-bin/gene_symbol_report?match=",
      kero:   "http://dbtss.hgc.jp/ontology/kero.owl#",
      chr:    "http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#",
      bs:     "http://dbtss.hgc.jp/rdf/BSseq/",
      bsfile: "http://dbtss.hgc.jp/rdf/BSseqFile/"
    })
    puts g.gsub(/^@.+\n/, "")
    g.clear
  end
end
puts xlsx.info