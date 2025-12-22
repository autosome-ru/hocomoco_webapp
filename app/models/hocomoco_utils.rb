module HocomocoUtils
  TFCLASS_PATTERN = /(?<tfclass_name>.+) \{(?<tfclass_id>\d+(\.\d+)*)\}/
  def self.parse_tfclass_id(str); str.match(TFCLASS_PATTERN).then{|m| m && m['tfclass_id'] }; end
  def self.parse_tfclass_name(str); str.match(TFCLASS_PATTERN).then{|m| m && m['tfclass_name'] }; end
end
