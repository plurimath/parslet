require 'spec_helper'

require 'timeout' unless RUBY_ENGINE == 'opal'
require 'parslet'

describe Parslet do
  def not_parse
    raise_error(Parslet::ParseFailed)
  end

  include Parslet
  extend Parslet

  def src(str)
    Parslet::Source.new str
  end
  let(:context) { Parslet::Atoms::Context.new }

  describe "match('[abc]')" do
    attr_reader :parslet

    before do
      @parslet = Parslet.match('[abc]')
    end

    it 'parses {a,b,c}' do
      parslet.parse('a')
      parslet.parse('b')
      parslet.parse('c')
    end

    it 'does not parse d' do
      cause = catch_failed_parse do
        parslet.parse('d')
      end
      expect(cause.to_s).to eq('Failed to match [abc] at line 1 char 1.')
    end

    it 'prints as [abc]' do
      parslet.inspect.should == '[abc]'
    end
  end

  describe "match(['[a]').repeat(3)" do
    attr_reader :parslet

    before do
      @parslet = Parslet.match('[a]').repeat(3)
    end

    context "when failing on input 'aa'" do
      let!(:cause) do
        catch_failed_parse { parslet.parse('aa') }
      end

      it 'has a relevant cause' do
        cause.to_s.should == 'Expected at least 3 of [a] at line 1 char 1.'
      end

      it 'has a tree with 2 nodes' do
        cause.children.size.should == 1
      end
    end

    it "succeeds on 'aaa'" do
      parslet.parse('aaa')
    end

    it "succeeds on many 'a'" do
      parslet.parse('a' * 100)
    end

    it 'inspects as [a]{3, }' do
      parslet.inspect.should == '[a]{3, }'
    end
  end

  describe "str('foo')" do
    attr_reader :parslet

    before do
      @parslet = str('foo')
    end

    it "parses 'foo'" do
      parslet.parse('foo')
    end

    it "does not parse 'bar'" do
      cause = catch_failed_parse { parslet.parse('bar') }
      cause.to_s.should ==
        'Expected "foo", but got "bar" at line 1 char 1.'
    end

    it "inspects as 'foo'" do
      parslet.inspect.should == "'foo'"
    end
  end

  describe "str('foo').maybe" do
    let(:parslet) { str('foo').maybe }

    it 'parses a foo' do
      parslet.parse('foo')
    end

    it 'leaves pos untouched if there is no foo' do
      source = src('bar')
      parslet.apply(source, context)
      source.pos.charpos.should == 0
    end

    it "inspects as 'foo'?" do
      parslet.inspect.should == "'foo'?"
    end

    context "when parsing 'foo'" do
      subject { parslet.parse('foo') }

      it { is_expected.to eq('foo') }
    end

    context "when parsing ''" do
      subject { parslet.parse('') }

      it { is_expected.to eq('') }
    end
  end

  describe "str('foo') >> str('bar')" do
    let(:parslet) { str('foo') >> str('bar') }

    context "when it fails on input 'foobaz'" do
      let!(:cause) do
        catch_failed_parse { parslet.parse('foobaz') }
      end

      it "does not parse 'foobaz'" do
        cause.to_s.should == "Failed to match sequence ('foo' 'bar') at line 1 char 4."
      end

      it 'has 2 nodes in error tree' do
        cause.children.size.should == 1
      end
    end

    it "parses 'foobar'" do
      parslet.parse('foobar')
    end

    it "inspects as ('foo' 'bar')" do
      parslet.inspect.should == "'foo' 'bar'"
    end
  end

  describe "str('foo') | str('bar')" do
    attr_reader :parslet

    before do
      @parslet = str('foo') | str('bar')
    end

    context "when failing on input 'baz'" do
      let!(:cause) do
        catch_failed_parse { parslet.parse('baz') }
      end

      it 'has a sensible cause' do
        cause.to_s.should == "Expected one of ['foo', 'bar'] at line 1 char 1."
      end

      it 'has an error tree with 3 nodes' do
        cause.children.size.should == 2
      end
    end

    it "accepts 'foo'" do
      parslet.parse('foo')
    end

    it "accepts 'bar'" do
      parslet.parse('bar')
    end

    it "inspects as ('foo' / 'bar')" do
      parslet.inspect.should == "'foo' / 'bar'"
    end
  end

  describe "str('foo').present? (positive lookahead)" do
    attr_reader :parslet

    before do
      @parslet = str('foo').present?
    end

    it "inspects as &'foo'" do
      parslet.inspect.should == "&'foo'"
    end

    context "when fed 'foo'" do
      it 'parses' do
        success, = parslet.apply(src('foo'), context)
        success.should == true
      end

      it 'does not change input position' do
        source = src('foo')
        parslet.apply(source, context)
        source.pos.charpos.should == 0
      end
    end

    context "when fed 'bar'" do
      it 'does not parse' do
        -> { parslet.parse('bar') }.should not_parse
      end
    end

    describe '<- #parse' do
      it 'returns nil' do
        parslet.apply(src('foo'), context).should == [true, nil]
      end
    end
  end

  describe "str('foo').absent? (negative lookahead)" do
    attr_reader :parslet

    before do
      @parslet = str('foo').absent?
    end

    it "inspects as !'foo'" do
      parslet.inspect.should == "!'foo'"
    end

    context "when fed 'bar'" do
      it 'parses' do
        parslet.apply(src('bar'), context).should == [true, nil]
      end

      it 'does not change input position' do
        source = src('bar')
        parslet.apply(source, context)
        source.pos.charpos.should == 0
      end
    end

    context "when fed 'foo'" do
      it 'does not parse' do
        -> { parslet.parse('foo') }.should not_parse
      end
    end
  end

  describe 'non greedy matcher combined with greedy matcher (possible loop)' do
    attr_reader :parslet

    before do
      # repeat will always succeed, since it has a minimum of 0. It will not
      # modify input position in that case. absent? will, depending on
      # implementation, match as much as possible and call its inner element
      # again. This leads to an infinite loop. This example tests for the
      # absence of that loop.
      @parslet = str('foo').repeat.maybe
    end

    unless RUBY_ENGINE == 'opal'
      it 'does not loop infinitely' do
        lambda {
          Timeout.timeout(1) { parslet.parse('bar') }
        }.should raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'any' do
    attr_reader :parslet

    before do
      @parslet = any
    end

    it 'matches' do
      parslet.parse('.')
    end

    it 'consumes one char' do
      source = src('foo')
      parslet.apply(source, context)
      source.pos.charpos.should == 1
    end
  end

  describe 'eof behaviour' do
    context "when the pattern just doesn't consume the input" do
      let(:parslet) { any }

      it 'fails the parse' do
        cause = catch_failed_parse { parslet.parse('..') }
        cause.to_s.should == "Don't know what to do with \".\" at line 1 char 2."
      end
    end

    context "when the pattern doesn't match the input" do
      let(:parslet) { (str('a')).repeat(1) }

      attr_reader :exception

      before do
        parslet.parse('a.')
      rescue StandardError => e
        @exception = e
      end

      it 'raises Parslet::ParseFailed' do
        # ParseFailed here, because the input doesn't match the parser grammar.
        exception.should be_kind_of(Parslet::ParseFailed)
      end

      it 'has the correct error message' do
        exception.message.should == \
          'Extra input after last repetition at line 1 char 2.'
      end
    end
  end

  describe '<- #as(name)' do
    context "str('foo').as(:bar)" do
      it "returns :bar => 'foo'" do
        str('foo').as(:bar).parse('foo').should == { bar: 'foo' }
      end
    end

    context "match('[abc]').as(:name)" do
      it "returns :name => 'b'" do
        Parslet.match('[abc]').as(:name).parse('b').should == { name: 'b' }
      end
    end

    context "match('[abc]').repeat.as(:name)" do
      it "returns collated result ('abc')" do
        Parslet.match('[abc]').repeat.as(:name)
          .parse('abc').should == { name: 'abc' }
      end
    end

    context "(str('a').as(:a) >> str('b').as(:b)).as(:c)" do
      it 'returns a hash of hashes' do
        (str('a').as(:a) >> str('b').as(:b)).as(:c)
          .parse('ab').should == {
            c: {
              a: 'a',
              b: 'b',
            },
          }
      end
    end

    context "(str('a').as(:a) >> str('ignore') >> str('b').as(:b))" do
      it "correctlies flatten (leaving out 'ignore')" do
        (str('a').as(:a) >> str('ignore') >> str('b').as(:b))
          .parse('aignoreb').should ==
          {
            a: 'a',
            b: 'b',
          }
      end
    end

    context "(str('a') >> str('ignore') >> str('b')) (no .as(...))" do
      it 'returns simply the original string' do
        (str('a') >> str('ignore') >> str('b'))
          .parse('aignoreb').should == 'aignoreb'
      end
    end

    context "str('a').as(:a) >> str('b').as(:a)" do
      attr_reader :parslet

      before do
        @parslet = str('a').as(:a) >> str('b').as(:a)
      end

      it 'issues a warning that a key is being overwritten in merge' do
        expect(parslet).to receive(:warn).once
        parslet.parse('ab').should == { a: 'b' }
      end

      it "returns :a => 'b'" do
        expect(parslet).to receive(:warn)

        parslet.parse('ab').should == { a: 'b' }
      end
    end

    context "str('a').absent?" do
      it 'returns something in merge, even though it is nil' do
        (str('a').absent? >> str('b').as(:b))
          .parse('b').should == { b: 'b' }
      end
    end

    context "str('a').as(:a).repeat" do
      it 'returns an array of subtrees' do
        expect(str('a').as(:a).repeat.parse('aa')).to eq([{ a: 'a' }, { a: 'a' }])
      end
    end
  end

  describe '<- #flatten(val)' do
    def call(val)
      dummy = str('a')
      allow(dummy).to receive(:warn)
      dummy.flatten(val)
    end

    [
      # In absence of named subtrees: ----------------------------------------
      # Sequence or Repetition
      [[:sequence, 'a', 'b'], 'ab'],
      [[:repetition, 'a', 'a'], 'aa'],

      # Nested inside another node
      [[:sequence, [:sequence, 'a', 'b']], 'ab'],
      # Combined with lookahead (nil)
      [[:sequence, nil, 'a'], 'a'],

      # Including named subtrees ---------------------------------------------
      # Atom: A named subtree
      [{ a: 'a' }, { a: 'a' }],
      # Composition of subtrees
      [[:sequence, { a: 'a' }, { b: 'b' }], { a: 'a', b: 'b' }],
      # Mixed subtrees :sequence of :repetition yields []
      [[:sequence, [:repetition, { a: 'a' }], { a: 'a' }], [{ a: 'a' }, { a: 'a' }]],
      [[:sequence, { a: 'a' }, [:repetition, { a: 'a' }]], [{ a: 'a' }, { a: 'a' }]],
      [[:sequence, [:repetition, { a: 'a' }], [:repetition, { a: 'a' }]], [{ a: 'a' }, { a: 'a' }]],
      # Repetition
      [[:repetition, [:repetition, { a: 'a' }], [:repetition, { a: 'a' }]],
       [{ a: 'a' }, { a: 'a' }]],
      [[:repetition, { a: 'a' }, 'a', { a: 'a' }], [{ a: 'a' }, { a: 'a' }]],
      [[:repetition, { a: 'a' }, [:repetition, { b: 'b' }]], [{ a: 'a' }]],

      # Some random samples --------------------------------------------------
      [[:sequence, { a: :b, b: :c }], { a: :b, b: :c }],
      [[:sequence, { a: :b }, 'a', { c: :d }], { a: :b, c: :d }],
      [[:repetition, { a: :b }, 'a', { c: :d }], [{ a: :b }, { c: :d }]],
      [[:sequence, { a: :b }, { a: :d }], { a: :d }],
      [[:sequence, { a: :b }, [:sequence, [:sequence, "\n", nil]]], { a: :b }],
      [[:sequence, nil, ' '], ' '],
    ].each do |input, output|
      it "transforms #{input.inspect} to #{output.inspect}" do
        call(input).should == output
      end
    end
  end

  describe 'combinations thereof (regression)' do
    [
      [(str('a').repeat >> str('b').repeat), 'aaabbb'],
    ].each do |(parslet, input)|
      describe "#{parslet.inspect} applied to #{input.inspect}" do
        it 'parses successfully' do
          parslet.parse(input)
        end
      end
    end

    [
      [str('a'),                              "'a'"],
      [(str('a') | str('b')).maybe,           "('a' / 'b')?"],
      [(str('a') >> str('b')).maybe,          "('a' 'b')?"],
      [str('a').maybe.maybe,                  "'a'??"],
      [(str('a') >> str('b')).maybe.maybe, "('a' 'b')??"],
      [(str('a') >> (str('b') | str('c'))),   "'a' ('b' / 'c')"],

      [str('a') >> str('b').repeat,           "'a' 'b'{0, }"],
      [(str('a') >> str('b')).repeat,           "('a' 'b'){0, }"],
    ].each do |(parslet, inspect_output)|
      context "regression for #{parslet.inspect}" do
        it "inspects correctly as #{inspect_output}" do
          parslet.inspect.should == inspect_output
        end
      end
    end
  end
end
