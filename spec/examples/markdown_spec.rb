require 'spec_helper'
require_relative '../fixtures/examples/markdown'

RSpec.describe 'Markdown Parser Example' do
  let(:parser) { MarkdownParser.new }
  let(:transformer) { MarkdownTransformer.new }

  describe MarkdownParser do
    describe 'basic parsing' do
      it 'parses a simple header' do
        markdown = <<~MARKDOWN
          # Comprehensive Header Content

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              header: {
                level: '#',
                text: 'Comprehensive Header Content'
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses a paragraph' do
        markdown = <<~MARKDOWN
          This is a comprehensive paragraph with substantial content for testing.

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              paragraph: [
                {
                  text: 'This is a comprehensive paragraph with substantial content for testing.'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses bold text in paragraph' do
        markdown = <<~MARKDOWN
          This comprehensive text contains **bold formatting** within the content.

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              paragraph: [
                {
                  text: 'This comprehensive text contains '
                },
                {
                  bold: {
                    text: 'bold formatting'
                  }
                },
                {
                  text: ' within the content.'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses italic text in paragraph' do
        markdown = <<~MARKDOWN
          This comprehensive text contains *italic formatting* within the content.

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              paragraph: [
                {
                  text: 'This comprehensive text contains '
                },
                {
                  italic: {
                    text: 'italic formatting'
                  }
                },
                {
                  text: ' within the content.'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses inline code' do
        markdown = <<~MARKDOWN
          This comprehensive text contains `inline code formatting` within the content.

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              paragraph: [
                {
                  text: 'This comprehensive text contains '
                },
                {
                  inline_code: {
                    text: 'inline code formatting'
                  }
                },
                {
                  text: ' within the content.'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses links' do
        markdown = <<~MARKDOWN
          Check out [this comprehensive link](https://example.com/detailed-page) for more information.

        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              paragraph: [
                {
                  text: 'Check out '
                },
                {
                  link: {
                    text: 'this comprehensive link',
                    url: 'https://example.com/detailed-page'
                  }
                },
                {
                  text: ' for more information.'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses list items' do
        markdown = <<~MARKDOWN
          - First comprehensive item with substantial content
          - Second detailed item with more information
          - Third substantial item to complete the list
        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              list_item: {
                text: 'First comprehensive item with substantial content'
              }
            },
            {
              list_item: {
                text: 'Second detailed item with more information'
              }
            },
            {
              list_item: {
                text: 'Third substantial item to complete the list'
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses code blocks' do
        markdown = <<~MARKDOWN
          ```ruby
          def comprehensive_method
            puts "This is substantial code content"
            return "comprehensive result"
          end
          ```
        MARKDOWN

        result = parser.parse(markdown)

        expected_structure = {
          document: [
            {
              code_block: {
                language: 'ruby',
                code: "def comprehensive_method\n  puts \"This is substantial code content\"\n  return \"comprehensive result\"\nend\n"
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end
    end
  end

  describe MarkdownTransformer do
    def parse_and_transform(text)
      tree = parser.parse(text)
      transformer.apply(tree)
    end

    describe 'transformation' do
      it 'transforms headers correctly' do
        markdown = <<~MARKDOWN
          # Main Header with substantial content
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :header,
              level: 1,
              text: 'Main Header with substantial content'
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms paragraphs correctly' do
        markdown = <<~MARKDOWN
          This is a substantial paragraph with meaningful content that demonstrates proper parsing.
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :paragraph,
              content: ['This is a substantial paragraph with meaningful content that demonstrates proper parsing.']
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms bold text correctly' do
        markdown = <<~MARKDOWN
          This paragraph contains **bold text** within normal content.
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :paragraph,
              content: [
                'This paragraph contains ',
                { type: :bold, text: 'bold text' },
                ' within normal content.'
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms italic text correctly' do
        markdown = <<~MARKDOWN
          This paragraph contains *italic text* within normal content.
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :paragraph,
              content: [
                'This paragraph contains ',
                { type: :italic, text: 'italic text' },
                ' within normal content.'
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms inline code correctly' do
        markdown = <<~MARKDOWN
          This paragraph contains `inline code` within normal content.
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :paragraph,
              content: [
                'This paragraph contains ',
                { type: :inline_code, text: 'inline code' },
                ' within normal content.'
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms links correctly' do
        markdown = <<~MARKDOWN
          Check out [this comprehensive link](https://example.com/detailed-page) for more information.
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :paragraph,
              content: [
                'Check out ',
                { type: :link, text: 'this comprehensive link', url: 'https://example.com/detailed-page' },
                ' for more information.'
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms list items correctly' do
        markdown = <<~MARKDOWN
          - First item with some content
          - Second item with more details
          - Third item to complete the list
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            { type: :list_item, text: 'First item with some content' },
            { type: :list_item, text: 'Second item with more details' },
            { type: :list_item, text: 'Third item to complete the list' }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms code blocks correctly' do
        markdown = <<~MARKDOWN
          ```ruby
          def hello_world
            puts "Hello, World!"
          end
          ```
        MARKDOWN

        result = parse_and_transform(markdown)

        expected_structure = {
          type: :document,
          blocks: [
            {
              type: :code_block,
              language: 'ruby',
              code: "def hello_world\n  puts \"Hello, World!\"\nend\n"
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end
    end
  end

  describe 'parse_markdown convenience function' do
    it 'parses and transforms in one call' do
      markdown = <<~MARKDOWN
        # Hello World

        This is a comprehensive paragraph with substantial content.
      MARKDOWN

      result = parse_markdown(markdown)

      expected_structure = {
        type: :document,
        blocks: [
          {
            type: :header,
            level: 1,
            text: 'Hello World'
          },
          {
            type: :paragraph,
            content: ['This is a comprehensive paragraph with substantial content.']
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'handles complex markdown' do
      markdown = <<~MARKDOWN
        # Main Title

        Text with **bold formatting** and [comprehensive link](https://example.com/detailed-url) content.
      MARKDOWN

      result = parse_markdown(markdown)

      expected_structure = {
        type: :document,
        blocks: [
          {
            type: :header,
            level: 1,
            text: 'Main Title'
          },
          {
            type: :paragraph,
            content: [
              'Text with ',
              { type: :bold, text: 'bold formatting' },
              ' and ',
              { type: :link, text: 'comprehensive link', url: 'https://example.com/detailed-url' },
              ' content.'
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end
  end

  describe 'integration tests' do
    it 'processes the main example from run_markdown.rb' do
      markdown = <<~MARKDOWN
        # Main Header

        This is a comprehensive paragraph with substantial content.
      MARKDOWN

      result = parse_markdown(markdown)

      expected_structure = {
        type: :document,
        blocks: [
          {
            type: :header,
            level: 1,
            text: 'Main Header'
          },
          {
            type: :paragraph,
            content: ['This is a comprehensive paragraph with substantial content.']
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'processes complex formatting example' do
      markdown = <<~MARKDOWN
        ## Comprehensive Subheader

        This paragraph has **bold text formatting** and *italic text styling* with substantial content.
      MARKDOWN

      result = parse_markdown(markdown)

      expected_structure = {
        type: :document,
        blocks: [
          {
            type: :header,
            level: 2,
            text: 'Comprehensive Subheader'
          },
          {
            type: :paragraph,
            content: [
              'This paragraph has ',
              { type: :bold, text: 'bold text formatting' },
              ' and ',
              { type: :italic, text: 'italic text styling' },
              ' with substantial content.'
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'demonstrates error handling' do
      # Test with malformed markdown that should fail
      malformed_markdown = <<~MARKDOWN
        **unclosed bold formatting that should cause parsing to fail
        *unclosed italic that should also fail
      MARKDOWN

      expect {
        parse_markdown(malformed_markdown)
      }.to raise_error(Parslet::ParseFailed)
    end

    it 'works with the examples from run_markdown.rb' do
      # Test comprehensive examples to ensure they work
      examples = [
        "# Main Header\n\nThis is a comprehensive paragraph.",
        "## Subheader\n\nThis paragraph has **bold text** and *italic text*.",
        "Here's a [comprehensive link](https://example.com/detailed-page) in a paragraph.",
        "Some `inline code example` in substantial text content.",
        "- First comprehensive item\n- Second detailed item\n- Third substantial item"
      ]

      examples.each do |markdown|
        expect { parse_markdown(markdown) }.not_to raise_error
        result = parse_markdown(markdown)

        expect(result[:type]).to eq(:document)
        expect(result[:blocks]).to be_an(Array)
        expect(result[:blocks]).not_to be_empty
      end
    end
  end
end
