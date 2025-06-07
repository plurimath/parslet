require 'spec_helper'
require_relative '../fixtures/examples/comments'

RSpec.describe 'Comments Parser Example' do
  let(:parser) { CommentsExample::ALanguage.new }

  describe CommentsExample::ALanguage do
    describe '#line_comment' do
      it 'parses line comments' do
        result = parser.line_comment.parse('// this is a comment')
        expect(result).to parse_as({ line: '// this is a comment' })
      end

      it 'parses empty line comments' do
        result = parser.line_comment.parse('//')
        expect(result).to parse_as({ line: '//' })
      end

      it 'stops at newlines' do
        result = parser.line_comment.parse('// comment')
        expect(result).to parse_as({ line: '// comment' })
      end
    end

    describe '#multiline_comment' do
      it 'parses simple multiline comments' do
        result = parser.multiline_comment.parse('/* comment */')
        expect(result).to parse_as({ multi: '/* comment */' })
      end

      it 'parses multiline comments with newlines' do
        result = parser.multiline_comment.parse("/* line1\nline2 */")
        expect(result).to parse_as({ multi: "/* line1\nline2 */" })
      end

      it 'parses empty multiline comments' do
        result = parser.multiline_comment.parse('/**/')
        expect(result).to parse_as({ multi: '/**/' })
      end
    end

    describe '#expression' do
      it 'parses single a' do
        result = parser.expression.parse('a')
        expect(result).to parse_as({ exp: { a: 'a' } })
      end

      it 'parses a with trailing spaces' do
        result = parser.expression.parse('a   ')
        expect(result).to parse_as({ exp: { a: 'a' } })
      end
    end

    describe 'root parser (lines)' do
      it 'parses simple code' do
        input = "a\na\n"
        result = parser.parse(input)

        expected = [
          { exp: { a: 'a' } },
          { exp: { a: 'a' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses code with line comments' do
        input = "a\n// line comment\na\n"
        result = parser.parse(input)

        expected = [
          { exp: { a: 'a' } },
          { line: '// line comment' },
          { exp: { a: 'a' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses code with multiline comments' do
        input = "a\n/* multiline\ncomment */\na\n"
        result = parser.parse(input)

        expected = [
          { exp: { a: 'a' } },
          { multi: "/* multiline\ncomment */" },
          { exp: { a: 'a' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'handles mixed comments and expressions on same line' do
        input = "a a a // line comment\na /* inline comment */ a\n"
        result = parser.parse(input)

        expected = [
          { exp: { a: 'a' } },
          { exp: { a: 'a' } },
          { exp: [{ a: 'a' }, { line: '// line comment' }] },
          { exp: [{ a: 'a' }, { multi: '/* inline comment */' }] },
          { exp: { a: 'a' } }
        ]
        expect(result).to parse_as(expected)
      end
    end
  end

  describe 'integration test' do
    it 'processes the main example correctly' do
      code = %q(
  a
  // line comment
  a a a // line comment
  a /* inline comment */ a
  /* multiline
  comment */
)
      result = parser.parse(code)

      # Verify the structure matches the actual output
      expect(result).to be_an(Array)
      expect(result.length).to eq(8)

      # First element: single a
      expect(result[0]).to parse_as({ exp: { a: 'a' } })

      # Second element: line comment
      expect(result[1]).to parse_as({ line: '// line comment' })

      # Third element: first a
      expect(result[2]).to parse_as({ exp: { a: 'a' } })

      # Fourth element: second a
      expect(result[3]).to parse_as({ exp: { a: 'a' } })

      # Fifth element: third a with line comment
      expect(result[4]).to parse_as({ exp: [{ a: 'a' }, { line: '// line comment' }] })

      # Sixth element: a with inline comment
      expect(result[5]).to parse_as({ exp: [{ a: 'a' }, { multi: '/* inline comment */' }] })

      # Seventh element: final a
      expect(result[6]).to parse_as({ exp: { a: 'a' } })

      # Eighth element: multiline comment
      expect(result[7]).to parse_as({ multi: "/* multiline\n  comment */" })
    end

    it 'handles various comment scenarios' do
      input = "// start comment\na /* mid */ a // end\n/* block\ncomment */ a\n"
      result = parser.parse(input)

      expected = [
        { line: '// start comment' },
        { exp: [{ a: 'a' }, { multi: '/* mid */' }] },
        { exp: [{ a: 'a' }, { line: '// end' }] },
        { multi: "/* block\ncomment */" },
        { exp: { a: 'a' } }
      ]
      expect(result).to parse_as(expected)
    end

    it 'produces the expected output from the example file' do
      # This matches the exact output shown when running the example
      code = %q(
  a
  // line comment
  a a a // line comment
  a /* inline comment */ a
  /* multiline
  comment */
)
      result = parser.parse(code)

      expected = [
        { exp: { a: 'a' } },
        { line: '// line comment' },
        { exp: { a: 'a' } },
        { exp: { a: 'a' } },
        { exp: [{ a: 'a' }, { line: '// line comment' }] },
        { exp: [{ a: 'a' }, { multi: '/* inline comment */' }] },
        { exp: { a: 'a' } },
        { multi: "/* multiline\n  comment */" }
      ]
      expect(result).to parse_as(expected)
    end
  end
end
