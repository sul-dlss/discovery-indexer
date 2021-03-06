module DiscoveryIndexer
  module InputXml
    class PurlxmlParserStrict
      include DiscoveryIndexer::Logging

      RDF_NAMESPACE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      OAI_DC_NAMESPACE = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      MODS_NAMESPACE = 'http://www.loc.gov/mods/v3'
      FEDORA_NAMESPACE = 'info:fedora/fedora-system:def/relations-external#'

      def initialize(druid, purlxml_ng_doc)
        @purlxml_ng_doc = purlxml_ng_doc
        @druid = druid
      end

      # it parses the purlxml into a purlxml model
      # @return [PurlxmlModel] represents the purlxml as parsed based on the parser rules
      def parse
        purlxml_model = PurlxmlModel.new
        purlxml_model.druid             = @druid
        purlxml_model.public_xml        = @purlxml_ng_doc
        purlxml_model.content_metadata  = parse_content_metadata
        purlxml_model.identity_metadata = parse_identity_metadata
        purlxml_model.rights_metadata   = parse_rights_metadata
        purlxml_model.dc                = parse_dc # why do we care?
        purlxml_model.rdf               = parse_rdf
        purlxml_model.is_collection     = parse_is_collection
        purlxml_model.collection_druids = parse_predicate_druids('isMemberOfCollection', FEDORA_NAMESPACE)
        purlxml_model.constituent_druids = parse_predicate_druids('isConstituentOf', FEDORA_NAMESPACE)
        purlxml_model.dor_content_type  = parse_dor_content_type
        purlxml_model.release_tags_hash = parse_release_tags_hash
        purlxml_model.file_ids          = parse_file_ids
        purlxml_model.thumb             = parse_thumb
        purlxml_model.encoded_thumb     = parse_encoded_thumb
        purlxml_model.image_ids         = parse_image_ids
        purlxml_model.sw_image_ids      = parse_sw_image_ids
        purlxml_model.catkey            = parse_catkey
        purlxml_model.previous_catkeys  = parse_previous_catkeys
        purlxml_model.barcode           = parse_barcode
        purlxml_model.label             = parse_label
        purlxml_model.copyright         = parse_copyright
        purlxml_model.use_and_reproduction = parse_use_and_reproduction
        purlxml_model.source_id = parse_sourceid
        purlxml_model
      end

      private

      # extracts the identityMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
      def parse_identity_metadata
        @idmd_ng_doc ||= Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/identityMetadata').to_xml)
        @idmd_ng_doc = nil if !@idmd_ng_doc || @idmd_ng_doc.children.empty?
        @idmd_ng_doc
      end

      # extracts the rightsMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object or nil
      def parse_rights_metadata
        @rmd_ng_doc ||= Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/rightsMetadata').to_xml)
        @rmd_ng_doc = nil if !@rmd_ng_doc || @rmd_ng_doc.children.empty?
        @rmd_ng_doc
      end

      # extracts the dc field for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the dc for the fedora object or nil
      def parse_dc
        @dc_ng_doc ||= Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/dc:dc', 'dc' => OAI_DC_NAMESPACE).to_xml(encoding: 'utf-8'))
        @dc_ng_doc = nil if !@dc_ng_doc || @dc_ng_doc.children.empty?
        @dc_ng_doc
      end

      # extracts the rdf field for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the rdf for the fedora object or nil
      def parse_rdf
        @rdf_ng_doc ||= Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/rdf:RDF', 'rdf' => RDF_NAMESPACE).to_xml)
        @rdf_ng_doc = nil if !@rdf_ng_doc || @rdf_ng_doc.children.empty?
        @rdf_ng_doc
      end

      # extracts the release tag element for this fedora object, from the the ReleaseData element in purl xml
      # @return [Hash] the release tags for the fedora object
      def parse_release_tags_hash
        release_tags = {}
        unless @purlxml_ng_doc.nil?
          release_elements = @purlxml_ng_doc.xpath('//ReleaseData/release')
          release_elements.each do |n|
            unless n.attr('to').nil?
              release_target = n.attr('to')
              text = n.text
              release_tags[release_target] = to_boolean(text) unless text.nil?
            end
          end
        end
        release_tags
      end

      # extracts the contentMetadata for this fedora object, from the purl xml
      # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
      # @raise [DiscoveryIndexer::Errors::MissingContentMetadata] if there is no contentMetadata
      def parse_content_metadata
        @cntmd_ng_doc ||= Nokogiri::XML(@purlxml_ng_doc.root.xpath('/publicObject/contentMetadata').to_xml)
        @cntmd_ng_doc = nil if !@cntmd_ng_doc || @cntmd_ng_doc.children.empty?
        @cntmd_ng_doc
      end

      # @return true if the identityMetadata has <objectType>collection</objectType>, false otherwise
      def parse_is_collection
        identity_metadata = parse_identity_metadata
        unless identity_metadata.nil?
          object_type_nodes = identity_metadata.xpath('//objectType')
          return true if object_type_nodes.find_index { |n| %w(collection set).include? n.text.downcase }
        end
        false
      end

      # get the druids from predicate relationships in rels-ext from public_xml
      # @return [Array<String>, nil] the druids (e.g. ww123yy1234) from the rdf:resource of the predicate relationships, or nil if none
      def parse_predicate_druids(predicate, predicate_ns)
        ns_hash = { 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'pred_ns' => predicate_ns }
        xpth = "/publicObject/rdf:RDF/rdf:Description/pred_ns:#{predicate}/@rdf:resource"
        pred_nodes = @purlxml_ng_doc.xpath(xpth, ns_hash)
        pred_nodes.reject { |n| n.value.empty? }.map do |n|
          n.value.split('druid:').last
        end
      end

      # the value of the type attribute for a DOR object's contentMetadata
      #  more info about these values is here:
      #    https://consul.stanford.edu/display/chimera/DOR+content+types%2C+resource+types+and+interpretive+metadata
      #    https://consul.stanford.edu/display/chimera/Summary+of+Content+Types%2C+Resource+Types+and+their+behaviors
      # @return [String]
      def parse_dor_content_type
        content_md = parse_content_metadata
        dct = content_md ? content_md.xpath('contentMetadata/@type').text : nil
        DiscoveryIndexer::Logging.logger.debug "#{@druid} has no DOR content type (<contentMetadata> element may be missing type attribute)" if !dct || dct.empty?
        dct
      end

      # the @id attribute of resource/file elements that match the image, page, or thumb resource type, including extension
      # @return [Array<String>] filenames
      def parse_image_ids
        content_md = parse_content_metadata
        return [] if content_md.nil?
        content_md.xpath('//resource[@type="page" or @type="image" or @type="thumb"]/file[@mimetype="image/jp2"]/@id').map(&:to_s)
      end

      # the thumbnail in publicXML, falling back to the first image if no thumb node is found
      # @return [String] thumb filename with druid prepended, e.g. oo000oo0001/filename withspace.jp2
      def parse_thumb
        unless @purlxml_ng_doc.nil?
          thumb = @purlxml_ng_doc.xpath('//thumb')
          # first try and parse what is in the thumb node of publicXML, but fallback to the first image if needed
          if thumb.size == 1
            thumb.first.content
          elsif thumb.size == 0 && parse_sw_image_ids.size > 0
            parse_sw_image_ids.first
          else
            nil
          end
        end
      end

      # the thumbnail in publicXML properly URI encoded, including the slash separator
      # @return [String] thumb filename with druid prepended, e.g. oo000oo0001%2Ffilename%20withspace.jp2
      def parse_encoded_thumb
        thumb=parse_thumb
        return unless thumb
        thumb_druid=thumb.split('/').first # the druid (before the first slash)
        thumb_filename=thumb.split(/[a-zA-Z]{2}[0-9]{3}[a-zA-Z]{2}[0-9]{4}[\/]/).last # everything after the druid
        "#{thumb_druid}%2F#{URI.escape(thumb_filename)}"
      end

      # the druid and id attribute of resource/file and objectId and fileId of the
      # resource/externalFile elements that match the image, page, or thumb resource type, including extension
      # Also, prepends the corresponding druid and / specifically for Searchworks use
      # @return [Array<String>] filenames
      def parse_sw_image_ids
        content_md = parse_content_metadata
        return [] if content_md.nil?
        content_md.xpath('//resource[@type="page" or @type="image" or @type="thumb"]').map do |node|
          node.xpath('./file[@mimetype="image/jp2"]/@id').map{ |x| "#{@druid.gsub('druid:','')}/" + x } << node.xpath('./externalFile[@mimetype="image/jp2"]').map do |y|
            "#{y.attributes['objectId'].text.split(':').last}" + "/" + "#{y.attributes['fileId']}"
          end
        end.flatten
      end

      def parse_sourceid
        get_value(@purlxml_ng_doc.css('//identityMetadata/sourceId'))
      end

      def parse_copyright
        get_value(@purlxml_ng_doc.css('//rightsMetadata/copyright/human[type="copyright"]'))
      end

      def parse_use_and_reproduction
        get_value(@purlxml_ng_doc.css('//rightsMetadata/use/human[type="useAndReproduction"]'))
      end

      # the @id attribute of resource/file elements, including extension
      # @return [Array<String>] filenames
      def parse_file_ids
        content_md = parse_content_metadata
        return [] if content_md.nil?
        content_md.xpath('//resource/file/@id').map { |x| x.text }.compact
      end

      # @return catkey value from the DOR identity_metadata, or nil if there is no catkey
      def parse_catkey
        get_value(@purlxml_ng_doc.xpath("/publicObject/identityMetadata/otherId[@name='catkey']"))
      end

      # @return previous catkey values from the DOR identity_metadata as an array, or empty array if there are no previous catkeys
      def parse_previous_catkeys
        @purlxml_ng_doc.xpath("/publicObject/identityMetadata/otherId[@name='previous_catkey']").map { |node| node.content }
      end

      # @return barcode value from the DOR identity_metadata, or nil if there is no barcode
      def parse_barcode
        get_value(@purlxml_ng_doc.xpath("/publicObject/identityMetadata/otherId[@name='barcode']"))
      end

      # @return objectLabel value from the DOR identity_metadata, or nil if there is no barcode
      def parse_label
        get_value(@purlxml_ng_doc.xpath('/publicObject/identityMetadata/objectLabel'))
      end

      def get_value(node)
        (node && node.first) ? node.first.content : nil
      end

      def to_boolean(text)
        if text.nil? || text.empty?
          return false
        elsif text.downcase.eql?('true') || text.downcase == 't'
          return true
        else
          return false
        end
      end
    end
  end
end
