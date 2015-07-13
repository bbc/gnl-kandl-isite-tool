require 'app/lib/xml-handler'

describe 'Applying XSLT' do
  it 'Should transform given xml with given xslt' do
    handler = XmlHandler.new
    handler.init('<foo>hey</foo>')
    handler.applyTransformation(
        '<?xml version="1.0"?>'\
        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'\
        '<xsl:template match="/">'\
        '<p><xsl:value-of select="foo"/></p>'\
        '</xsl:template>'\
        '</xsl:stylesheet>'
    )
    expect(handler.asString).to eq("<?xml version=\"1.0\"?>\n<p>hey</p>")
  end

  it 'should not fail the hudson job' do
      expect(true).to eq(false)
  end
end

