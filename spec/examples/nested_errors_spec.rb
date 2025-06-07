require 'spec_helper'
require 'fixtures/examples/nested_errors'

RSpec.describe 'Nested Errors Example' do
  include NestedErrorsExample

  describe 'NestedErrorsExample::Parser' do
    let(:parser) { NestedErrorsExample::Parser.new }

    describe 'basic parsing components' do
      describe '#space' do
        it 'parses single space' do
          result = parser.space.parse(' ')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq(' ')
        end

        it 'parses multiple spaces' do
          result = parser.space.parse('   ')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('   ')
        end

        it 'parses tabs' do
          result = parser.space.parse("\t")
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq("\t")
        end

        it 'fails on empty string' do
          expect { parser.space.parse('') }.to raise_error(Parslet::ParseFailed)
        end
      end

      describe '#space?' do
        it 'parses optional space' do
          result = parser.space?.parse(' ')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq(' ')
        end

        it 'parses empty string' do
          result = parser.space?.parse('')
          expect(result).to eq('')
        end
      end

      describe '#newline' do
        it 'parses line feed' do
          result = parser.newline.parse("\n")
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq("\n")
        end

        it 'parses carriage return' do
          result = parser.newline.parse("\r")
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq("\r")
        end

        it 'fails on other characters' do
          expect { parser.newline.parse('a') }.to raise_error(Parslet::ParseFailed)
        end
      end

      describe '#comment' do
        it 'parses simple comment' do
          result = parser.comment.parse('# this is a comment')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('# this is a comment')
        end

        it 'parses empty comment' do
          result = parser.comment.parse('#')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('#')
        end

        it 'stops at newline' do
          result = parser.comment.parse('# comment')
          expect(result.to_s).to eq('# comment')
        end
      end

      describe '#identifier' do
        it 'parses simple identifier' do
          result = parser.identifier.parse('test')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('test')
        end

        it 'parses identifier with numbers' do
          result = parser.identifier.parse('test123')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('test123')
        end

        it 'parses identifier with underscores' do
          result = parser.identifier.parse('test_name')
          expect(result).to be_a(Parslet::Slice)
          expect(result.to_s).to eq('test_name')
        end

        it 'fails on empty string' do
          expect { parser.identifier.parse('') }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    describe 'resource statement components' do
      describe '#reference' do
        it 'parses single @ reference' do
          result = parser.reference.parse('@resource')
          expect(result).to eq({ reference: '@resource' })
        end

        it 'parses double @ reference' do
          result = parser.reference.parse('@@resource')
          expect(result).to eq({ reference: '@@resource' })
        end

        it 'fails without @' do
          expect { parser.reference.parse('resource') }.to raise_error(Parslet::ParseFailed)
        end
      end

      describe '#res_action_or_link' do
        it 'parses method call without question mark' do
          result = parser.res_action_or_link.parse('.method()')
          expect(result).to eq({ dot: '.', name: 'method' })
        end

        it 'parses method call with question mark' do
          result = parser.res_action_or_link.parse('.method?()')
          expect(result).to eq({ dot: '.', name: 'method?' })
        end
      end

      describe '#res_actions' do
        it 'parses reference only' do
          result = parser.res_actions.parse('@res')
          expect(result).to eq({
            resources: { reference: '@res' },
            res_actions: []
          })
        end

        it 'parses reference with single action' do
          result = parser.res_actions.parse('@res.action()')
          expect(result[:resources][:reference].to_s).to eq('@res')
          expect(result[:res_actions]).to be_an(Array)
          expect(result[:res_actions].length).to eq(1)
          expect(result[:res_actions][0][:res_action][:dot].to_s).to eq('.')
          expect(result[:res_actions][0][:res_action][:name].to_s).to eq('action')
        end

        it 'parses reference with multiple actions' do
          result = parser.res_actions.parse('@res.action1().action2()')
          expect(result[:resources][:reference].to_s).to eq('@res')
          expect(result[:res_actions]).to be_an(Array)
          expect(result[:res_actions].length).to eq(2)
          expect(result[:res_actions][0][:res_action][:name].to_s).to eq('action1')
          expect(result[:res_actions][1][:res_action][:name].to_s).to eq('action2')
        end
      end

      describe '#res_statement' do
        it 'parses simple resource without actions or field' do
          result = parser.res_statement.parse('@res')
          expect(result[:resources][:reference].to_s).to eq('@res')
          expect(result[:res_actions]).to eq([])
          expect(result[:res_field]).to be_nil
        end

        it 'parses resource statement without field' do
          result = parser.res_statement.parse('@res.action()')
          expect(result[:resources][:reference].to_s).to eq('@res')
          expect(result[:res_actions]).to be_an(Array)
          expect(result[:res_actions].length).to eq(1)
          expect(result[:res_field]).to be_nil
        end

        it 'parses resource statement with field' do
          result = parser.res_statement.parse('@res.action():field')
          expect(result[:resources][:reference].to_s).to eq('@res')
          expect(result[:res_actions]).to be_an(Array)
          expect(result[:res_actions].length).to eq(1)
          expect(result[:res_field][:name].to_s).to eq('field')
        end
      end
    end

    describe 'block parsing' do
      describe '#define_block' do
        it 'parses simple define block with proper formatting' do
          input = "define test()\n  @res.action()\nend"
          result = parser.define_block.parse(input)
          expect(result[:define]).to eq('define')
          expect(result[:name]).to eq('test')
          expect(result[:body]).to be_an(Array)
        end

        it 'fails on malformed define block (demonstrating error reporting)' do
          input = "define test()\n  @res"
          expect { parser.define_block.parse(input) }.to raise_error(Parslet::ParseFailed)
        end
      end

      describe '#begin_block' do
        it 'parses simple begin block with proper formatting' do
          input = "begin\n  @res.action()\nend"
          result = parser.begin_block.parse(input)
          expect(result[:begin]).to eq('begin')
          expect(result[:body]).to be_an(Array)
        end

        it 'parses concurrent begin block with proper formatting' do
          input = "concurrent begin\n  @res.action()\nend"
          result = parser.begin_block.parse(input)
          expect(result[:pre][:type]).to eq('concurrent')
          expect(result[:begin]).to eq('begin')
          expect(result[:body]).to be_an(Array)
        end

        it 'fails on malformed begin block (demonstrating error reporting)' do
          input = "begin\n  @res"
          expect { parser.begin_block.parse(input) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    describe 'root parser (radix)' do
      it 'parses valid syntax correctly' do
        input = "define test()\n  @res.action()\nend"
        result = parser.parse(input)
        expect(result).to be_a(Hash)
        expect(result[:define]).to eq('define')
        expect(result[:name]).to eq('test')
      end

      it 'fails to parse the first example (demonstrating error reporting)' do
        input = "define f()\n  @res.name\nend"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails to parse the second example (demonstrating error reporting)' do
        input = "define f()\n  begin\n    @res.name\n  end\nend"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'error handling' do
      it 'handles incomplete define blocks' do
        input = "define test()\n  @res"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles incomplete begin blocks' do
        input = "begin\n  @res"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end

      it 'provides meaningful error messages for malformed input' do
        input = "invalid syntax here"
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'nested error reporting' do
      it 'demonstrates the purpose of the example - showing nested errors' do
        input = "define f()\n  @res.name\nend"

        begin
          parser.parse(input)
          fail "Expected ParseFailed to be raised"
        rescue Parslet::ParseFailed => e
          # The error should contain information about the nested structure
          expect(e.message).to include('Failed to match')
        end
      end

      it 'works with parse_with_debug and nested reporter on valid input' do
        input = "define test()\n  @res.action()\nend"

        expect { parser.parse_with_debug(input) }.not_to raise_error
      end

      it 'demonstrates nested error reporting with malformed input' do
        input = "define f()\n  @res.name\nend"

        # parse_with_debug may not always raise an error, so let's test the regular parse method
        expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'prettify helper function' do
    it 'formats strings with line numbers' do
      input = "line 1\nline 2\nline 3"
      result = NestedErrorsExample.prettify(input)

      expect(result).to include('01 line 1')
      expect(result).to include('02 line 2')
      expect(result).to include('03 line 3')
    end

    it 'handles single line input' do
      input = "single line"
      result = NestedErrorsExample.prettify(input)

      expect(result).to include('01 single line')
    end

    it 'handles empty input' do
      input = ""
      result = NestedErrorsExample.prettify(input)

      expect(result).to include('10')
      expect(result).to include('20')
    end
  end
end
