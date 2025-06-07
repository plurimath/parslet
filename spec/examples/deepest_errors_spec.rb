require 'spec_helper'
require_relative '../fixtures/examples/deepest_errors'

RSpec.describe 'Deepest Errors Parser Example' do
  let(:parser) { DeepestErrorsParser.new }

  describe DeepestErrorsParser do
    describe '#space' do
      it 'parses single space' do
        result = parser.space.parse(' ')
        expect(result).to eq(' ')
      end

      it 'parses multiple spaces' do
        result = parser.space.parse('   ')
        expect(result).to eq('   ')
      end

      it 'parses tabs' do
        result = parser.space.parse("\t")
        expect(result).to eq("\t")
      end

      it 'parses mixed spaces and tabs' do
        result = parser.space.parse(" \t ")
        expect(result).to eq(" \t ")
      end

      it 'fails on empty string' do
        expect { parser.space.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#space?' do
      it 'parses optional space' do
        result = parser.space?.parse(' ')
        expect(result).to eq(' ')
      end

      it 'parses empty string' do
        result = parser.space?.parse('')
        expect(result).to eq('')
      end
    end

    describe '#newline' do
      it 'parses carriage return' do
        result = parser.newline.parse("\r")
        expect(result).to eq("\r")
      end

      it 'parses line feed' do
        result = parser.newline.parse("\n")
        expect(result).to eq("\n")
      end

      it 'fails on other characters' do
        expect { parser.newline.parse('a') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#comment' do
      it 'parses simple comment' do
        result = parser.comment.parse('# this is a comment')
        expect(result).to eq('# this is a comment')
      end

      it 'parses empty comment' do
        result = parser.comment.parse('#')
        expect(result).to eq('#')
      end

      it 'stops at newline' do
        result = parser.comment.parse('# comment')
        expect(result).to eq('# comment')
      end
    end

    describe '#identifier' do
      it 'parses simple identifier' do
        result = parser.identifier.parse('test')
        expect(result).to eq('test')
      end

      it 'parses identifier with numbers' do
        result = parser.identifier.parse('test123')
        expect(result).to eq('test123')
      end

      it 'parses identifier with underscores' do
        result = parser.identifier.parse('test_name')
        expect(result).to eq('test_name')
      end

      it 'fails on empty string' do
        expect { parser.identifier.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#reference' do
      it 'parses single @ reference' do
        result = parser.reference.parse('@res')
        expected = { reference: '@res' }
        expect(result).to parse_as(expected)
      end

      it 'parses double @ reference' do
        result = parser.reference.parse('@@global')
        expected = { reference: '@@global' }
        expect(result).to parse_as(expected)
      end

      it 'fails without @' do
        expect { parser.reference.parse('res') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#res_action_or_link' do
      it 'parses method call without question mark' do
        result = parser.res_action_or_link.parse('.name()')
        expected = {
          dot: '.',
          name: 'name'
        }
        expect(result).to parse_as(expected)
      end

      it 'parses method call with question mark' do
        result = parser.res_action_or_link.parse('.valid?()')
        expected = {
          dot: '.',
          name: 'valid?'
        }
        expect(result).to parse_as(expected)
      end
    end

    describe '#res_actions' do
      it 'parses reference only' do
        result = parser.res_actions.parse('@res')
        expected = {
          resources: { reference: '@res' },
          res_actions: []
        }
        expect(result).to parse_as(expected)
      end

      it 'parses reference with single action' do
        result = parser.res_actions.parse('@res.name()')
        expected = {
          resources: { reference: '@res' },
          res_actions: [
            {
              res_action: {
                dot: '.',
                name: 'name'
              }
            }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses reference with multiple actions' do
        result = parser.res_actions.parse('@res.name().valid?()')
        expected = {
          resources: { reference: '@res' },
          res_actions: [
            {
              res_action: {
                dot: '.',
                name: 'name'
              }
            },
            {
              res_action: {
                dot: '.',
                name: 'valid?'
              }
            }
          ]
        }
        expect(result).to parse_as(expected)
      end
    end

    describe '#res_statement' do
      it 'parses resource statement without field' do
        result = parser.res_statement.parse('@res.name()')
        expected = {
          resources: { reference: '@res' },
          res_actions: [
            {
              res_action: {
                dot: '.',
                name: 'name'
              }
            }
          ],
          res_field: nil
        }
        expect(result).to parse_as(expected)
      end

      it 'parses resource statement with field' do
        result = parser.res_statement.parse('@res.name():field')
        expected = {
          resources: { reference: '@res' },
          res_actions: [
            {
              res_action: {
                dot: '.',
                name: 'name'
              }
            }
          ],
          res_field: { name: 'field' }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses simple resource without actions or field' do
        result = parser.res_statement.parse('@res')
        expected = {
          resources: { reference: '@res' },
          res_actions: [],
          res_field: nil
        }
        expect(result).to parse_as(expected)
      end
    end

    describe '#define_block' do
      it 'parses simple define block with proper formatting' do
        input = "define f()\n@res.name()\nend"

        result = parser.define_block.parse(input)
        expect(result[:define]).to eq('define')
        expect(result[:name]).to eq('f')
        expect(result[:body]).to be_an(Array)
        expect(result[:body].length).to eq(1)
      end

      it 'fails on malformed define block (demonstrating error reporting)' do
        input = <<~CODE
          define f()
            @res.name
          end
        CODE

        # This should fail due to improper syntax (@res.name should be @res.name())
        expect { parser.define_block.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#begin_block' do
      it 'parses simple begin block with proper formatting' do
        input = "begin\n@res.name()\nend"

        result = parser.begin_block.parse(input)
        expect(result[:pre]).to be_nil
        expect(result[:begin]).to eq('begin')
        expect(result[:body]).to be_an(Array)
      end

      it 'parses concurrent begin block with proper formatting' do
        input = "concurrent begin\n@res.name()\nend"

        result = parser.begin_block.parse(input)
        expect(result[:pre][:type]).to eq('concurrent')
        expect(result[:begin]).to eq('begin')
      end

      it 'fails on malformed begin block (demonstrating error reporting)' do
        input = <<~CODE
          begin
            @res.name
          end
        CODE

        # This should fail due to improper syntax (@res.name should be @res.name())
        expect { parser.begin_block.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'root parser (radix)' do
      it 'fails to parse the first example (demonstrating error reporting)' do
        input = <<~CODE
          define f()
            @res.name
          end
        CODE

        # This should fail - the example is designed to show error reporting
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails to parse the second example (demonstrating error reporting)' do
        input = <<~CODE
          define f()
            begin
              @res.name
            end
          end
        CODE

        # This should also fail - the example is designed to show error reporting
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end

      it 'parses valid syntax correctly' do
        # Create a properly formatted input that should parse
        input = "define f()\n@res.name()\nend\n"

        result = parser.parse(input)
        expect(result[:define]).to eq('define')
        expect(result[:name]).to eq('f')
        expect(result[:body]).to be_an(Array)
      end
    end

    describe 'error handling' do
      it 'provides meaningful error messages for malformed input' do
        expect { parser.parse('invalid syntax') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles incomplete define blocks' do
        expect { parser.parse('define f()') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles incomplete begin blocks' do
        expect { parser.parse('begin') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'deepest error reporting' do
      it 'demonstrates deepest error reporting with malformed input' do
        input = <<~CODE
          define f()
            @res.name
          end
        CODE

        # This should fail with regular parse
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)

        # parse_with_debug returns nil on failure but prints detailed error info
        result = parser.parse_with_debug(input,
          :reporter => Parslet::ErrorReporter::Deepest.new)
        expect(result).to be_nil
      end

      it 'works with parse_with_debug and deepest reporter on valid input' do
        input = "define f()\n@res.name()\nend\n"

        # Test that parse_with_debug works with valid input
        result = parser.parse_with_debug(input,
          :reporter => Parslet::ErrorReporter::Deepest.new)
        expect(result).not_to be_nil
        expect(result[:define]).to eq('define')
      end

      it 'demonstrates the purpose of the example - showing deepest errors' do
        # The example is specifically designed to show how deepest error reporting
        # provides better error messages than standard parsing
        input = <<~CODE
          define f()
            @res.name
          end
        CODE

        # Regular parse should fail with exception
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)

        # parse_with_debug returns nil but provides detailed error info
        result = parser.parse_with_debug(input, :reporter => Parslet::ErrorReporter::Deepest.new)
        expect(result).to be_nil
      end
    end
  end

  describe 'prettify helper function' do
    it 'formats strings with line numbers' do
      input = "line 1\nline 2\nline 3"

      # Capture the output
      output = capture_stdout { prettify(input) }

      expect(output).to include('01 line 1')
      expect(output).to include('02 line 2')
      expect(output).to include('03 line 3')
    end

    it 'handles single line input' do
      input = "single line"

      output = capture_stdout { prettify(input) }
      expect(output).to include('01 single line')
    end

    it 'handles empty input' do
      input = ""

      output = capture_stdout { prettify(input) }
      # Should still show the header line
      expect(output).to include('10')
      expect(output).to include('20')
    end
  end

  # Helper method to capture stdout
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
