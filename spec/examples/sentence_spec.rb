# encoding: UTF-8

require 'spec_helper'
require_relative '../fixtures/examples/sentence'

RSpec.describe 'Sentence Parser Example' do
  let(:parser) { SentenceExample::MyParser.new }
  let(:transformer) { SentenceExample::Transformer.new }

  describe SentenceExample::MyParser do
    describe '#sentence' do
      it 'parses a single sentence ending with 。' do
        result = parser.sentence.parse("テスト。")
        expect(result).to parse_as({ sentence: "テスト。" })
      end

      it 'parses sentences with complex Unicode characters' do
        result = parser.sentence.parse("RubyKaigi2009のテーマは、「変わる／変える」です。")
        expect(result).to parse_as({ sentence: "RubyKaigi2009のテーマは、「変わる／変える」です。" })
      end

      it 'fails to parse text without sentence ending' do
        expect { parser.sentence.parse("テスト") }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#sentences' do
      it 'parses multiple sentences' do
        input = "第一。第二。第三。"
        result = parser.sentences.parse(input)
        expected = [
          { sentence: "第一。" },
          { sentence: "第二。" },
          { sentence: "第三。" }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses single sentence as array' do
        result = parser.sentences.parse("テスト。")
        expected = [{ sentence: "テスト。" }]
        expect(result).to parse_as(expected)
      end

      it 'parses empty input as empty array' do
        result = parser.sentences.parse("")
        expect(result).to eq("")
      end
    end

    describe 'root parser' do
      it 'parses the full example string correctly' do
        string = "RubyKaigi2009のテーマは、「変わる／変える」です。 前回の" +
                 "RubyKaigi2008のテーマであった「多様性」の言葉の通り、 " +
                 "2008年はRubyそのものに関しても、またRubyの活躍する舞台に関しても、 " +
                 "ますます多様化が進みつつあります。RubyKaigi2008は、そのような " +
                 "Rubyの生態系をあらためて認識する場となりました。 しかし、" +
                 "こうした多様化が進む中、異なる者同士が単純に距離を 置いたままでは、" +
                 "その違いを認識したところであまり意味がありません。 異なる実装、" +
                 "異なる思想、異なる背景といった、様々な多様性を理解しつつ、 " +
                 "すり合わせるべきものをすり合わせ、変えていくべきところを " +
                 "変えていくことが、豊かな未来へとつながる道に違いありません。"

        result = parser.parse(string)
        expected = [
          { sentence: "RubyKaigi2009のテーマは、「変わる／変える」です。" },
          { sentence: " 前回のRubyKaigi2008のテーマであった「多様性」の言葉の通り、 2008年はRubyそのものに関しても、またRubyの活躍する舞台に関しても、 ますます多様化が進みつつあります。" },
          { sentence: "RubyKaigi2008は、そのような Rubyの生態系をあらためて認識する場となりました。" },
          { sentence: " しかし、こうした多様化が進む中、異なる者同士が単純に距離を 置いたままでは、その違いを認識したところであまり意味がありません。" },
          { sentence: " 異なる実装、異なる思想、異なる背景といった、様々な多様性を理解しつつ、 すり合わせるべきものをすり合わせ、変えていくべきところを 変えていくことが、豊かな未来へとつながる道に違いありません。" }
        ]
        expect(result).to parse_as(expected)
      end
    end
  end

  describe SentenceExample::Transformer do
    it 'transforms sentence slices to strings' do
      input = { sentence: Parslet::Slice.new(Parslet::Position.new("テスト", 0), "テスト") }
      result = transformer.apply(input)
      expect(result).to eq("テスト")
    end

    it 'transforms array of sentences' do
      input = [
        { sentence: Parslet::Slice.new(Parslet::Position.new("第一第二", 0), "第一") },
        { sentence: Parslet::Slice.new(Parslet::Position.new("第一第二", 2), "第二") }
      ]
      result = transformer.apply(input)
      expect(result).to eq(["第一", "第二"])
    end
  end

  describe 'integration test' do
    it 'processes the full example correctly' do
      string = "RubyKaigi2009のテーマは、「変わる／変える」です。 前回の" +
               "RubyKaigi2008のテーマであった「多様性」の言葉の通り、 " +
               "2008年はRubyそのものに関しても、またRubyの活躍する舞台に関しても、 " +
               "ますます多様化が進みつつあります。RubyKaigi2008は、そのような " +
               "Rubyの生態系をあらためて認識する場となりました。 しかし、" +
               "こうした多様化が進む中、異なる者同士が単純に距離を 置いたままでは、" +
               "その違いを認識したところであまり意味がありません。 異なる実装、" +
               "異なる思想、異なる背景といった、様々な多様性を理解しつつ、 " +
               "すり合わせるべきものをすり合わせ、変えていくべきところを " +
               "変えていくことが、豊かな未来へとつながる道に違いありません。"

      tree = parser.parse(string)
      result = transformer.apply(tree)

      expect(result).to be_an(Array)
      expect(result.length).to eq(5)
      expect(result[0]).to eq("RubyKaigi2009のテーマは、「変わる／変える」です。")
      expect(result[1]).to eq(" 前回のRubyKaigi2008のテーマであった「多様性」の言葉の通り、 2008年はRubyそのものに関しても、またRubyの活躍する舞台に関しても、 ますます多様化が進みつつあります。")
      expect(result[2]).to eq("RubyKaigi2008は、そのような Rubyの生態系をあらためて認識する場となりました。")
      expect(result[3]).to eq(" しかし、こうした多様化が進む中、異なる者同士が単純に距離を 置いたままでは、その違いを認識したところであまり意味がありません。")
      expect(result[4]).to eq(" 異なる実装、異なる思想、異なる背景といった、様々な多様性を理解しつつ、 すり合わせるべきものをすり合わせ、変えていくべきところを 変えていくことが、豊かな未来へとつながる道に違いありません。")
    end
  end
end
