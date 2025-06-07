require 'spec_helper'
require_relative '../fixtures/examples/capture'

RSpec.describe 'Capture Parser Example' do
  let(:parser) { CaptureExample::CapturingParser.new }

  describe CaptureExample::CapturingParser do
    describe '#marker' do
      it 'parses uppercase letter sequences' do
        result = parser.marker.parse('CAPTURE')
        expect(result).to parse_as('CAPTURE')
      end

      it 'parses single uppercase letters' do
        result = parser.marker.parse('A')
        expect(result).to parse_as('A')
      end

      it 'fails on lowercase letters' do
        expect { parser.marker.parse('capture') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty input' do
        expect { parser.marker.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    # Note: doc_start and text_line cannot be tested in isolation as they depend on scope context
    # from the document parser. Testing them through integration tests instead.

    describe 'root parser (document)' do
      it 'parses simple documents' do
        input = "<CAPTURE\nText1\nCAPTURE"
        result = parser.parse(input)

        expected = [
          { line: "Text1\n" }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses documents with multiple lines' do
        input = "<CAPTURE\nText1\nText2\nCAPTURE"
        result = parser.parse(input)

        expected = [
          { line: "Text1\n" },
          { line: "Text2\n" }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses nested documents' do
        input = "<CAPTURE\nText1\n<FOOBAR\nText3\nText4\nFOOBAR\nText2\nCAPTURE"
        result = parser.parse(input)

        expected = [
          { line: "Text1\n" },
          { doc: [
            { line: "Text3\n" },
            { line: "Text4\n" }
          ]},
          { line: "\nText2\n" }  # Note: includes the newline before Text2
        ]
        expect(result).to parse_as(expected)
      end

      it 'handles different marker names' do
        input = "<FOOBAR\nSome text\nFOOBAR"
        result = parser.parse(input)

        expected = [
          { line: "Some text\n" }
        ]
        expect(result).to parse_as(expected)
      end

      it 'fails when end marker does not match start marker' do
        input = "<CAPTURE\nText1\nWRONG"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'integration test' do
    it 'processes the main example correctly' do
      input = "<CAPTURE\nText1\n<FOOBAR\nText3\nText4\nFOOBAR\nText2\nCAPTURE"
      result = parser.parse(input)

      # Verify the structure matches the expected nested document format
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)

      # First line
      expect(result[0]).to have_key(:line)
      expect(result[0][:line]).to parse_as("Text1\n")

      # Nested document
      expect(result[1]).to have_key(:doc)
      expect(result[1][:doc]).to be_an(Array)
      expect(result[1][:doc].length).to eq(2)
      expect(result[1][:doc][0][:line]).to parse_as("Text3\n")
      expect(result[1][:doc][1][:line]).to parse_as("Text4\n")

      # Last line (includes newline before Text2)
      expect(result[2]).to have_key(:line)
      expect(result[2][:line]).to parse_as("\nText2\n")
    end

    it 'handles simple single-level documents' do
      input = "<TEST\nHello\nWorld\nTEST"
      result = parser.parse(input)

      expected = [
        { line: "Hello\n" },
        { line: "World\n" }
      ]
      expect(result).to parse_as(expected)
    end

    it 'produces the expected output from the example file' do
      # This matches the exact output shown when running the example
      input = "<CAPTURE\nText1\n<FOOBAR\nText3\nText4\nFOOBAR\nText2\nCAPTURE"
      result = parser.parse(input)

      expected = [
        { line: "Text1\n" },
        { doc: [
          { line: "Text3\n" },
          { line: "Text4\n" }
        ]},
        { line: "\nText2\n" }
      ]
      expect(result).to parse_as(expected)
    end
  end
end
