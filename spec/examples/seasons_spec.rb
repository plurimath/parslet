require 'spec_helper'
require_relative '../fixtures/examples/seasons'

RSpec.describe 'Seasons Transform Example' do
  let(:initial_tree) { { bud: { stem: [] } } }

  describe SeasonsExample::Spring do
    let(:spring) { SeasonsExample::Spring.new }

    it 'adds a leaf branch to empty stems' do
      tree = { stem: [] }
      result = spring.apply(tree)
      expect(result).to eq({ stem: [{ branch: :leaf }] })
    end

    it 'does not modify stems that are not empty arrays' do
      # Spring only matches empty stems (sequence), not stems with existing content
      tree = { stem: [{ branch: :existing }] }
      result = spring.apply(tree)
      expect(result).to eq({ stem: [{ branch: :existing }] })
    end

    it 'works with nested structures' do
      tree = { bud: { stem: [] } }
      result = spring.apply(tree)
      expect(result).to eq({ bud: { stem: [{ branch: :leaf }] } })
    end
  end

  describe SeasonsExample::Summer do
    let(:summer) { SeasonsExample::Summer.new }

    it 'transforms leaf branches to leaf and flower' do
      tree = { stem: [{ branch: :leaf }] }
      result = summer.apply(tree)
      expect(result).to eq({ stem: [{ branch: [:leaf, :flower] }] })
    end

    it 'transforms multiple branches' do
      tree = { stem: [{ branch: :leaf }, { branch: :leaf }] }
      result = summer.apply(tree)
      expect(result).to eq({ stem: [{ branch: [:leaf, :flower] }, { branch: [:leaf, :flower] }] })
    end

    it 'works with nested structures' do
      tree = { bud: { stem: [{ branch: :leaf }] } }
      result = summer.apply(tree)
      expect(result).to eq({ bud: { stem: [{ branch: [:leaf, :flower] }] } })
    end
  end

  describe SeasonsExample::Fall do
    let(:fall) { SeasonsExample::Fall.new }

    it 'empties branches and prints messages' do
      tree = { branch: [:leaf, :flower] }

      # Capture output
      output = capture_output do
        result = fall.apply(tree)
        expect(result).to eq({ branch: [] })
      end

      expect(output).to include("Fruit!")
      expect(output).to include("Falling Leaves!")
    end

    it 'handles branches with only leaves' do
      tree = { branch: [:leaf] }

      output = capture_output do
        result = fall.apply(tree)
        expect(result).to eq({ branch: [] })
      end

      expect(output).to include("Falling Leaves!")
      expect(output).not_to include("Fruit!")
    end

    it 'handles branches with only flowers' do
      tree = { branch: [:flower] }

      output = capture_output do
        result = fall.apply(tree)
        expect(result).to eq({ branch: [] })
      end

      expect(output).to include("Fruit!")
      expect(output).not_to include("Falling Leaves!")
    end
  end

  describe SeasonsExample::Winter do
    let(:winter) { SeasonsExample::Winter.new }

    it 'empties all stems' do
      tree = { stem: [{ branch: [] }, { branch: [] }] }
      result = winter.apply(tree)
      expect(result).to eq({ stem: [] })
    end

    it 'works with nested structures' do
      tree = { bud: { stem: [{ branch: [] }] } }
      result = winter.apply(tree)
      expect(result).to eq({ bud: { stem: [] } })
    end
  end

  describe 'do_seasons function' do
    it 'cycles through all seasons correctly' do
      tree = { bud: { stem: [] } }

      output = capture_output do
        result = SeasonsExample.do_seasons(tree)

        # After all seasons, should be back to empty stem
        expect(result).to eq({ bud: { stem: [] } })
      end

      # Should contain season announcements
      expect(output).to include("And when SeasonsExample::Spring comes")
      expect(output).to include("And when SeasonsExample::Summer comes")
      expect(output).to include("And when SeasonsExample::Fall comes")
      expect(output).to include("And when SeasonsExample::Winter comes")

      # Should contain fall messages
      expect(output).to include("Fruit!")
      expect(output).to include("Falling Leaves!")
    end
  end

  describe 'integration test' do
    it 'processes the complete seasonal cycle' do
      tree = { bud: { stem: [] } }

      # Spring: adds leaf
      spring = SeasonsExample::Spring.new
      tree = spring.apply(tree)
      expect(tree).to eq({ bud: { stem: [{ branch: :leaf }] } })

      # Summer: leaf becomes leaf + flower
      summer = SeasonsExample::Summer.new
      tree = summer.apply(tree)
      expect(tree).to eq({ bud: { stem: [{ branch: [:leaf, :flower] }] } })

      # Fall: branch becomes empty
      fall = SeasonsExample::Fall.new
      output = capture_output do
        tree = fall.apply(tree)
      end
      expect(tree).to eq({ bud: { stem: [{ branch: [] }] } })
      expect(output).to include("Fruit!")
      expect(output).to include("Falling Leaves!")

      # Winter: stem becomes empty
      winter = SeasonsExample::Winter.new
      tree = winter.apply(tree)
      expect(tree).to eq({ bud: { stem: [] } })
    end

    it 'runs two complete cycles as in the example' do
      tree = { bud: { stem: [] } }

      output = capture_output do
        # First cycle
        tree = SeasonsExample.do_seasons(tree)
        expect(tree).to eq({ bud: { stem: [] } })

        # Second cycle
        tree = SeasonsExample.do_seasons(tree)
        expect(tree).to eq({ bud: { stem: [] } })
      end

      # Should have two sets of season announcements
      season_announcements = output.scan(/And when SeasonsExample::\w+ comes/).length
      expect(season_announcements).to eq(8) # 4 seasons × 2 cycles

      # Should have fruit and falling leaves messages from both cycles
      fruit_count = output.scan(/Fruit!/).length
      leaves_count = output.scan(/Falling Leaves!/).length
      expect(fruit_count).to eq(2) # Once per cycle
      expect(leaves_count).to eq(2) # Once per cycle
    end
  end

  private

  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
