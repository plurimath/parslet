require 'spec_helper'
require_relative '../fixtures/examples/simple_xml'

RSpec.describe 'Simple XML Parser Example' do
  let(:parser) { XML.new }

  describe XML do
    describe '#text' do
      it 'parses empty text' do
        result = parser.text.parse('')
        expect(result).to eq('')
      end

      it 'parses simple text' do
        result = parser.text.parse('hello world')
        expect(result).to eq('hello world')
      end

      it 'parses text with spaces and punctuation' do
        result = parser.text.parse('some text in the tags')
        expect(result).to eq('some text in the tags')
      end

      it 'stops at angle brackets' do
        result = parser.text.parse('text')
        expect(result).to eq('text')
      end
    end

    describe '#tag method' do
      it 'parses opening tags' do
        result = parser.tag(close: false).parse('<hello>')
        expect(result).to parse_as({ name: 'hello' })
      end

      it 'parses closing tags' do
        result = parser.tag(close: true).parse('</hello>')
        expect(result).to parse_as({ name: 'hello' })
      end

      it 'parses single letter tags' do
        result = parser.tag(close: false).parse('<a>')
        expect(result).to parse_as({ name: 'a' })
      end

      it 'parses multi-letter tags' do
        result = parser.tag(close: false).parse('<body>')
        expect(result).to parse_as({ name: 'body' })
      end

      it 'parses mixed case tags' do
        result = parser.tag(close: false).parse('<MyTag>')
        expect(result).to parse_as({ name: 'MyTag' })
      end

      it 'parses closing tags with mixed case' do
        result = parser.tag(close: true).parse('</MyTag>')
        expect(result).to parse_as({ name: 'MyTag' })
      end
    end

    describe '#document (root)' do
      it 'parses simple text documents' do
        result = parser.parse('hello world')
        expect(result).to eq('hello world')
      end

      it 'parses empty documents' do
        result = parser.parse('')
        expect(result).to eq('')
      end

      it 'parses simple tag pairs with text' do
        result = parser.parse('<a>text</a>')
        expected = {
          o: { name: 'a' },
          i: 'text',
          c: { name: 'a' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses nested tags' do
        result = parser.parse('<a><b>text</b></a>')
        expected = {
          o: { name: 'a' },
          i: {
            o: { name: 'b' },
            i: 'text',
            c: { name: 'b' }
          },
          c: { name: 'a' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses the main example: <a><b>some text in the tags</b></a>' do
        result = parser.parse('<a><b>some text in the tags</b></a>')
        expected = {
          o: { name: 'a' },
          i: {
            o: { name: 'b' },
            i: 'some text in the tags',
            c: { name: 'b' }
          },
          c: { name: 'a' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses mismatched tags (parser allows this)' do
        result = parser.parse('<b><b>some text in the tags</b></a>')
        expected = {
          o: { name: 'b' },
          i: {
            o: { name: 'b' },
            i: 'some text in the tags',
            c: { name: 'b' }
          },
          c: { name: 'a' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses tags with empty content' do
        result = parser.parse('<tag></tag>')
        expected = {
          o: { name: 'tag' },
          i: [],
          c: { name: 'tag' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses multiple levels of nesting' do
        result = parser.parse('<a><b><c>deep</c></b></a>')
        expected = {
          o: { name: 'a' },
          i: {
            o: { name: 'b' },
            i: {
              o: { name: 'c' },
              i: 'deep',
              c: { name: 'c' }
            },
            c: { name: 'b' }
          },
          c: { name: 'a' }
        }
        expect(result).to parse_as(expected)
      end
    end
  end

  describe 'check function' do
    it 'validates matching tag pairs' do
      result = check('<a><b>some text in the tags</b></a>')
      expect(result).to eq('verified')
    end

    it 'handles mismatched tags by showing the structure' do
      result = check('<b><b>some text in the tags</b></a>')
      expected = {
        o: { name: 'b' },
        i: 'verified',
        c: { name: 'a' }
      }
      expect(result).to eq(expected)
    end

    it 'validates simple tag pairs' do
      result = check('<tag>content</tag>')
      expect(result).to eq('verified')
    end

    it 'validates nested matching tags' do
      result = check('<outer><inner>text</inner></outer>')
      expect(result).to eq('verified')
    end

    it 'shows structure for partially matching tags' do
      result = check('<a><b>text</b></c>')
      expected = {
        o: { name: 'a' },
        i: 'verified',
        c: { name: 'c' }
      }
      expect(result).to eq(expected)
    end

    it 'handles empty tags' do
      result = check('<empty></empty>')
      # Empty content results in an array, which doesn't match the transform rule
      expected = {
        o: { name: 'empty' },
        i: [],
        c: { name: 'empty' }
      }
      expect(result).to eq(expected)
    end
  end

  describe 'integration test' do
    it 'processes the first example correctly: <a><b>some text in the tags</b></a>' do
      # This should validate to "verified"
      result = check('<a><b>some text in the tags</b></a>')
      expect(result).to eq('verified')
    end

    it 'processes the second example correctly: <b><b>some text in the tags</b></a>' do
      # This should show the mismatched structure
      result = check('<b><b>some text in the tags</b></a>')
      expected = {
        o: { name: 'b' },
        i: 'verified',
        c: { name: 'a' }
      }
      expect(result).to eq(expected)
    end

    it 'produces the expected outputs from the example file' do
      # First example should verify
      result1 = check('<a><b>some text in the tags</b></a>')
      expect(result1).to eq('verified')

      # Second example should show mismatch structure
      result2 = check('<b><b>some text in the tags</b></a>')
      expected2 = {
        o: { name: 'b' },
        i: 'verified',
        c: { name: 'a' }
      }
      expect(result2).to eq(expected2)
    end

    it 'demonstrates the validation concept' do
      # Valid XML reduces to "verified"
      valid_xml = '<root><child>content</child></root>'
      expect(check(valid_xml)).to eq('verified')

      # Invalid XML shows the structure with mismatches
      invalid_xml = '<root><child>content</wrong></root>'
      result = check(invalid_xml)
      expect(result).to be_a(Hash)
      expect(result).to have_key(:o)
      expect(result).to have_key(:i)
      expect(result).to have_key(:c)
    end
  end
end
