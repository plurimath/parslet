require 'spec_helper'
require_relative '../fixtures/examples/html5'

RSpec.describe 'HTML5 Parser Example' do
  let(:parser) { HTML5Parser.new }
  let(:transformer) { HTML5Transformer.new }

  describe HTML5Parser do
    describe 'basic parsing' do
      it 'parses DOCTYPE declaration' do
        html = <<~HTML
          <!DOCTYPE html>
        HTML

        result = parser.parse(html)

        expected_structure = {
          doctype: {
            doctype_name: 'html'
          },
          elements: []
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses simple void elements' do
        html = <<~HTML
          <br>
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              void_element: {
                tag_name: 'br',
                attributes: []
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses void elements with attributes' do
        html = <<~HTML
          <img src="comprehensive-image.jpg" alt="Comprehensive Test Image">
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              void_element: {
                tag_name: 'img',
                attributes: [
                  {
                    name: 'src',
                    value: 'comprehensive-image.jpg'
                  },
                  {
                    name: 'alt',
                    value: 'Comprehensive Test Image'
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses simple container elements' do
        html = <<~HTML
          <div>Comprehensive content for testing</div>
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              container_element: {
                opening: {
                  tag_name: 'div',
                  attributes: []
                },
                closing: {
                  tag_name: 'div'
                },
                content: [
                  {
                    text: 'Comprehensive content for testing'
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses container elements without closing tags' do
        html = <<~HTML
          <p>Comprehensive paragraph content without closing tag
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              container_element: {
                opening: {
                  tag_name: 'p',
                  attributes: []
                },
                content: [
                  {
                    text: "Comprehensive paragraph content without closing tag\n"
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses nested elements' do
        html = <<~HTML
          <div><span>Comprehensive nested text content</span></div>
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              container_element: {
                opening: {
                  tag_name: 'div',
                  attributes: []
                },
                closing: {
                  tag_name: 'div'
                },
                content: [
                  {
                    container_element: {
                      opening: {
                        tag_name: 'span',
                        attributes: []
                      },
                      closing: {
                        tag_name: 'span'
                      },
                      content: [
                        {
                          text: 'Comprehensive nested text content'
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses comments' do
        html = <<~HTML
          <!-- This is a comprehensive comment for testing -->
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              comment: {
                text: ' This is a comprehensive comment for testing '
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses attributes with quoted values' do
        html = <<~HTML
          <div class="comprehensive-container" id="main-content">
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              container_element: {
                opening: {
                  tag_name: 'div',
                  attributes: [
                    {
                      name: 'class',
                      value: 'comprehensive-container'
                    },
                    {
                      name: 'id',
                      value: 'main-content'
                    }
                  ]
                },
                content: []
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses attributes without values' do
        html = <<~HTML
          <input type="text" name="comprehensive-input" required>
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              void_element: {
                tag_name: 'input',
                attributes: [
                  {
                    name: 'type',
                    value: 'text'
                  },
                  {
                    name: 'name',
                    value: 'comprehensive-input'
                  },
                  {
                    name: 'required'
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'parses mixed content' do
        result = parser.parse('<p>Text with <strong>bold</strong> content</p>')
        element = result[:elements].first[:container_element]
        expect(element[:content]).to be_an(Array)
        expect(element[:content].length).to eq(3) # text, strong element, text
      end
    end

    describe 'complex parsing scenarios' do
      it 'parses complete HTML document' do
        html = "<!DOCTYPE html>\n<html>\n<head>\n<title>Test</title>\n</head>\n<body>\n<h1>Hello</h1>\n</body>\n</html>"
        result = parser.parse(html)

        expect(result[:doctype]).to be_a(Hash)
        expect(result[:elements]).to be_an(Array)
        expect(result[:elements].first[:container_element][:opening][:tag_name].to_s).to eq('html')
      end

      it 'handles multiple unclosed paragraph tags' do
        html = <<~HTML
          <p>First paragraph with some content
          <p>Second paragraph with more details
          <p>Third paragraph to complete the test
        HTML

        result = parser.parse(html)

        expected_structure = {
          elements: [
            {
              container_element: {
                opening: {
                  tag_name: 'p',
                  attributes: []
                },
                content: [
                  {
                    text: "First paragraph with some content\n"
                  }
                ]
              }
            },
            {
              container_element: {
                opening: {
                  tag_name: 'p',
                  attributes: []
                },
                content: [
                  {
                    text: "Second paragraph with more details\n"
                  }
                ]
              }
            },
            {
              container_element: {
                opening: {
                  tag_name: 'p',
                  attributes: []
                },
                content: [
                  {
                    text: "Third paragraph to complete the test\n"
                  }
                ]
              }
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end
    end
  end

  describe HTML5Transformer do
    def parse_and_transform(html)
      tree = parser.parse(html)
      # Pre-process comments to preserve spaces
      tree = preprocess_comments(tree)
      transformer.apply(tree)
    end

    describe 'transformation' do
      it 'transforms DOCTYPE correctly' do
        html = <<~HTML
          <!DOCTYPE html>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          doctype: {
            type: :doctype,
            name: 'html'
          },
          children: []
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms void elements correctly' do
        html = <<~HTML
          <br>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'br',
              void: true,
              attributes: {},
              children: []
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms void elements with attributes correctly' do
        html = <<~HTML
          <img src="comprehensive-image.jpg" alt="Comprehensive Test Image">
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'img',
              void: true,
              attributes: {
                'src' => 'comprehensive-image.jpg',
                'alt' => 'Comprehensive Test Image'
              },
              children: []
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms container elements correctly' do
        html = <<~HTML
          <div>Comprehensive content for testing</div>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'div',
              void: false,
              attributes: {},
              children: [
                {
                  type: :text,
                  content: 'Comprehensive content for testing'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms unclosed container elements correctly' do
        html = <<~HTML
          <p>Comprehensive paragraph content without closing tag
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'p',
              void: false,
              unclosed: true,
              attributes: {},
              children: [
                {
                  type: :text,
                  content: 'Comprehensive paragraph content without closing tag'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms nested elements correctly' do
        html = <<~HTML
          <div><span>Comprehensive nested text content</span></div>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'div',
              void: false,
              attributes: {},
              children: [
                {
                  type: :element,
                  tag: 'span',
                  void: false,
                  attributes: {},
                  children: [
                    {
                      type: :text,
                      content: 'Comprehensive nested text content'
                    }
                  ]
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms comments correctly' do
        html = <<~HTML
          <!-- This is a comprehensive comment for testing -->
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :comment,
              text: ' This is a comprehensive comment for testing '
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms attributes correctly' do
        html = <<~HTML
          <div class="comprehensive-container" id="main-content" data-value="test-data">
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'div',
              void: false,
              unclosed: true,
              attributes: {
                'class' => 'comprehensive-container',
                'id' => 'main-content',
                'data-value' => 'test-data'
              },
              children: []
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms boolean attributes correctly' do
        html = <<~HTML
          <input type="text" name="comprehensive-input" required disabled>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'input',
              void: true,
              attributes: {
                'type' => 'text',
                'name' => 'comprehensive-input',
                'required' => true,
                'disabled' => true
              },
              children: []
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end

      it 'transforms mixed content correctly' do
        html = <<~HTML
          <p>Comprehensive text with <strong>bold formatting</strong> and more content</p>
        HTML

        result = parse_and_transform(html)

        expected_structure = {
          type: :document,
          children: [
            {
              type: :element,
              tag: 'p',
              void: false,
              attributes: {},
              children: [
                {
                  type: :text,
                  content: 'Comprehensive text with'
                },
                {
                  type: :element,
                  tag: 'strong',
                  void: false,
                  attributes: {},
                  children: [
                    {
                      type: :text,
                      content: 'bold formatting'
                    }
                  ]
                },
                {
                  type: :text,
                  content: 'and more content'
                }
              ]
            }
          ]
        }

        expect(result).to parse_as(expected_structure)
      end
    end
  end

  describe 'parse_html5 convenience function' do
    it 'parses and transforms in one call' do
      html = <<~HTML
        <div>Comprehensive Hello World Content</div>
      HTML

      result = parse_html5(html)

      expected_structure = {
        type: :document,
        children: [
          {
            type: :element,
            tag: 'div',
            void: false,
            attributes: {},
            children: [
              {
                type: :text,
                content: 'Comprehensive Hello World Content'
              }
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'handles complex HTML structure' do
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
        <title>Comprehensive Test Document</title>
        </head>
        <body>
        <h1>Main Heading Content</h1>
        </body>
        </html>
      HTML

      result = parse_html5(html)

      expected_structure = {
        type: :document,
        doctype: {
          type: :doctype,
          name: 'html'
        },
        children: [
          {
            type: :element,
            tag: 'html',
            void: false,
            attributes: {},
            children: [
              {
                type: :element,
                tag: 'head',
                void: false,
                attributes: {},
                children: [
                  {
                    type: :element,
                    tag: 'title',
                    void: false,
                    attributes: {},
                    children: [
                      {
                        type: :text,
                        content: 'Comprehensive Test Document'
                      }
                    ]
                  }
                ]
              },
              {
                type: :element,
                tag: 'body',
                void: false,
                attributes: {},
                children: [
                  {
                    type: :element,
                    tag: 'h1',
                    void: false,
                    attributes: {},
                    children: [
                      {
                        type: :text,
                        content: 'Main Heading Content'
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end
  end

  describe 'integration tests' do
    it 'processes the main example from run_html5.rb' do
      html = <<~HTML
        <div class="comprehensive-container"><h1>Main Title Content</h1><p>Comprehensive paragraph content</p></div>
      HTML

      result = parse_html5(html)

      expected_structure = {
        type: :document,
        children: [
          {
            type: :element,
            tag: 'div',
            void: false,
            attributes: {
              'class' => 'comprehensive-container'
            },
            children: [
              {
                type: :element,
                tag: 'h1',
                void: false,
                attributes: {},
                children: [
                  {
                    type: :text,
                    content: 'Main Title Content'
                  }
                ]
              },
              {
                type: :element,
                tag: 'p',
                void: false,
                attributes: {},
                children: [
                  {
                    type: :text,
                    content: 'Comprehensive paragraph content'
                  }
                ]
              }
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'processes form elements correctly' do
      html = <<~HTML
        <form><input type="text" name="comprehensive-username" placeholder="Enter username"><button type="submit">Submit Form</button></form>
      HTML

      result = parse_html5(html)

      expected_structure = {
        type: :document,
        children: [
          {
            type: :element,
            tag: 'form',
            void: false,
            attributes: {},
            children: [
              {
                type: :element,
                tag: 'input',
                void: true,
                attributes: {
                  'type' => 'text',
                  'name' => 'comprehensive-username',
                  'placeholder' => 'Enter username'
                },
                children: []
              },
              {
                type: :element,
                tag: 'button',
                void: false,
                attributes: {
                  'type' => 'submit'
                },
                children: [
                  {
                    type: :text,
                    content: 'Submit Form'
                  }
                ]
              }
            ]
          }
        ]
      }

      expect(result).to parse_as(expected_structure)
    end

    it 'demonstrates error handling' do
      # Test with malformed HTML that should fail to parse
      # Using unclosed div and span tags which should trigger the error handling
      malformed_html = <<~HTML
        <div><span>Unclosed tags
      HTML

      expect {
        parse_html5(malformed_html)
      }.to raise_error(Parslet::ParseFailed)
    end

    it 'works with the examples from run_html5.rb' do
      # Test comprehensive examples to ensure they work
      examples = [
        '<img src="comprehensive-image.jpg" alt="Comprehensive Image">',
        '<p>First comprehensive paragraph\n<p>Second detailed paragraph',
        '<div class="comprehensive-container"><span>Nested content</span></div>',
        '<!-- Comprehensive comment --><p>Content with comment</p>',
        '<form><input type="text" name="comprehensive-field" required></form>'
      ]

      examples.each do |html|
        expect { parse_html5(html) }.not_to raise_error
        result = parse_html5(html)

        expect(result[:type]).to eq(:document)
        expect(result[:children]).to be_an(Array)
        expect(result[:children]).not_to be_empty
      end
    end
  end
end
