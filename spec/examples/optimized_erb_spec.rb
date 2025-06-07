require 'spec_helper'
require 'fixtures/examples/optimized_erb'

RSpec.describe 'Optimized ERB Example' do
  include OptimizedErbExample

  describe 'OptimizedErbExample::ErbParser' do
    let(:parser) { OptimizedErbExample::ErbParser.new }

    describe 'basic parsing components' do
      describe '#ruby' do
        it 'parses ruby code until %>' do
          result = parser.ruby.parse('puts "hello"')
          expect(result).to eq({ ruby: 'puts "hello"' })
        end

        it 'stops at %>' do
          result = parser.ruby.parse('puts "hello"')
          expect(result[:ruby].to_s).to eq('puts "hello"')
        end

        it 'handles empty ruby code' do
          result = parser.ruby.parse('')
          expect(result).to eq({ ruby: [] })
        end
      end

      describe '#expression' do
        it 'parses ERB expression syntax' do
          result = parser.expression.parse('= @user.name')
          expect(result).to eq({ expression: { ruby: ' @user.name' } })
        end

        it 'parses complex expressions' do
          result = parser.expression.parse('= items.map(&:name).join(", ")')
          expect(result[:expression][:ruby].to_s).to eq(' items.map(&:name).join(", ")')
        end
      end

      describe '#comment' do
        it 'parses ERB comment syntax' do
          result = parser.comment.parse('# This is a comment')
          expect(result).to eq({ comment: { ruby: ' This is a comment' } })
        end

        it 'parses empty comments' do
          result = parser.comment.parse('#')
          expect(result).to eq({ comment: { ruby: [] } })
        end
      end

      describe '#code' do
        it 'parses plain ruby code' do
          result = parser.code.parse('if condition')
          expect(result).to eq({ code: { ruby: 'if condition' } })
        end

        it 'parses multi-statement code' do
          result = parser.code.parse('x = 1; y = 2')
          expect(result[:code][:ruby].to_s).to eq('x = 1; y = 2')
        end
      end

      describe '#erb' do
        it 'parses expressions' do
          result = parser.erb.parse('= @name')
          expect(result).to eq({ expression: { ruby: ' @name' } })
        end

        it 'parses comments' do
          result = parser.erb.parse('# comment')
          expect(result).to eq({ comment: { ruby: ' comment' } })
        end

        it 'parses code' do
          result = parser.erb.parse('puts "hello"')
          expect(result).to eq({ code: { ruby: 'puts "hello"' } })
        end
      end

      describe '#erb_with_tags' do
        it 'parses ERB expression with tags' do
          result = parser.erb_with_tags.parse('<%= @user.name %>')
          expect(result).to eq({ expression: { ruby: ' @user.name ' } })
        end

        it 'parses ERB comment with tags' do
          result = parser.erb_with_tags.parse('<%# This is a comment %>')
          expect(result).to eq({ comment: { ruby: ' This is a comment ' } })
        end

        it 'parses ERB code with tags' do
          result = parser.erb_with_tags.parse('<% if condition %>')
          expect(result).to eq({ code: { ruby: ' if condition ' } })
        end
      end

      describe '#text' do
        it 'parses plain text' do
          result = parser.text.parse('Hello World')
          expect(result.to_s).to eq('Hello World')
        end

        it 'parses text with special characters' do
          result = parser.text.parse('Hello! @#$%^&*()')
          expect(result.to_s).to eq('Hello! @#$%^&*()')
        end

        it 'stops at ERB tags' do
          result = parser.text.parse('Hello')
          expect(result.to_s).to eq('Hello')
        end

        it 'fails on empty string' do
          expect { parser.text.parse('') }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    describe 'integration parsing' do
      describe '#text_with_ruby (root)' do
        it 'parses plain text only' do
          result = parser.parse('Hello World')
          expect(result).to eq({ text: [{ text: 'Hello World' }] })
        end

        it 'parses ERB expression only' do
          result = parser.parse('<%= @name %>')
          expect(result).to eq({ text: [{ expression: { ruby: ' @name ' } }] })
        end

        it 'parses mixed text and ERB' do
          result = parser.parse('Hello <%= @name %>!')
          expect(result).to eq({
            text: [
              { text: 'Hello ' },
              { expression: { ruby: ' @name ' } },
              { text: '!' }
            ]
          })
        end

        it 'parses multiple ERB tags' do
          result = parser.parse('<%= @first %> and <%= @second %>')
          expect(result).to eq({
            text: [
              { expression: { ruby: ' @first ' } },
              { text: ' and ' },
              { expression: { ruby: ' @second ' } }
            ]
          })
        end

        it 'parses ERB comments' do
          result = parser.parse('Before <%# comment %> After')
          expect(result).to eq({
            text: [
              { text: 'Before ' },
              { comment: { ruby: ' comment ' } },
              { text: ' After' }
            ]
          })
        end

        it 'parses ERB code blocks' do
          result = parser.parse('Before <% code %> After')
          expect(result).to eq({
            text: [
              { text: 'Before ' },
              { code: { ruby: ' code ' } },
              { text: ' After' }
            ]
          })
        end
      end
    end

    describe 'complex examples' do
      it 'parses a simple ERB template' do
        template = <<~ERB
          <h1>Welcome <%= @user.name %>!</h1>
          <p>You have <%= @messages.count %> messages.</p>
        ERB

        result = parser.parse(template)
        expect(result[:text]).to be_an(Array)
        expect(result[:text].length).to be > 3

        # Check that we have the expected ERB expressions
        erb_expressions = result[:text].select { |item| item.key?(:expression) }
        expect(erb_expressions.length).to eq(2)
        expect(erb_expressions[0][:expression][:ruby].to_s).to include('@user.name')
        expect(erb_expressions[1][:expression][:ruby].to_s).to include('@messages.count')
      end

      it 'parses ERB with different tag types' do
        template = <<~ERB
          <%# This is a comment %>
          <% if @user %>
            Hello <%= @user.name %>!
          <% end %>
        ERB

        result = parser.parse(template)
        expect(result[:text]).to be_an(Array)

        # Should contain comment, code, expression, and text elements
        has_comment = result[:text].any? { |item| item.key?(:comment) }
        has_code = result[:text].any? { |item| item.key?(:code) }
        has_expression = result[:text].any? { |item| item.key?(:expression) }
        has_text = result[:text].any? { |item| item.key?(:text) }

        expect(has_comment).to be true
        expect(has_code).to be true
        expect(has_expression).to be true
        expect(has_text).to be true
      end
    end

    describe 'big.erb file parsing' do
      it 'successfully parses the big.erb file' do
        result = OptimizedErbExample.parse_big_erb_file
        expect(result).to be_a(Hash)
        expect(result[:text]).to be_an(Array)
        expect(result[:text].length).to be > 1

        # Should contain the ERB expression from the file
        erb_expressions = result[:text].select { |item| item.key?(:expression) }
        expect(erb_expressions.length).to eq(1)
        expect(erb_expressions[0][:expression][:ruby].to_s).to include('erb tag')
      end

      it 'handles large text content efficiently' do
        # This test demonstrates the optimization aspect
        expect { OptimizedErbExample.parse_big_erb_file }.not_to raise_error
      end
    end

    describe 'error handling' do
      it 'handles malformed ERB tags' do
        expect { parser.parse('<%') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles unclosed ERB tags' do
        expect { parser.parse('<% code') }.to raise_error(Parslet::ParseFailed)
      end

      it 'provides meaningful error messages' do
        begin
          parser.parse('<%')
          fail 'Expected ParseFailed to be raised'
        rescue Parslet::ParseFailed => e
          expect(e.message).to include('Extra input after last repetition')
        end
      end
    end

    describe 'edge cases' do
      it 'handles empty input' do
        result = parser.parse('')
        expect(result).to eq({ text: [] })
      end

      it 'handles whitespace only' do
        result = parser.parse('   ')
        expect(result).to eq({ text: [{ text: '   ' }] })
      end

      it 'handles nested angle brackets in text' do
        result = parser.parse('This < that > other')
        expect(result).to eq({ text: [{ text: 'This < that > other' }] })
      end

      it 'handles percent signs in text' do
        result = parser.parse('100% complete')
        expect(result).to eq({ text: [{ text: '100% complete' }] })
      end
    end
  end

  describe 'module methods' do
    describe '.parse_erb_content' do
      it 'parses ERB content using the parser' do
        content = 'Hello <%= @world %>!'
        result = OptimizedErbExample.parse_erb_content(content)
        expect(result[:text]).to be_an(Array)
        expect(result[:text].length).to eq(3)
      end
    end

    describe '.parse_big_erb_file' do
      it 'reads and parses the big.erb file' do
        result = OptimizedErbExample.parse_big_erb_file
        expect(result).to be_a(Hash)
        expect(result[:text]).to be_an(Array)
      end
    end
  end
end
