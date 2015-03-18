require "spec_helper"

describe DiscoveryIndexer::Writer::SolrClient do
      
  VCR.configure do |config|
    config.allow_http_connections_when_no_cassette = true
    config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
    config.hook_into :webmock 
  end
  
  describe ".process" do
    it "should add an item to the solr index" do
     druid = "tn629pk3948"
      
      purl_model=nil
      VCR.use_cassette("available_purl_xml") do
        purl_model =  DiscoveryIndexer::InputXml::Purlxml.new(druid).load()
      end
      
      mods_model = nil
      VCR.use_cassette("available_mods_xml") do
        mods_model =  DiscoveryIndexer::InputXml::Modsxml.new(druid).load()
      end
      
      mapper = DiscoveryIndexer::Mapper::IndexerlMapper.new(druid, mods_model, purl_model)
      solr_doc =  mapper.map   
      solr_connector = RSolr.connect 'http://localhost:8983/solr/'
      expect{DiscoveryIndexer::Writer::SolrClient.add(solr_doc, solr_connector)}.not_to raise_error
    end
    
    it "should delete an item from solr index" do
    end
  end
  
  describe ".delete" do
    it "should delete an item from solr index" do       
      solr_connector = RSolr.connect 'http://localhost:8983/solr/'
      expect{DiscoveryIndexer::Writer::SolrClient.add({:id=>"tn629pk3948"}, solr_connector)}.not_to raise_error
    end
  end
end