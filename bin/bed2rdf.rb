require 'rdf'
require 'rdf/turtle'
include RDF

input_file = ARGV[0] || "../sample/tmp.bed"

#########################################################
#  define PREFIX
#########################################################
rdf      = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
rdfs     = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
dct      = RDF::Vocabulary.new("http://purl.org/dc/terms/")
sio      = RDF::Vocabulary.new("http://semanticscience.org/resource/")
obo      = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
faldo    = RDF::Vocabulary.new("http://biohackathon.org/resource/faldo#")
data     = RDF::Vocabulary.new("http://ftp.ebi.ac.uk/pub/databases/blueprint/data/homo_sapiens/GRCh37/Venous_blood/S00622/alternatively_activated_macrophage/Bisulfite-Seq/CNAG/S0062252.hyper_meth.bs_call.20140106.bb#")
resource = RDF::Vocabulary.new("http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/")

puts "@prefix rdf: <#{RDF::URI(rdf)}> ."
puts "@prefix rdfs: <#{RDF::URI(rdfs)}> ."
puts "@prefix dct: <#{RDF::URI(dct)}> ."
puts "@prefix sio: <#{RDF::URI(sio)}> ."
puts "@prefix obo: <#{RDF::URI(obo)}> ."
puts "@prefix faldo: <#{RDF::URI(faldo)}> ."
puts "@prefix data: <#{RDF::URI(data)}> ."
puts "@prefix resource: <#{RDF::URI(resource)}> ."


File.open(input_file).each do |line|
  g = Graph.new
  
  chr, s, e, local_id, value = line.chomp.split("\t")
  id = RDF::URI("http://ftp.ebi.ac.uk/pub/databases/blueprint/data/homo_sapiens/GRCh37/Venous_blood/S00622/alternatively_activated_macrophage/Bisulfite-Seq/CNAG/S0062252.hyper_meth.bs_call.20140106.bb##{local_id}")
  region = RDF::URI("http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/#{chr}_#{s}_#{e}")
  s_node = RDF::URI("http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/#{chr}_#{s}")
  e_node = RDF::URI("http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/#{chr}_#{e}")
  chrom  = RDF::URI("http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/#{chr}")

  g << [id, RDF.type, RDF::URI("http://purl.obolibrary.org/obo/SO_0001720")] ##SO_0001720: epigenetically_modified_region 
  g << [id, rdfs.label, local_id]
  g << [id, dct.identifier, local_id]
  g << [id, RDF::URI("http://semanticscience.org/resource/SIO_000300"), value.to_i] ##SIO_000300: has_value
  
  # FALDO location
  g << [id, faldo.location, region]
  g << [region, RDF.type, faldo.Region]
  g << [region, rdfs.label, "chromosome #{chr}:#{s}-#{e}"]
  g << [region, dct.identifier, "#{chr}_#{s}-#{e}"]
  g << [region, faldo.begin, s_node]
  g << [region, faldo.end, e_node]
  g << [region, faldo.reference, chrom]
  
  g << [s_node, RDF.type, faldo.ExactPosition]
  g << [s_node, RDF.type, faldo.StrandedPosition]
  g << [s_node, rdfs.label, "chromosome #{chr}:#{s}"]
  g << [s_node, dct.identifier, "#{chr}_#{s}"]
  g << [s_node, faldo.position, s.to_i]
  g << [s_node, faldo.reference, chrom]
  
  g << [e_node, RDF.type, faldo.ExactPosition]
  g << [e_node, RDF.type, faldo.StrandedPosition]
  g << [e_node, rdfs.label, "chromosome #{chr}:#{e}"]
  g << [e_node, dct.identifier, "#{chr}_#{e}"]
  g << [e_node, faldo.position, e.to_i]
  g << [e_node, faldo.reference, chrom]
  

  g = g.dump(:ttl, prefixes:{
    rdf:      "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    rdfs:     "http://www.w3.org/2000/01/rdf-schema#",
    dct:      "http://purl.org/dc/terms/",
    faldo:    "http://biohackathon.org/resource/faldo#",
    obo:      "http://purl.obolibrary.org/obo/",
    resource: "http://rdf.ebi.ac.uk/resource/ensembl/homo_sapiens/hg19/",
    sio:      "http://semanticscience.org/resource/",
    data:     "http://ftp.ebi.ac.uk/pub/databases/blueprint/data/homo_sapiens/GRCh37/Venous_blood/S00622/alternatively_activated_macrophage/Bisulfite-Seq/CNAG/S0062252.hyper_meth.bs_call.20140106.bb#",
  })
  puts g.gsub(/^@.+\n/, "")
  g.clear
end





