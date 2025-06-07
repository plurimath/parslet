require 'spec_helper'
require_relative '../fixtures/examples/erb'

RSpec.describe 'ERB Parser Example' do
  let(:parser) { ErbParser.new }
  let(:transform) { ErbTransform.new }

  describe ErbParser do
    describe '#ruby' do
      it 'parses ruby code until %>' do
        result = parser.ruby.parse('x + 1')
        expected = { ruby: 'x + 1' }
        expect(result).to parse_as(expected)
      end

      it 'parses complex ruby expressions' do
        result = parser.ruby.parse('User.find(1).name')
        expected = { ruby: 'User.find(1).name' }
        expect(result).to parse_as(expected)
      end

      it 'stops at %>' do
        result = parser.ruby.parse('x + 1')
        expected = { ruby: 'x + 1' }
        expect(result).to parse_as(expected)
      end

      it 'handles empty ruby code' do
        result = parser.ruby.parse('')
        expected = { ruby: [] }
        expect(result).to parse_as(expected)
      end
    end

    describe '#expression' do
      it 'parses expression with equals sign' do
        result = parser.expression.parse('= x + 1')
        expected = { expression: { ruby: ' x + 1' } }
        expect(result).to parse_as(expected)
      end

      it 'parses complex expressions' do
        result = parser.expression.parse('= User.find(1).name')
        expected = { expression: { ruby: ' User.find(1).name' } }
        expect(result).to parse_as(expected)
      end

      it 'parses string expressions' do
        result = parser.expression.parse("= 'hello world'")
        expected = { expression: { ruby: " 'hello world'" } }
        expect(result).to parse_as(expected)
      end
    end

    describe '#comment' do
      it 'parses comment with hash sign' do
        result = parser.comment.parse('# this is a comment')
        expected = { comment: { ruby: ' this is a comment' } }
        expect(result).to parse_as(expected)
      end

      it 'parses empty comment' do
        result = parser.comment.parse('#')
        expected = { comment: { ruby: [] } }
        expect(result).to parse_as(expected)
      end

      it 'parses comment with ruby code' do
        result = parser.comment.parse('# x = 1')
        expected = { comment: { ruby: ' x = 1' } }
        expect(result).to parse_as(expected)
      end
    end

    describe '#code' do
      it 'parses plain ruby code' do
        result = parser.code.parse('x = 1')
        expected = { code: { ruby: 'x = 1' } }
        expect(result).to parse_as(expected)
      end

      it 'parses method calls' do
        result = parser.code.parse('puts "hello"')
        expected = { code: { ruby: 'puts "hello"' } }
        expect(result).to parse_as(expected)
      end

      it 'parses variable assignments' do
        result = parser.code.parse('a = 2')
        expected = { code: { ruby: 'a = 2' } }
        expect(result).to parse_as(expected)
      end
    end

    describe '#erb' do
      it 'parses expression erb' do
        result = parser.erb.parse('= x + 1')
        expected = { expression: { ruby: ' x + 1' } }
        expect(result).to parse_as(expected)
      end

      it 'parses comment erb' do
        result = parser.erb.parse('# comment')
        expected = { comment: { ruby: ' comment' } }
        expect(result).to parse_as(expected)
      end

      it 'parses code erb' do
        result = parser.erb.parse('x = 1')
        expected = { code: { ruby: 'x = 1' } }
        expect(result).to parse_as(expected)
      end
    end

    describe '#erb_with_tags' do
      it 'parses erb expression with tags' do
        result = parser.erb_with_tags.parse('<%= x + 1 %>')
        expected = { expression: { ruby: ' x + 1 ' } }
        expect(result).to parse_as(expected)
      end

      it 'parses erb comment with tags' do
        result = parser.erb_with_tags.parse('<%# comment %>')
        expected = { comment: { ruby: ' comment ' } }
        expect(result).to parse_as(expected)
      end

      it 'parses erb code with tags' do
        result = parser.erb_with_tags.parse('<% x = 1 %>')
        expected = { code: { ruby: ' x = 1 ' } }
        expect(result).to parse_as(expected)
      end

      it 'handles no spaces around erb content' do
        result = parser.erb_with_tags.parse('<%=x%>')
        expected = { expression: { ruby: 'x' } }
        expect(result).to parse_as(expected)
      end
    end

    describe '#text' do
      it 'parses plain text' do
        result = parser.text.parse('Hello world')
        expect(result).to eq('Hello world')
      end

      it 'parses text with spaces' do
        result = parser.text.parse('The value is ')
        expect(result).to eq('The value is ')
      end

      it 'parses text with punctuation' do
        result = parser.text.parse('Hello, world!')
        expect(result).to eq('Hello, world!')
      end

      it 'stops at erb tags' do
        result = parser.text.parse('Hello ')
        expect(result).to eq('Hello ')
      end

      it 'fails on empty string' do
        expect { parser.text.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#text_with_ruby (root)' do
      it 'parses simple text with erb expression' do
        result = parser.parse('The value of x is <%= x %>.')
        expected = {
          text: [
            { text: 'The value of x is ' },
            { expression: { ruby: ' x ' } },
            { text: '.' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses erb code block' do
        result = parser.parse('<% 1 + 2 %>')
        expected = {
          text: [
            { code: { ruby: ' 1 + 2 ' } }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses erb comment' do
        result = parser.parse('<%# commented %>')
        expected = {
          text: [
            { comment: { ruby: ' commented ' } }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses mixed text and erb' do
        result = parser.parse('Hello <% name = "World" %><%=name%>!')
        expected = {
          text: [
            { text: 'Hello ' },
            { code: { ruby: ' name = "World" ' } },
            { expression: { ruby: 'name' } },
            { text: '!' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses complex erb template' do
        input = 'The <% a = 2 %>value of a is <%= a %>.'
        result = parser.parse(input)

        expected = {
          text: [
            { text: 'The ' },
            { code: { ruby: ' a = 2 ' } },
            { text: 'value of a is ' },
            { expression: { ruby: ' a ' } },
            { text: '.' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses multiline erb template' do
        input = <<~ERB.chomp
          Hello
          <%= "World" %>
        ERB

        result = parser.parse(input)
        expected = {
          text: [
            { text: "Hello\n" },
            { expression: { ruby: ' "World" ' } }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'handles empty input' do
        result = parser.parse('')
        expected = { text: [] }
        expect(result).to parse_as(expected)
      end

      it 'parses only text' do
        result = parser.parse('Just plain text')
        expected = {
          text: [
            { text: 'Just plain text' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses only erb' do
        result = parser.parse('<%= "only erb" %>')
        expected = {
          text: [
            { expression: { ruby: ' "only erb" ' } }
          ]
        }
        expect(result).to parse_as(expected)
      end
    end

    describe 'error handling' do
      it 'fails on unclosed erb tags' do
        expect { parser.parse('Hello <%= world') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on malformed erb tags' do
        expect { parser.parse('Hello <% world >') }.to raise_error(Parslet::ParseFailed)
      end

      it 'parses nested erb tags as ruby code and text' do
        result = parser.parse('<%= <% nested %> %>')
        expected = {
          text: [
            { expression: { ruby: ' <% nested ' } },
            { text: ' %>' }
          ]
        }
        expect(result).to parse_as(expected)
      end
    end
  end

  describe ErbTransform do
    let(:binding_context) do
      # Create a binding with some variables for testing
      x = 42
      name = "World"
      binding
    end

    let(:transform_with_context) { ErbTransform.new(binding_context) }

    describe 'code transformation' do
      it 'executes code and returns empty string' do
        parsed = { code: { ruby: 'a = 2' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('')
      end

      it 'executes method calls and returns empty string' do
        parsed = { code: { ruby: 'puts "hello"' } }
        # Capture stdout to avoid printing during tests
        allow($stdout).to receive(:puts)
        result = transform_with_context.apply(parsed)
        expect(result).to eq('')
      end
    end

    describe 'expression transformation' do
      it 'evaluates expressions and returns result' do
        parsed = { expression: { ruby: 'x' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq(42)
      end

      it 'evaluates string expressions' do
        parsed = { expression: { ruby: '"Hello"' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('Hello')
      end

      it 'evaluates arithmetic expressions' do
        parsed = { expression: { ruby: '2 + 3' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq(5)
      end

      it 'evaluates variable references' do
        parsed = { expression: { ruby: 'name' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('World')
      end
    end

    describe 'comment transformation' do
      it 'returns empty string for comments' do
        parsed = { comment: { ruby: ' this is a comment' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('')
      end

      it 'does not evaluate comment content' do
        parsed = { comment: { ruby: ' x = 999' } }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('')
        # x should still be 42, not 999
        expect(binding_context.local_variable_get(:x)).to eq(42)
      end
    end

    describe 'text transformation' do
      it 'returns text as-is for simple text' do
        parsed = { text: 'Hello World' }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('Hello World')
      end

      it 'joins text sequences' do
        parsed = { text: ['Hello', ' ', 'World'] }
        result = transform_with_context.apply(parsed)
        expect(result).to eq('Hello World')
      end
    end

    describe 'integration transformation' do
      it 'transforms complete erb template' do
        input = 'The value of x is <%= x %>.'
        parsed = parser.parse(input)
        result = transform_with_context.apply(parsed)
        expect(result).to eq('The value of x is 42.')
      end

      it 'handles code blocks that set variables' do
        input = 'Start<% y = 10 %>The value is <%= y %>.'
        parsed = parser.parse(input)
        result = transform_with_context.apply(parsed)
        expect(result).to eq('StartThe value is 10.')
      end

      it 'handles comments that are ignored' do
        input = 'Hello<%# this is ignored %>World'
        parsed = parser.parse(input)
        result = transform_with_context.apply(parsed)
        expect(result).to eq('HelloWorld')
      end

      it 'handles complex template with multiple erb blocks' do
        input = 'Hello <% greeting = "Hi" %><%=greeting%> <%= name %>!'
        parsed = parser.parse(input)
        result = transform_with_context.apply(parsed)
        expect(result).to eq('Hello Hi World!')
      end

      it 'handles multiline templates' do
        input = <<~ERB.chomp
          Name: <%= name %>
          Value: <%= x %>
        ERB

        parsed = parser.parse(input)
        result = transform_with_context.apply(parsed)
        expected = "Name: World\nValue: 42"
        expect(result).to eq(expected)
      end
    end

    describe 'error handling in transformation' do
      it 'raises error for undefined variables in expressions' do
        parsed = { expression: { ruby: 'undefined_var' } }
        expect { transform_with_context.apply(parsed) }.to raise_error(NameError)
      end

      it 'raises error for syntax errors in ruby code' do
        parsed = { expression: { ruby: 'invalid syntax !' } }
        expect { transform_with_context.apply(parsed) }.to raise_error(SyntaxError)
      end
    end
  end

  describe 'parser and transformer integration' do
    let(:binding_context) do
      x = 42
      name = "World"
      binding
    end

    let(:transform_with_context) { ErbTransform.new(binding_context) }

    it 'processes simple erb template end-to-end' do
      input = 'Hello <%= name %>!'
      parsed = parser.parse(input)
      result = transform_with_context.apply(parsed)
      expect(result).to eq('Hello World!')
    end

    it 'processes erb with code blocks end-to-end' do
      input = 'The <% a = 2 %>value of a is <%= a %>.'
      parsed = parser.parse(input)
      result = transform_with_context.apply(parsed)
      expect(result).to eq('The value of a is 2.')
    end

    it 'processes erb with comments end-to-end' do
      input = 'Hello<%# comment %>World'
      parsed = parser.parse(input)
      result = transform_with_context.apply(parsed)
      expect(result).to eq('HelloWorld')
    end

    it 'processes complex erb template end-to-end' do
      input = <<~ERB.chomp
        The <% a = 2 %>not printed result of "a = 2".
        The <%# a = 1 %>not printed non-evaluated comment "a = 1", see the value of a below.
        The <%= 'nicely' %> printed result.
        The <% b = 3 %>value of a is <%= a %>, and b is <%= b %>.
      ERB

      parsed = parser.parse(input)
      result = transform_with_context.apply(parsed)

      expected = <<~RESULT.chomp
        The not printed result of "a = 2".
        The not printed non-evaluated comment "a = 1", see the value of a below.
        The nicely printed result.
        The value of a is 2, and b is 3.
      RESULT

      expect(result).to eq(expected)
    end
  end
end
