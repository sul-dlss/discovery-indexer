require 'discovery-indexer/errors'
require 'discovery-indexer/logging'

require 'discovery-indexer/reader/purlxml'
require 'discovery-indexer/reader/purlxml_reader'
require 'discovery-indexer/reader/purlxml_parser_strict'
require 'discovery-indexer/reader/purlxml_model'

require 'discovery-indexer/reader/modsxml'
require 'discovery-indexer/reader/modsxml_reader'

require 'discovery-indexer/general_mapper'
require 'discovery-indexer/collection'

# require 'utilities/extract_sub_targets'

module DiscoveryIndexer
  PURL_DEFAULT = 'https://purl.stanford.edu'
end
