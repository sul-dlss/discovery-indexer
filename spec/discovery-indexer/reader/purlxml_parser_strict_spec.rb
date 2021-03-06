require 'spec_helper'

describe DiscoveryIndexer::InputXml::PurlxmlParserStrict do

  let(:fake_druid) { 'oo000oo0000' }
  let(:fedora_ns) { 'info:fedora/fedora-system:def/relations-external#' }
  let(:parser) { described_class.new(fake_druid, nil) }

  before :all do
    @available_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item.xml'), nil, 'UTF-8')
    @identity_metadata = '  <identityMetadata>    <sourceId source="sul">V0401_b1_1.01</sourceId>    <objectId>druid:tn629pk3948</objectId>    <objectCreator>DOR</objectCreator>    <objectLabel>Lecture 1</objectLabel>    <objectType>item</objectType>    <adminPolicy>druid:ww057vk7675</adminPolicy>    <displayType>image</displayType>    <otherId name="label">Lecture 1</otherId> <otherId name="barcode">barcodey</otherId> <otherId name="catkey">12345</otherId> <otherId name="previous_catkey">000</otherId> <otherId name="previous_catkey">999</otherId>    <otherId name="uuid">08d544da-d459-11e2-8afb-0050569b3c3c</otherId>    <tag>Project:V0401 mccarthyism:vhs</tag>    <tag> Process:Content Type:Media</tag>    <tag> JIRA:DIGREQ-592</tag>    <tag> SMPL:video:ua</tag>    <tag> Registered By:gwillard</tag>    <tag>Remediated By : 4.6.6.2</tag>  </identityMetadata>'
    @rights_metadata = ' <rightsMetadata>   <copyright><human type="copyright">Test copyright statement. All rights reserved unless otherwise indicated.</human></copyright>  <access type="discover">      <machine>        <world/>      </machine>    </access>    <access type="read">      <machine>        <world/>      </machine>    </access>    <use>      <human type="useAndReproduction">Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).</human>    </use>    <use>      <human type="creativeCommons"/>      <machine type="creativeCommons"/>    </use>  </rightsMetadata>'
    @content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>      <file id="tn629pk3948_sl.mp4" mimetype="video/mp4" size="3615267858">                </file>    </resource>    <resource sequence="2" id="tn629pk3948_2" type="image">      <label>Image of media (1 of 3)</label>      <file id="tn629pk3948_img_1.jp2" mimetype="image/jp2" size="919945">        <imageData width="1777" height="2723"/>      </file>    </resource>    <resource sequence="3" id="tn629pk3948_3" type="image">      <label>Image of media (2 of 3)</label>      <file id="tn629pk3948_img_2.jp2" mimetype="image/jp2" size="719940">        <imageData width="2560" height="1475"/>      </file>    </resource>    <resource sequence="4" id="tn629pk3948_4" type="image">      <label>Image of media (3 of 3)</label>      <file id="tn629pk3948_img_3.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource>  <resource sequence="5" id="tn629pk3948_5" type="page">      <label>Page with Media Information</label>      <file id="tn629pk3948_pg_1.pdf" mimetype="application/pdf" size="411054"><imageData width="1547" height="1379"/></file> <file id="tn629pk3948_pg_1.jp2" mimetype="image/jp2" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource> <resource sequence="6" id="tn629pk3948_6" type="page">      <label>PDF with Media Information</label>      <file id="tn629pk3948_pg_1.pdf" mimetype="application/pdf" size="411054">        <imageData width="1547" height="1379"/>      </file>    </resource><resource sequence="7" id="tn629pk3948_7" type="thumb"><label>Thumbnail</label><file id="tn629pk3948_thumb_1.jp2" mimetype="image/jp2" size="411054"><imageData width="1547" height="1379"/></file></resource><resource sequence="8" id="tn629pk3948_8" type="thumb"><label>Thumbnail</label><file id="tn629pk3948_thumb_2.jp2" mimetype="image/jp2" size="411054"><imageData width="1547" height="1379"/></file></resource><resource id="tn629pk3948_9" sequence="9" type="page"><label>Cover: Carey\'s American atlas.</label><externalFile fileId="2542A.jp2" mimetype="image/jp2" objectId="druid:cg767mn6478" resourceId="cg767mn6478_1"><imageData width="6475" height="4747"/></externalFile><relationship objectId="druid:cg767mn6478" type="alsoAvailableAs"/></resource><resource id="tn629pk3948_10" sequence="10" thumb="yes" type="page"><label>Title Page: Carey\'s American atlas.</label><externalFile fileId="2542B.jp2" mimetype="image/jp2" objectId="druid:jw923xn5254" resourceId="jw923xn5254_1"><imageData width="3139" height="4675"/></externalFile><relationship objectId="druid:jw923xn5254" type="alsoAvailableAs"/></resource><resource id="tn629pk3948_11" sequence="11" type="image"><label>British Possessions in North America.</label><externalFile fileId="2542001.jp2" mimetype="image/jp2" objectId="druid:wn461xh4882" resourceId="wn461xh4882_1"><imageData width="6633" height="5305"/></externalFile><relationship objectId="druid:wn461xh4882" type="alsoAvailableAs"/></resource></contentMetadata>'
    @blank_content_metadata = ' <contentMetadata objectId="tn629pk3948" type="media">    <resource sequence="1" id="tn629pk3948_1" type="video">      <label>Tape 1</label>    </resource></contentMetadata>'
    @dc = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">    <dc:identifier>V0401_b1_1.01</dc:identifier>    <dc:identifier>V0401</dc:identifier>    <dc:title>Lecture 1</dc:title>    <dc:date>2003-01-27</dc:date>    <dc:format>1 tape</dc:format>    <dc:format>VHS</dc:format>    <dc:format>video/mpeg</dc:format>    <dc:type>MovingImage</dc:type>    <dc:contributor>Frantz, Marge (Speaker)</dc:contributor>    <dc:subject>Anti-Communist Movements--United States</dc:subject>    <dc:subject>McCarthy, Joseph, 1908-1957</dc:subject>    <dc:relation type="repository">Stanford University. Libraries. Department of Special Collections and University Archives https://purl.stanford.edu/tn629pk3948</dc:relation>    <dc:rights>Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).     </dc:rights>    <dc:language>eng</dc:language>    <dc:relation type="collection">Marge Frantz lectures on McCarthyism, 2003</dc:relation>  </oai_dc:dc>'
    @rdf = '<rdf:RDF xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">    <rdf:Description rdf:about="info:fedora/druid:tn629pk3948">      <fedora:isMemberOf rdf:resource="info:fedora/druid:yk804rq1656"/>      <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:yk804rq1656"/>    </rdf:Description>  </rdf:RDF>'
  end

  describe '#parse' do
    before(:each) do
      allow(parser).to receive(:parse_content_metadata).and_return(@content_metadata)
      allow(parser).to receive(:parse_identity_metadata)
      allow(parser).to receive(:parse_rights_metadata)
      allow(parser).to receive(:parse_dc)
      allow(parser).to receive(:parse_rdf)
      allow(parser).to receive(:parse_catkey)
      allow(parser).to receive(:parse_previous_catkeys)
      allow(parser).to receive(:parse_barcode)
      allow(parser).to receive(:parse_label)
      allow(parser).to receive(:parse_copyright)
      allow(parser).to receive(:parse_use_and_reproduction)
      allow(parser).to receive(:parse_sourceid)
      allow(parser).to receive(:parse_is_collection)
      allow(parser).to receive(:parse_predicate_druids)
      allow(parser).to receive(:parse_dor_content_type)
      allow(parser).to receive(:parse_file_ids)
      allow(parser).to receive(:parse_image_ids)
      allow(parser).to receive(:parse_sw_image_ids)
    end
    it 'calls parse methods to populate the required fields in the model' do
      allow(parser).to receive(:parse_identity_metadata) { 'identityMetadata' }
      allow(parser).to receive(:parse_rights_metadata) { 'rightsMetadata' }
      allow(parser).to receive(:parse_dc) { 'dc' }
      allow(parser).to receive(:parse_rdf) { 'rdf' }
      allow(parser).to receive(:parse_label) { 'label' }

      model = parser.parse
      expect(model.druid).to eq(fake_druid)
      expect(model.public_xml).to be_nil
      expect(model.content_metadata).to eq(@content_metadata)
      expect(model.identity_metadata).to eq('identityMetadata')
      expect(model.rights_metadata).to eq('rightsMetadata')
      expect(model.dc).to eq('dc')
      expect(model.rdf).to eq('rdf')
      expect(model.label).to eq('label')
    end
    it 'collection_druids populated from #parse_predicate_druids with isMemberOfCollection' do
      coll_druids = ['ab123cd4567', '666']
      allow(parser).to receive(:parse_predicate_druids).with('isConsituentOf', fedora_ns)
      expect(parser).to receive(:parse_predicate_druids).with('isMemberOfCollection', fedora_ns).and_return(coll_druids)
      model = parser.parse
      expect(model.collection_druids).to eq coll_druids
    end
    it 'consituent_druids populated from #parse_predicate_druids with isConsituentOf' do
      constituent_druids = ['666', '777', '888']
      allow(parser).to receive(:parse_predicate_druids).with('isMemberOfCollection', fedora_ns)
      expect(parser).to receive(:parse_predicate_druids).with('isConstituentOf', fedora_ns).and_return(constituent_druids)
      model = parser.parse
      expect(model.constituent_druids).to eq constituent_druids
    end
  end

  describe '#parse_identity_metadata' do
    it 'returns the identity metadata stream for the valid public xml' do
      im = described_class.new('', @available_purl_xml_ng_doc).send(:parse_identity_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('identityMetadata')
      expect(im.root.xpath('objectId').text).to eql('druid:tn629pk3948')
      expect(im).to be_equivalent_to(Nokogiri::XML(@identity_metadata))
    end

    it "returns nil when the public xml doesn't have identity metadata" do
      public_xml_no_identity = Nokogiri::XML("<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@rights_metadata}</publicObject>")
      im = described_class.new('', public_xml_no_identity).send(:parse_identity_metadata)
      expect(im).to be_nil
    end
  end

  describe '#parse_rights_metadata' do
    it 'returns the rights metadata stream for the valid public xml' do
      im = described_class.new('', @available_purl_xml_ng_doc).send(:parse_rights_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('rightsMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rights_metadata))
    end

    it "returns nil when the public xml doesn't have rights metadata" do
      public_xml_no_rights = Nokogiri::XML("<publicObject id='druid:aa111aa1111'>#{@content_metadata}#{@identity_metadata}</publicObject>")
      rm = described_class.new('', public_xml_no_rights).send(:parse_rights_metadata)
      expect(rm).to be_nil
    end
  end

  describe '#parse_dc' do
    it 'returns the Nokogiri XML Document from dc metadata in purl public xml' do
      im = described_class.new('', @available_purl_xml_ng_doc).send(:parse_dc)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('dc')
      expect(im).to be_equivalent_to(Nokogiri::XML(@dc))
    end

    it 'returns nil for the metadata without dc' do
      public_xml_no_dc = Nokogiri::XML("<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>")
      dcm = described_class.new('', public_xml_no_dc).send(:parse_dc)
      expect(dcm).to be_nil
    end
  end

  describe '#parse_thumb' do
    it 'returns the thumb from publicxml' do
      purlxml = described_class.new('tn629pk3948', @available_purl_xml_ng_doc)
      expect(purlxml.send(:parse_thumb)).to eq 'tn629pk3948/tn629pk3948_thumb_1.jp2'
      expect(purlxml.send(:parse_encoded_thumb)).to eq 'tn629pk3948%2Ftn629pk3948_thumb_1.jp2'
    end
    it 'returns the first image when there is no thumb in publicxml' do
      alternate_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item_2.xml'), nil, 'UTF-8')
      purlxml = described_class.new('druid:bg210vm0680', alternate_purl_xml_ng_doc)
      expect(purlxml.send(:parse_thumb)).to eq 'bg210vm0680/bookCover.jp2'
      expect(purlxml.send(:parse_encoded_thumb)).to eq 'bg210vm0680%2FbookCover.jp2'
    end
    it 'returns the first image with an encoded space' do
      alternate_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item_image_with_space.xml'), nil, 'UTF-8')
      purlxml = described_class.new('druid:bg210vm0680', alternate_purl_xml_ng_doc)
      expect(purlxml.send(:parse_thumb)).to eq 'bg210vm0680/bookCover withspace.jp2'
      expect(purlxml.send(:parse_encoded_thumb)).to eq 'bg210vm0680%2FbookCover%20withspace.jp2'
    end
    it 'returns nil when there are no images in publicxml' do
      alternate_purl_xml_ng_doc = Nokogiri::XML(open('spec/fixtures/available_purl_xml_item_no_image.xml'), nil, 'UTF-8')
      purlxml=described_class.new('bg210vm0680', alternate_purl_xml_ng_doc)
      expect(purlxml.send(:parse_thumb)).to be_nil
      expect(purlxml.send(:parse_encoded_thumb)).to be_nil
    end
  end

  describe '#parse_rdf' do
    it 'returns the rdf for the valid public xml' do
      im = described_class.new('', @available_purl_xml_ng_doc).send(:parse_rdf)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('RDF')
      expect(im).to be_equivalent_to(Nokogiri::XML(@rdf))
    end

    it 'returns nil for the metadata without rdf' do
      public_xml_no_rdf = Nokogiri::XML("<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@content_metadata}</publicObject>")
      rdfm = described_class.new('', public_xml_no_rdf).send(:parse_rdf)
      expect(rdfm).to be_nil
    end
  end

  describe '#parse_release_tags_hash' do
    it 'parses the release tags from ReleaseData in public XML' do
      release_tags_hash = described_class.new('', @available_purl_xml_ng_doc).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq('revs_stage' => true, 'sw_prod' => false, 'sw_preview' => false)
    end
    it 'returns empty release tags from pulic XML in the absence of ReleaseData element' do
      reduced_purl_xml_ng = @available_purl_xml_ng_doc.clone
      reduced_purl_xml_ng.search('//ReleaseData').remove
      release_tags_hash = described_class.new('', reduced_purl_xml_ng).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq({})
    end
    it 'returns empty release tags from nil pulic XML' do
      release_tags_hash = described_class.new('', nil).send(:parse_release_tags_hash)
      expect(release_tags_hash).to eq({})
    end
  end

  describe '#parse_copyright' do
    it 'parses the copyright statement correctly' do
      copyright = described_class.new('', @available_purl_xml_ng_doc).send(:parse_copyright)
      expect(copyright).to eq('Test copyright statement. All rights reserved unless otherwise indicated.')
    end
  end

  describe '#parse_use_and_reproduction' do
    it 'parses the use and reproduction statement correctly' do
      use_and_reproduction = described_class.new('', @available_purl_xml_ng_doc).send(:parse_use_and_reproduction)
      expect(use_and_reproduction).to eq('Digital recordings from this collection may be accessed freely. These files may not be reproduced or used for any purpose without permission. For permission requests, please contact Stanford University Department of Special Collections  University Archives (speccollref@stanford.edu).')
    end
  end

  describe '#parse_content_metadata' do
    it 'returns the content metadata stream for the valid public xml' do
      im = described_class.new('', @available_purl_xml_ng_doc).send(:parse_content_metadata)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('contentMetadata')
      expect(im).to be_equivalent_to(Nokogiri::XML(@content_metadata))
    end

    it "returns nil when the public xml doesn't have content metadata" do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      cm = described_class.new('', Nokogiri::XML(public_xml_no_content)).send(:parse_content_metadata)
      expect(cm).to be_nil
    end
  end

  describe 'Parse File and Image IDs' do
    it 'returns empty array when no content metadata is present' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      pm = described_class.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_image_ids)).to be_empty
      expect(pm.send(:parse_file_ids)).to be_empty
      expect(pm.send(:parse_sw_image_ids)).to be_empty
    end

    it 'returns nil when content metadata is present but no image, page, or thumb resource types are present' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@blank_content_metadata}</publicObject>"
      pm = described_class.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_image_ids)).to be_empty
    end

    it 'returns nil when content metadata is present but no image, page, or thumb resource types are present' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@blank_content_metadata}</publicObject>"
      pm = described_class.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_sw_image_ids)).to be_empty
    end

    it 'returns nil when content metadata is present but no ids are present in the file tags' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}#{@blank_content_metadata}</publicObject>"
      pm = described_class.new('', Nokogiri::XML(public_xml_no_content))
      expect(pm.send(:parse_file_ids)).to be_empty
    end

    it 'returns ids from resource/file tag when present if resource type is image, page, or thumb' do
      pm = described_class.new('tn629pk3948', @available_purl_xml_ng_doc)
      expect(pm.send(:parse_image_ids)).to eq(["tn629pk3948_img_1.jp2", "tn629pk3948_img_2.jp2", "tn629pk3948_img_3.jp2", "tn629pk3948_pg_1.jp2", "tn629pk3948_thumb_1.jp2", "tn629pk3948_thumb_2.jp2"])
    end

    it 'returns objectIds and fileIds from resource/externalFile tag if resource type is image, page, or thumb' do
      pm = described_class.new('tn629pk3948', @available_purl_xml_ng_doc)
      expect(pm.send(:parse_sw_image_ids)).to eq(["tn629pk3948/tn629pk3948_img_1.jp2", "tn629pk3948/tn629pk3948_img_2.jp2", "tn629pk3948/tn629pk3948_img_3.jp2", "tn629pk3948/tn629pk3948_pg_1.jp2", "tn629pk3948/tn629pk3948_thumb_1.jp2", "tn629pk3948/tn629pk3948_thumb_2.jp2", "cg767mn6478/2542A.jp2", "jw923xn5254/2542B.jp2", "wn461xh4882/2542001.jp2"])
    end
  end

  describe '#parse_catkey' do
    it 'parses the catkey correctly' do
      catkey = described_class.new('tn629pk3948', @available_purl_xml_ng_doc).send(:parse_catkey)
      expect(catkey).to eq('12345')
    end
  end

  describe '#parse_previous_catkeys' do
    it 'parses the previous catkeys correctly' do
      previous_catkeys = described_class.new('tn629pk3948', @available_purl_xml_ng_doc).send(:parse_previous_catkeys)
      expect(previous_catkeys).to eq(['000','999'])
    end
  end

  describe '#parse_barcode' do
    it 'parses the barcode correctly' do
      barcode = described_class.new('tn629pk3948', @available_purl_xml_ng_doc).send(:parse_barcode)
      expect(barcode).to eq('barcodey')
    end
  end

  describe '#parse_label' do
    it 'parses the label correctly' do
      label = described_class.new('tn629pk3948', @available_purl_xml_ng_doc).send(:parse_label)
      expect(label).to eq('Lecture 1')
    end
  end

  describe '#parse_dor_content_type' do
    it 'returns valid dor content type for valid druid' do
      content_type = described_class.new('', @available_purl_xml_ng_doc).send(:parse_dor_content_type)
      expect(content_type).to eq('media')
    end

    it 'returns nil dor content type if there is no content metadata' do
      public_xml_no_content = "<publicObject id='druid:aa111aa1111'>#{@rights_metadata}#{@identity_metadata}</publicObject>"
      content_type = described_class.new('', Nokogiri::XML(public_xml_no_content)).send(:parse_dor_content_type)
      expect(content_type).to be_nil
    end
  end

  describe '#parse_predicate_druids' do
    let(:public_xml_ng) do
      Nokogiri::XML <<-EOF
        <publicObject id='druid:#{fake_druid}'>
          <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="#{fedora_ns}">
            <rdf:Description rdf:about="info:fedora/druid:#{fake_druid}">
              <fedora:isMemberOf rdf:resource="info:fedora/druid:xh235dd9059"/>
              <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:xh235dd9059"/>
              <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:aa097bm8879"/>
              <fedora:isConstituentOf rdf:resource="info:fedora/druid:hj097bm8879"/>
              <fedora:isEmpty/>
            </rdf:Description>
          </rdf:RDF>
        </publicObject>
        EOF
    end
    let(:parser) { described_class.new('', public_xml_ng) }
    it 'gets all druids for the desired predicate and only that predicate' do
      expect(parser.send(:parse_predicate_druids, 'isMemberOfCollection', fedora_ns)).to eq ['xh235dd9059', 'aa097bm8879']
      expect(parser.send(:parse_predicate_druids, 'isConstituentOf', fedora_ns)).to eq ['hj097bm8879']
    end
    it 'returns nil when there are no matching predicates' do
      expect(parser.send(:parse_predicate_druids, 'hasConstituent', fedora_ns)).to eq []
    end
    it 'ignores predicate matches that have no object' do
      expect(parser.send(:parse_predicate_druids, 'isEmpty', fedora_ns)).to eq []
    end
  end

  describe '#parse_is_collection' do
    it 'parses the is_collection correctly' do
      is_collection = described_class.new('tn629pk3948', @available_purl_xml_ng_doc).send(:parse_is_collection)
      expect(is_collection).to be_falsey
    end
  end

end
