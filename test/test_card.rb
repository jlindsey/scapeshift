require 'helper'

class CardTest < Test::Unit::TestCase
  context "The Card class" do
    should "properly convert cost words to symbols" do
      assert_equal "B", Scapeshift::Card.cost_symbol_from_str("Black")
      assert_equal "W", Scapeshift::Card.cost_symbol_from_str("White")
      assert_equal "U", Scapeshift::Card.cost_symbol_from_str("Blue")
      assert_equal "R", Scapeshift::Card.cost_symbol_from_str("Red")
      assert_equal "G", Scapeshift::Card.cost_symbol_from_str("Green")
      assert_equal "X", Scapeshift::Card.cost_symbol_from_str("Variable Colorless")
      assert_equal "3", Scapeshift::Card.cost_symbol_from_str("3")
      assert_equal "[chaos]", Scapeshift::Card.cost_symbol_from_str("[chaos]")
    end

    should "raise the proper error when passed an invalid cost word" do
      assert_raise Scapeshift::Errors::UnknownCostSymbol do
        Scapeshift::Card.cost_symbol_from_str "Yellow"
      end
    end
  end
  
  context "A Card object" do
    context "with complex types" do
      setup do
        @types_str = "Legendary Artifact Creature - Human Wizard"
        @card = Scapeshift::Card.new
        @card.types = @types_str
      end

      should "parse the types string correctly" do
        assert_equal %w{Legendary}, @card.supertypes
        assert_equal %w{Artifact Creature}, @card.base_types
        assert_equal %w{Human Wizard}, @card.subtypes
      end

      should "display the string representation of its types" do
        assert_equal @types_str, @card.types
      end
    end

    context "with several sets and rarities" do
      setup do
        printings = [["Magic 2010", "Rare"], ["Tenth Edition", "Uncommon"]]
        @card = Scapeshift::Card.new :sets => printings
      end

      should "display its most recent set" do
        assert_equal "Magic 2010", @card.set
      end

      should "display its most recent rarity" do
        assert_equal "Rare", @card.rarity
      end
    end

    context "that was instantiated with a Hash" do
      setup do
        @params = { :name => "Mind Spring", :cost => "XBB",
          :types => "Sorcery", :text => "Draw X cards.",
          :sets => [["Magic 2010", "Rare"], ["Morningtide", "Rare"]],
          :image_id => 191323 }

        @card = Scapeshift::Card.new @params
      end

      should "have its attributes set properly" do
        assert_instance_of Scapeshift::Card, @card

        assert_equal @params[:name], @card.name
        assert_equal @params[:cost], @card.cost
        assert_equal @params[:types], @card.types
        assert_equal @params[:text], @card.text
        assert_equal @params[:sets], @card.sets
        assert_equal 'http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=191323&type=card', @card.image_uri
      end
    end
  end
end

