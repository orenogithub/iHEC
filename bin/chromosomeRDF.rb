require 'rdf'
require 'rdf/turtle'
include RDF

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

# Describe chromosome (生物種、バージョン番号、可能であれば配列へのリンクを入れたい)
chromosome = RDF::Graph.new
25.times do |n|
  if n == 0
    id = RDF::URI("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#M")
    chromosome << [id, RDF.type, so.SO_0000819] #mitochondrial_chromosome
    chromosome << [id, RDFS.label, "Mitochondrial Chromosome"]
  elsif n == 23
    id = RDF::URI("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#X")
    chromosome << [id, RDF.type, so.SO_0000957] #linear_double_stranded_DNA_chromosome 
    chromosome << [id, RDFS.label, "Chromosome X"]
  elsif n ==24
    id = RDF::URI("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#Y")
    chromosome << [id, RDF.type, so.SO_0000957]
    chromosome << [id, RDFS.label, "Chromosome Y"]
  else
    id = id = RDF::URI("http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38##{n}")
    chromosome << [id, RDF.type, so.SO_0000957]
    chromosome << [id, RDFS.label, "Chromosome #{n}"]
  end 
end

chromosome = chromosome.dump(:ttl, prefixes:
{
  rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  rdfs:  "http://www.w3.org/2000/01/rdf-schema#",
  so:    "http://purl.obolibrary.org/obo/",
  chr:   "http://dbtss.hgc.jp/rdf/chromosome/9606/GRCh38#"
})
puts chromosome