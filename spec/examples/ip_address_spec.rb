require 'spec_helper'
require_relative '../fixtures/examples/ip_address'

RSpec.describe 'IP Address Parser Example' do
  let(:parser) { IpAddressExample::Parser.new }

  describe IpAddressExample::IPv4 do
    describe '#dec_octet' do
      it 'parses single digits' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        expect(parser_with_ipv4.dec_octet.parse('0')).to parse_as('0')
        expect(parser_with_ipv4.dec_octet.parse('9')).to parse_as('9')
      end

      it 'parses two digit numbers' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        expect(parser_with_ipv4.dec_octet.parse('10')).to parse_as('10')
        expect(parser_with_ipv4.dec_octet.parse('99')).to parse_as('99')
      end

      it 'parses three digit numbers' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        expect(parser_with_ipv4.dec_octet.parse('100')).to parse_as('100')
        expect(parser_with_ipv4.dec_octet.parse('199')).to parse_as('199')
        expect(parser_with_ipv4.dec_octet.parse('255')).to parse_as('255')
      end

      it 'rejects numbers over 255' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        expect { parser_with_ipv4.dec_octet.parse('256') }.to raise_error(Parslet::ParseFailed)
        expect { parser_with_ipv4.dec_octet.parse('300') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#ipv4' do
      it 'parses valid IPv4 addresses' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        result = parser_with_ipv4.ipv4.parse('192.168.1.1')
        expect(result).to parse_as({ ipv4: '192.168.1.1' })
      end

      it 'parses edge case IPv4 addresses' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new

        result = parser_with_ipv4.ipv4.parse('0.0.0.0')
        expect(result).to parse_as({ ipv4: '0.0.0.0' })

        result = parser_with_ipv4.ipv4.parse('255.255.255.255')
        expect(result).to parse_as({ ipv4: '255.255.255.255' })
      end

      it 'rejects invalid IPv4 addresses' do
        parser_with_ipv4 = Class.new { include IpAddressExample::IPv4 }.new
        expect { parser_with_ipv4.ipv4.parse('256.1.1.1') }.to raise_error(Parslet::ParseFailed)
        expect { parser_with_ipv4.ipv4.parse('1.1.1') }.to raise_error(Parslet::ParseFailed)
        expect { parser_with_ipv4.ipv4.parse('1.1.1.1.1') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  # Note: IPv6 module depends on IPv4's digit rule, so we test through the main Parser class

  describe IpAddressExample::Parser do
    describe '#parse' do
      it 'parses valid IPv4 addresses' do
        result = parser.parse('0.0.0.0')
        expect(result).to parse_as({ ipv4: '0.0.0.0' })

        result = parser.parse('255.255.255.255')
        expect(result).to parse_as({ ipv4: '255.255.255.255' })
      end

      it 'parses valid IPv6 addresses' do
        result = parser.parse('1:2:3:4:5:6:7:8')
        expect(result).to parse_as({ ipv6: '1:2:3:4:5:6:7:8' })

        result = parser.parse('12AD:34FC:A453:1922::')
        expect(result).to parse_as({ ipv6: '12AD:34FC:A453:1922::' })

        result = parser.parse('12AD::34FC')
        expect(result).to parse_as({ ipv6: '12AD::34FC' })

        result = parser.parse('12AD::')
        expect(result).to parse_as({ ipv6: '12AD::' })

        result = parser.parse('::')
        expect(result).to parse_as({ ipv6: '::' })
      end

      it 'handles some IPv6 addresses but not all short ones' do
        # This actually fails in the original example - the IPv6 grammar is strict
        expect { parser.parse('1:2') }.to raise_error(Parslet::ParseFailed)
      end

      it 'rejects invalid addresses' do
        expect { parser.parse('255.255.255') }.to raise_error(Parslet::ParseFailed)
        expect { parser.parse('256.1.1.1') }.to raise_error(Parslet::ParseFailed)
        expect { parser.parse('invalid') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'integration test' do
    it 'processes all the successful example addresses correctly' do
      test_cases = [
        { input: '0.0.0.0', expected: { ipv4: '0.0.0.0' } },
        { input: '255.255.255.255', expected: { ipv4: '255.255.255.255' } },
        { input: '1:2:3:4:5:6:7:8', expected: { ipv6: '1:2:3:4:5:6:7:8' } },
        { input: '12AD:34FC:A453:1922::', expected: { ipv6: '12AD:34FC:A453:1922::' } },
        { input: '12AD::34FC', expected: { ipv6: '12AD::34FC' } },
        { input: '12AD::', expected: { ipv6: '12AD::' } },
        { input: '::', expected: { ipv6: '::' } }
      ]

      test_cases.each do |test_case|
        result = parser.parse(test_case[:input])
        expect(result).to parse_as(test_case[:expected])
      end
    end

    it 'handles failing cases correctly' do
      failing_cases = ['255.255.255', '1:2']

      failing_cases.each do |address|
        expect { parser.parse(address) }.to raise_error(Parslet::ParseFailed)
      end
    end

    it 'produces the expected output from the example file' do
      # Test the successful cases from the example
      successful_cases = {
        '0.0.0.0' => { ipv4: '0.0.0.0' },
        '255.255.255.255' => { ipv4: '255.255.255.255' },
        '1:2:3:4:5:6:7:8' => { ipv6: '1:2:3:4:5:6:7:8' },
        '12AD:34FC:A453:1922::' => { ipv6: '12AD:34FC:A453:1922::' },
        '12AD::34FC' => { ipv6: '12AD::34FC' },
        '12AD::' => { ipv6: '12AD::' },
        '::' => { ipv6: '::' }
      }

      successful_cases.each do |input, expected|
        result = parser.parse(input)
        expect(result).to parse_as(expected)
      end

      # Test the failing cases from the example
      failing_cases = ['255.255.255', '1:2']
      failing_cases.each do |address|
        expect { parser.parse(address) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end
end
